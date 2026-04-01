import 'dart:async';
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:http/http.dart'
    show Client, Response, MultipartRequest, MultipartFile;

/// API WRAPPER to call all the IsmLiveApis and handle the status codes
class IsmLiveApiWrapper {
  const IsmLiveApiWrapper(this.client);

  final Client client;

  /// Method to make all the requests inside the app like GET, POST, PUT, Delete
  Future<IsmLiveResponseModel> makeRequest(
    String api, {
    String? baseUrl,
    required IsmLiveRequestType type,
    required Map<String, String> headers,
    dynamic payload,
    String field = '',
    String filePath = '',
    bool showLoader = false,
    bool showDialog = true,
    bool shouldEncodePayload = true,
    String? message,
  }) async {
    assert(
      type != IsmLiveRequestType.upload ||
          (type == IsmLiveRequestType.upload &&
              payload is! Map<String, String> &&
              field.isNotEmpty &&
              filePath.isNotEmpty),
      'if type is passed as [RequestType.upload] then payload must be of type Map<String, String> and field & filePath must not be empty',
    );
    assert(
      type != IsmLiveRequestType.get ||
          (type == IsmLiveRequestType.get && payload == null),
      'if type is passed as [RequestType.get] then payload must not be passed',
    );

    /// To see whether the network is available or not
    var url = (baseUrl ?? IsmLiveApis.baseUrl) + api;

    final uri = Uri.parse(url);

    // Logging must never affect the actual API call. Keep this 100% safe.
    try {
      // Log-only cURL: must be type-safe because `payload` can be non-String
      // (e.g. Uint8List for binary flows) in some integrators.
      final body = type != IsmLiveRequestType.upload
          ? _stringifyBodyForCurl(
              payload: payload,
              shouldEncodePayload: shouldEncodePayload,
            )
          : null;
      final curlCommand = _toCurl(
        uri: uri,
        type: type,
        headers: headers,
        body: body,
        multipartField: type == IsmLiveRequestType.upload ? field : null,
        multipartFilePath: type == IsmLiveRequestType.upload ? filePath : null,
        multipartFields:
            type == IsmLiveRequestType.upload && payload is Map<String, String>
                ? payload
                : null,
      );
      IsmLiveLog.info('[cURL] $curlCommand');
    } catch (e, st) {
      IsmLiveLog.info(
          '[Request] - ${type.name.toUpperCase()} - $uri (cURL log failed: ${e.runtimeType})');
      IsmLiveLog.error(e, st);
    }

    if (showLoader) IsmLiveUtility.showLoader(message);
    if (await IsmLiveUtility.isNetworkAvailable) {
      try {
        // Handles API call
        final start = DateTime.now();
        var response = await _handleRequest(
          uri,
          type: type,
          headers: headers,
          payload: shouldEncodePayload ? jsonEncode(payload) : payload,
          field: field,
          filePath: filePath,
        );

        // Handles response based on status code
        var res = await _processResponse(
          response,
          showDialog: showDialog,
          startTime: start,
        );

        // Sanitized API result analytics (no response body, no payload).
        // Must never break API flows.
        try {
          final durationMs = DateTime.now().difference(start).inMilliseconds;
          String? errorSummary;
          if (res.hasError) {
            try {
              final decoded = res.decode();
              final candidate = (decoded['error'] ??
                      decoded['message'] ??
                      decoded['msg'] ??
                      decoded['reason'])
                  ?.toString();
              if (candidate != null && candidate.trim().isNotEmpty) {
                errorSummary = candidate.trim();
                if (errorSummary.length > 160) {
                  errorSummary = errorSummary.substring(0, 160);
                }
              }
            } catch (_) {
              // ignore: best-effort only
            }
          }

          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.apiResult,
            properties: [
              {
                'path': api,
                'base_url': baseUrl ?? IsmLiveApis.baseUrl,
                'method': type.name.toUpperCase(),
                'status_code': res.statusCode,
                'has_error': res.hasError,
                'duration_ms': durationMs,
                if (errorSummary != null) 'error': errorSummary,
              }
            ],
          );
        } catch (_) {
          // ignore: analytics must never impact API calls
        }

        if (showLoader) {
          IsmLiveUtility.closeLoader();
        }
        if (res.statusCode != 406) {
          return res;
        }
        return makeRequest(
          api,
          baseUrl: baseUrl,
          type: type,
          headers: headers,
          payload: payload,
          field: field,
          filePath: filePath,
          showDialog: showDialog,
          showLoader: showLoader,
          shouldEncodePayload: shouldEncodePayload,
        );
      } on TimeoutException catch (e, st) {
        IsmLiveLog.error('TimeOutException - $e', st);
        if (showLoader) {
          IsmLiveUtility.closeLoader();
        }
        await Future.delayed(const Duration(milliseconds: 100));
        var res = IsmLiveResponseModel.message(IsmLiveStrings.timeoutError);
        if (showDialog) {
          await IsmLiveUtility.showInfoDialog(
            res,
            title: 'Timeout Error',
            onRetry: () => makeRequest(
              api,
              baseUrl: baseUrl,
              type: type,
              headers: headers,
              payload: payload,
              field: field,
              filePath: filePath,
              showDialog: showDialog,
              showLoader: showLoader,
              shouldEncodePayload: shouldEncodePayload,
            ),
          );
        }
        return res;
      } on ArgumentError catch (e, st) {
        IsmLiveLog.error(e, st);
        if (showLoader) {
          IsmLiveUtility.closeLoader();
        }
        await Future.delayed(const Duration(milliseconds: 100));
        var res =
            IsmLiveResponseModel.message(IsmLiveStrings.somethingWentWrong);

        if (showDialog) {
          await IsmLiveUtility.showInfoDialog(
            res,
            title: 'Argument Error',
          );
        }
        return res;
      } catch (e, st) {
        IsmLiveLog.info(e.runtimeType);
        IsmLiveLog.error(e, st);
        if (showLoader) {
          IsmLiveUtility.closeLoader();
        }
        await Future.delayed(const Duration(milliseconds: 100));
        var res =
            IsmLiveResponseModel.message(IsmLiveStrings.somethingWentWrong);

        if (showDialog) {
          await IsmLiveUtility.showInfoDialog(res);
        }
        return res;
      }
    } else {
      IsmLiveLog.error('No Internet Connection', StackTrace.current);
      if (showLoader) {
        IsmLiveUtility.closeLoader();
      }
      await Future.delayed(const Duration(milliseconds: 100));
      var res = IsmLiveResponseModel.message(IsmLiveStrings.noInternet);

      if (showDialog) {
        await IsmLiveUtility.showInfoDialog(
          res,
          title: 'Internet Error',
          onRetry: () => makeRequest(
            api,
            baseUrl: baseUrl,
            type: type,
            headers: headers,
            payload: payload,
            field: field,
            filePath: filePath,
            showDialog: showDialog,
            showLoader: showLoader,
            shouldEncodePayload: shouldEncodePayload,
          ),
        );
      }
      return res;
    }
  }

  Future<Response> _handleRequest(
    Uri api, {
    required IsmLiveRequestType type,
    required Map<String, String> headers,
    required String field,
    required String filePath,
    dynamic payload,
  }) async {
    switch (type) {
      case IsmLiveRequestType.get:
        return _get(api, headers: headers);
      case IsmLiveRequestType.post:
        return _post(api, payload: payload, headers: headers);
      case IsmLiveRequestType.put:
        return _put(api, payload: payload, headers: headers);
      case IsmLiveRequestType.patch:
        return _patch(api, payload: payload, headers: headers);
      case IsmLiveRequestType.delete:
        return _delete(api, payload: payload, headers: headers);
      case IsmLiveRequestType.upload:
        return _upload(
          api,
          payload: payload,
          headers: headers,
          field: field,
          filePath: filePath,
        );
    }
  }

  Future<Response> _get(
    Uri api, {
    required Map<String, String> headers,
  }) async =>
      await client
          .get(
            api,
            headers: headers,
          )
          .timeout(IsmLiveConstants.timeOutDuration);

  Future<Response> _post(
    Uri api, {
    required payload,
    required Map<String, String> headers,
  }) async =>
      await client
          .post(
            api,
            body: payload,
            headers: headers,
          )
          .timeout(IsmLiveConstants.timeOutDuration);

  Future<Response> _put(
    Uri api, {
    required dynamic payload,
    required Map<String, String> headers,
  }) async =>
      await client
          .put(
            api,
            body: payload,
            headers: headers,
          )
          .timeout(IsmLiveConstants.timeOutDuration);

  Future<Response> _patch(
    Uri api, {
    required dynamic payload,
    required Map<String, String> headers,
  }) async =>
      await client
          .patch(
            api,
            body: payload,
            headers: headers,
          )
          .timeout(IsmLiveConstants.timeOutDuration);

  Future<Response> _delete(
    Uri api, {
    required dynamic payload,
    required Map<String, String> headers,
  }) async =>
      await client
          .delete(
            api,
            body: payload,
            headers: headers,
          )
          .timeout(IsmLiveConstants.timeOutDuration);

  /// Method to make all the requests inside the app like GET, POST, PUT, Delete
  Future<Response> _upload(
    Uri api, {
    required Map<String, String> payload,
    required Map<String, String> headers,
    required String field,
    required String filePath,
  }) async {
    var request = MultipartRequest(
      'POST',
      api,
    )
      ..headers.addAll(headers)
      ..fields.addAll(payload)
      ..files.add(
        await MultipartFile.fromPath(field, filePath),
      );

    var response = await request.send();

    return await Response.fromStream(response);
  }

  /// Method to return the API response based upon the status code of the server
  Future<IsmLiveResponseModel> _processResponse(
    Response response, {
    required bool showDialog,
    required DateTime startTime,
  }) async {
    var diff = DateTime.now().difference(startTime).inMilliseconds / 1000;
    // Production-safe logging: do not print full response bodies.
    // (Bodies may contain PII, tokens, and can be very large.)
    IsmLiveLog(
      '[Response] - ${diff}s ${response.statusCode} ${response.request?.url}',
    );

    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
      case 203:
      case 204:
      case 205:
      case 208:
        return IsmLiveResponseModel(
          data: utf8.decode(response.bodyBytes),
          hasError: false,
          statusCode: response.statusCode,
        );
      case 400:
      case 401:
      case 404:
      case 406:
      case 409:
      case 410:
      case 412:
      case 413:
      case 415:
      case 416:
      case 522:
        if (response.statusCode == 401) {
          // UnAuthorized
          // Logic to clear the data and send user to login view
          // ex: Get.find<ProfileController>().clearData();
          //     RouteManagement.goToSignIn();
        } else if (response.statusCode == 406) {
          // Token expired
          // Logic to refresh the token the API will be called again automatically from the makeRequest function
          // ex: await Get.find<AuthController>().refreshToken();
        }
        var hasError = true;
        var res = IsmLiveResponseModel(
          data: utf8.decode(response.bodyBytes),
          hasError: hasError,
          statusCode: response.statusCode,
        );
        if (![401, 406, 410].contains(response.statusCode) && showDialog) {
          await IsmLiveUtility.showInfoDialog(res);
        }
        return res;
      case 500:
        var res = IsmLiveResponseModel.message(
          'Server error',
          statusCode: response.statusCode,
        );
        if (showDialog) {
          await IsmLiveUtility.showInfoDialog(res);
        }
        return res;

      default:
        return IsmLiveResponseModel(
          data: utf8.decode(response.bodyBytes),
          hasError: true,
          statusCode: response.statusCode,
        );
    }
  }

  /// Builds a copy-pasteable cURL command for the request (for developer debugging).
  static String _toCurl({
    required Uri uri,
    required IsmLiveRequestType type,
    required Map<String, String> headers,
    String? body,
    String? multipartField,
    String? multipartFilePath,
    Map<String, String>? multipartFields,
  }) {
    String escapeSingleQuotes(String s) => s.replaceAll("'", r"'\''");

    final buffer = StringBuffer('curl');
    buffer.write(' -X ${_curlMethod(type)}');
    buffer.write(" '${escapeSingleQuotes(uri.toString())}'");

    for (final entry in headers.entries) {
      buffer.write(" -H '${escapeSingleQuotes(entry.key)}: ${escapeSingleQuotes(entry.value)}'");
    }

    if (type == IsmLiveRequestType.upload) {
      if (multipartField != null && multipartFilePath != null) {
        buffer.write(
            " -F '${escapeSingleQuotes(multipartField)}=@${escapeSingleQuotes(multipartFilePath)}'");
      }
      if (multipartFields != null && multipartFields.isNotEmpty) {
        for (final entry in multipartFields.entries) {
          buffer.write(
              " -F '${escapeSingleQuotes(entry.key)}=${escapeSingleQuotes(entry.value)}'");
        }
      }
    } else if (body != null && body.isNotEmpty) {
      buffer.write(" -d '${escapeSingleQuotes(body)}'");
    }

    return buffer.toString();
  }

  static String _curlMethod(IsmLiveRequestType type) {
    // cURL uses HTTP methods; uploads here are multipart POST.
    switch (type) {
      case IsmLiveRequestType.get:
        return 'GET';
      case IsmLiveRequestType.post:
        return 'POST';
      case IsmLiveRequestType.put:
        return 'PUT';
      case IsmLiveRequestType.patch:
        return 'PATCH';
      case IsmLiveRequestType.delete:
        return 'DELETE';
      case IsmLiveRequestType.upload:
        return 'POST';
    }
  }

  static String? _stringifyBodyForCurl({
    required dynamic payload,
    required bool shouldEncodePayload,
  }) {
    if (payload == null) return null;
    if (payload is String) return payload;

    if (shouldEncodePayload) {
      try {
        return jsonEncode(payload);
      } catch (_) {
        // Fall back to a best-effort representation.
      }
    }

    // Avoid crashes for binary bodies; keep logs useful but safe.
    if (payload is List<int>) {
      try {
        return 'base64:${base64Encode(payload)}';
      } catch (_) {
        return 'binary(${payload.length} bytes)';
      }
    }

    return payload.toString();
  }
}
