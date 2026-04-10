import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart'
    show Client, Response, MultipartRequest, MultipartFile;

/// API WRAPPER to call all the IsmLiveApis and handle the status codes
class IsmLiveApiWrapper {
  const IsmLiveApiWrapper(this.client);

  final Client client;

  // Ensures only one refresh flow is in-flight at a time.
  static Future<String?>? _refreshingToken;

  static bool _isTokenExpiredResponse(Response response) {
    // Backend contract (production): token-expired returns ONLY 401.
    return response.statusCode == 401;
  }

  static Map<String, String> _withUpdatedUserTokenHeader(
    Map<String, String> headers,
    String newToken,
  ) {
    final t = newToken.trim();
    if (t.isEmpty) return headers;
    if (!headers.containsKey('userToken')) return headers;

    final next = Map<String, String>.from(headers);
    next['userToken'] = t;
    return next;
  }

  Future<String?> _refreshTokenFromHostApp() async {
    final cb = IsmLiveDelegate.tokenExpiredCallback;
    if (cb == null) return null;

    // Coalesce concurrent 401/406 refresh attempts into one callback call.
    final existing = _refreshingToken;
    if (existing != null) return await existing;

    final completer = Completer<String?>();
    _refreshingToken = completer.future;

    try {
      final token = await cb();
      final t = token?.trim();
      if (t != null && t.isNotEmpty) {
        IsmLiveUtility.updateUserToken(t);
      }
      completer.complete(t);
      return t;
    } catch (e, st) {
      IsmLiveLog.error('Token refresh callback failed: $e', st);
      completer.complete(null);
      return null;
    } finally {
      _refreshingToken = null;
    }
  }

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
    int tokenRefreshAttempts = 0,
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

        // Handle token expired: request new token from host app and retry once.
        if (tokenRefreshAttempts == 0 && _isTokenExpiredResponse(response)) {
          final newToken = await _refreshTokenFromHostApp();
          if (newToken != null && newToken.trim().isNotEmpty) {
            final updatedHeaders =
                _withUpdatedUserTokenHeader(headers, newToken);
            return makeRequest(
              api,
              baseUrl: baseUrl,
              type: type,
              headers: updatedHeaders,
              payload: payload,
              field: field,
              filePath: filePath,
              showDialog: showDialog,
              showLoader: showLoader,
              shouldEncodePayload: shouldEncodePayload,
              message: message,
              tokenRefreshAttempts: 1,
            );
          }
        }

        // Handles response based on status code
        var res = await _processResponse(
          response,
          showDialog: showDialog,
          startTime: start,
        );

        // API result analytics (no raw response body). Includes full [headers]
        // and [request_payload] as provided (JSON-safe body; binary → placeholder).
        // Must never break API flows.
        try {
          final durationMs = DateTime.now().difference(start).inMilliseconds;
          String? errorSummary;
          if (res.hasError) {
            try {
              final decoded = res.decode();
              errorSummary = _apiErrorSummaryForAnalytics(decoded);
            } catch (_) {
              // ignore: best-effort only
            }
          }

          Map<String, dynamic>? userInfo;
          try {
            if (IsmLiveUtility.hasValidUserToken) {
              final uc = IsmLiveUtility.config.userConfig;
              userInfo = {
                'user_id': uc.userId,
                'first_name': uc.firstName,
                'last_name': uc.lastName,
                'user_email': uc.userEmail,
                'user_profile': uc.userProfile,
              };
            }
          } catch (_) {
            // SDK may not be initialized yet; safe to skip.
          }

          final requestPayload = _requestPayloadForAnalytics(
            type: type,
            payload: payload,
            field: field,
            filePath: filePath,
          );

          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.apiResult,
            properties: [
              {
                'path': api,
                'base_url': baseUrl ?? IsmLiveApis.baseUrl,
                'method': type.name.toUpperCase(),
                'headers': Map<String, String>.from(headers),
                'status_code': res.statusCode,
                'has_error': res.hasError,
                'duration_ms': durationMs,
                if (errorSummary != null) 'error': errorSummary,
                if (userInfo != null) 'user': userInfo,
                if (requestPayload != null) 'request_payload': requestPayload,
              }
            ],
          );
        } catch (_) {
          // ignore: analytics must never impact API calls
        }

        if (showLoader) {
          IsmLiveUtility.closeLoader();
        }
        return res;
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
          // onRetry: () => makeRequest(
          //   api,
          //   baseUrl: baseUrl,
          //   type: type,
          //   headers: headers,
          //   payload: payload,
          //   field: field,
          //   filePath: filePath,
          //   showDialog: showDialog,
          //   showLoader: showLoader,
          //   shouldEncodePayload: shouldEncodePayload,
          // ),
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

    if (kDebugMode) {
      final body = utf8.decode(response.bodyBytes);
      IsmLiveLog(
        '[Response Debug] - ${response.statusCode} ${response.request?.url}\n'
        'Headers: ${response.headers}\n'
        'Body:\n$body',
      );
    } else {
      IsmLiveLog(
        '[Response] - ${diff}s ${response.statusCode} ${response.request?.url}',
      );
    }

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

  /// Best-effort text for analytics only; capped length, no PII beyond API messages.
  static String? _apiErrorSummaryForAnalytics(Map<String, dynamic> decoded) {
    const maxLen = 160;
    String? truncate(String s) {
      final t = s.trim();
      if (t.isEmpty) return null;
      return t.length > maxLen ? t.substring(0, maxLen) : t;
    }

    final candidate = (decoded['error'] ??
            decoded['message'] ??
            decoded['msg'] ??
            decoded['reason'])
        ?.toString();
    final fromFlat = truncate(candidate ?? '');
    if (fromFlat != null) return fromFlat;

    final fromErrors = _messagesFromErrorsObject(decoded['errors']);
    return truncate(fromErrors ?? '');
  }

  /// Parses `errors` shapes like `{"field":["msg"]}` or a string/list at `errors`.
  static String? _messagesFromErrorsObject(dynamic errors) {
    if (errors == null) return null;
    if (errors is String) {
      final s = errors.trim();
      return s.isEmpty ? null : s;
    }
    if (errors is List) {
      final parts = <String>[];
      for (final e in errors) {
        if (e is String) {
          final t = e.trim();
          if (t.isNotEmpty) parts.add(t);
        } else if (e != null) {
          final t = e.toString().trim();
          if (t.isNotEmpty) parts.add(t);
        }
      }
      if (parts.isEmpty) return null;
      return parts.join(', ');
    }
    if (errors is Map) {
      final parts = <String>[];
      for (final entry in errors.entries) {
        final key = entry.key.toString();
        final nested = _messagesFromErrorsObject(entry.value);
        if (nested != null && nested.isNotEmpty) {
          parts.add('$key: $nested');
        }
      }
      if (parts.isEmpty) return null;
      return parts.join('; ');
    }
    return null;
  }

  static const int _maxAnalyticsPayloadDepth = 32;

  /// JSON-serializable snapshot of [value] for analytics (no key redaction).
  static dynamic _payloadTreeForAnalytics(dynamic value, int depth) {
    if (depth > _maxAnalyticsPayloadDepth) {
      return '[max_depth]';
    }
    if (value == null || value is bool || value is num) {
      return value;
    }
    if (value is String) {
      return value;
    }
    if (value is Uint8List) {
      return 'binary(${value.length} bytes)';
    }
    if (value is List<int>) {
      return 'bytes(${value.length})';
    }
    if (value is Map) {
      final out = <String, dynamic>{};
      for (final e in value.entries) {
        out[e.key.toString()] = _payloadTreeForAnalytics(e.value, depth + 1);
      }
      return out;
    }
    if (value is List) {
      return value
          .map((e) => _payloadTreeForAnalytics(e, depth + 1))
          .toList();
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    return value.toString();
  }

  static Map<String, dynamic>? _requestPayloadForAnalytics({
    required IsmLiveRequestType type,
    required dynamic payload,
    required String field,
    required String filePath,
  }) {
    try {
      if (type == IsmLiveRequestType.get) {
        return null;
      }

      if (type == IsmLiveRequestType.upload) {
        final m = <String, dynamic>{
          'kind': 'multipart',
          if (field.isNotEmpty) 'file_field': field,
          'has_file': filePath.isNotEmpty,
        };
        if (payload is Map<String, String>) {
          m['fields'] = Map<String, dynamic>.from(payload);
        }
        return _ensureJsonEncodablePayloadMap(m);
      }

      if (payload == null) {
        return null;
      }

      dynamic body;
      if (payload is String) {
        try {
          final decoded = jsonDecode(payload);
          body = _payloadTreeForAnalytics(decoded, 0);
        } catch (_) {
          body = payload;
        }
      } else {
        body = _payloadTreeForAnalytics(payload, 0);
      }

      return _ensureJsonEncodablePayloadMap(<String, dynamic>{'body': body});
    } catch (_) {
      return <String, dynamic>{'body': '[unavailable]'};
    }
  }

  static Map<String, dynamic> _ensureJsonEncodablePayloadMap(
      Map<String, dynamic> m) {
    try {
      jsonEncode(m);
      return m;
    } catch (_) {
      return <String, dynamic>{'body': '[unavailable]'};
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
      buffer.write(
          " -H '${escapeSingleQuotes(entry.key)}: ${escapeSingleQuotes(entry.value)}'");
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
