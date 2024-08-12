import 'dart:convert';
import 'dart:math';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';

extension IsmLiveNullString on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
}

extension IsmLiveMapExtension on Map<String, dynamic> {
  Map<String, dynamic> removeNullValues() {
    var result = <String, dynamic>{};
    for (var entry in entries) {
      var k = entry.key;
      var v = entry.value;
      if (v != null) {
        if (!v.runtimeType.toString().contains('List') &&
            v.runtimeType.toString().contains('Map')) {
          result[k] = (v as Map<String, dynamic>).removeNullValues();
        } else {
          result[k] = v;
        }
      }
    }
    return result;
  }

  String makeQuery() {
    var res = [];
    for (var entry in removeNullValues().entries) {
      var key = entry.key;
      var value = entry.value;
      res.add('$key=$value');
    }
    return res.join('&');
  }
}

extension IsmLiveStreamTypeExtension on IsmLiveStreamType {
  IsmLiveStreamQueryModel queryModel({int skip = 0}) {
    var model = IsmLiveStreamQueryModel(
        skip: skip, limit: 10, status: 4, sortOrder: 'asc');
    switch (this) {
      case IsmLiveStreamType.all:
        return model.copyWith(fetchLive: true);
      // case IsmLiveStreamType.audioOnly:
      //   return model.copyWith(audioOnly: true);
      // case IsmLiveStreamType.multilive:
      //   return model.copyWith(multiLive: true);
      // case IsmLiveStreamType.private:
      //   return model.copyWith(private: true);
      // case IsmLiveStreamType.ecommerce:
      //   return model.copyWith(productsLinked: true);
      case IsmLiveStreamType.restream:
        return model.copyWith(reStream: true);
      case IsmLiveStreamType.hd:
        return model.copyWith(hdbroadcast: true);
      case IsmLiveStreamType.recorded:
        return model.copyWith(isRecorded: true);
      case IsmLiveStreamType.pk:
        return model.copyWith(pk: true);
      case IsmLiveStreamType.scheduledStreams:
        return model;
    }
  }
}

extension IsmLiveEditingExtension on TextEditingController {
  bool get isEmpty => text.trim().isEmpty;

  bool get isNotEmpty => text.trim().isNotEmpty;
}

extension IsmLiveContextExtension on BuildContext {
  IsmLiveDataExtension? get liveExtension =>
      Theme.of(this).extension<IsmLiveDataExtension>();

  IsmLiveThemeData? get liveTheme => liveExtension?.theme;

  IsmLiveConfigData get liveConfig => IsmLiveUtility.config;

  IsmLiveTranslationsData? get liveTranslations => liveExtension?.translations;

  IsmLivePropertiesData? get liveProperties => liveExtension?.properties;
}

extension IsmLiveMaterialStateExtension on Set<WidgetState> {
  bool get isDisabled => any((e) => [WidgetState.disabled].contains(e));
}

extension IsmLiveDurationExtension on Duration {
  String get formattedTime {
    final h = inHours.toString().padLeft(2, '0');
    final m = (inMinutes % 60).toString().padLeft(2, '0');
    final s = (inSeconds % 60).toString().padLeft(2, '0');
    return [h, m, s].join(':');
  }

  String get formattedTimeInMin {
    final m = (inMinutes % 60).toString().padLeft(2, '0');
    final s = (inSeconds % 60).toString().padLeft(2, '0');
    return [m, s].join(':');
  }
}

extension IsmLiveIntExtensions on num {
  double get sheetHeight =>
      IsmLiveDimens.oneHundredTwenty + this * IsmLiveDimens.sixty;

  String formatWithKAndL() {
    if (this >= 100000) {
      var lakhs = this ~/ 100000;
      return '${lakhs.toString().replaceAll(RegExp(r'\.0$'), '')} L';
    } else if (this >= 1000) {
      var thousands = this / 1000;
      return '${thousands.toString().replaceAll(RegExp(r'\.0$'), '')} K';
    } else {
      return toString();
    }
  }
}

extension IsmLiveDoubleExtensions on double {
  double get verticalPosition => Get.height * 1.1 * this;

  double get horizontalPosition {
    final random1 = Random().nextBool();
    final random2 = Random().nextBool();
    final value = random1
        ? random2
            ? 0.3
            : 0.4
        : random2
            ? 0.6
            : 0.7;
    return Get.width * 0.5 * this * value;
  }
}

extension IsmLiveRestreamExtensions on IsmLiveRestreamType {
  String get icon {
    switch (value) {
      case 2:
        return IsmLiveAssetConstants.instagram;
      case 1:
        return IsmLiveAssetConstants.youtube;

      default:
        return IsmLiveAssetConstants.facebook;
    }
  }

  String get linkPreview => 'www.$name.com';
}

extension IsmLiveDateExtensions on DateTime {
  String get formattedDate {
    final date = DateFormat('dd MMM yyyy, hh:mm aa');
    return date.format(this);
  }

  String get formattedTime {
    final date = DateFormat('hh:mm aa');
    return date.format(this);
  }
}

extension IsmLiveUserConfigExtensions on IsmLiveUserConfig {
  UserDetails getDetails() => UserDetails(
        userProfileImageUrl: userProfile ?? '',
        userName: firstName,
        userIdentifier: userEmail ?? '',
        userId: userId,
      );
}

extension IsmLiveAlignmentExtension on Alignment {
  bool get isBottomAligned => [
        Alignment.bottomLeft,
        Alignment.bottomCenter,
        Alignment.bottomRight
      ].contains(this);
}

extension InAppProductExtension on ProductDetails {
  String toJson() {
    final data = {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'rawPrice': rawPrice,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
    };
    return jsonEncode(data);
  }
}
