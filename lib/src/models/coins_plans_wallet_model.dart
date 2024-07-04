import 'dart:convert';

import 'package:get/get.dart';

CoinPlansModel coinsPlansWalletModelFromJson(String str) =>
    CoinPlansModel.fromJson(json.decode(str));

class CoinPlansModel {
  const CoinPlansModel({
    this.status = '',
    this.message = '',
    this.data = const [],
    this.totalCount = 0,
  });

  factory CoinPlansModel.fromJson(Map<String, dynamic> json) => CoinPlansModel(
        status: json['status'] as String? ?? '',
        message: json['message'] as String? ?? '',
        data: List<CoinPlan>.from((json['data'] as List? ?? [])
            .map((x) => CoinPlan.fromJson(x as Map<String, dynamic>))),
        totalCount: json['totalCount'] as int? ?? 0,
      );
  final String status;
  final String message;
  final List<CoinPlan> data;
  final int totalCount;

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': List.from(data.map((x) => x.toJson())),
        'totalCount': totalCount,
      };
}

class CoinPlan {
  const CoinPlan({
    this.id = '',
    this.currencyPlanImage = '',
    this.baseCurrencyValue = 0,
    this.numberOfUnits = 0,
    this.appStoreProductIdentifier = '',
    this.googlePlayProductIdentifier = '',
    this.planDescription = '',
    this.planId = '',
    this.planName = '',
    this.applicationId = '',
    this.clientName = '',
    this.baseCurrency = '',
    this.unitSymbol = '',
    this.baseCurrencySymbol = '',
    this.status = '',
  });

  factory CoinPlan.fromJson(Map<String, dynamic> json) => CoinPlan(
        id: json['id'] as String? ?? '',
        currencyPlanImage: json['currencyPlanImage'] as String? ?? '',
        baseCurrencyValue: json['baseCurrencyValue'] as num? ?? 0,
        numberOfUnits: json['numberOfUnits'] as num? ?? 0,
        appStoreProductIdentifier:
            json['appStoreProductIdentifier'] as String? ?? '',
        googlePlayProductIdentifier:
            json['googlePlayProductIdentifier'] as String? ?? '',
        planDescription: json['planDescription'] as String? ?? '',
        planId: json['planId'] as String? ?? '',
        planName: json['planName'] as String? ?? '',
        applicationId: json['applicationId'] as String? ?? '',
        clientName: json['clientName'] as String? ?? '',
        baseCurrency: json['baseCurrency'] as String? ?? '',
        unitSymbol: json['unitSymbol'] as String? ?? '',
        baseCurrencySymbol: json['baseCurrencySymbol'] as String? ?? '',
        status: json['status'] as String? ?? '',
      );
  final String id;
  final String currencyPlanImage;
  final num baseCurrencyValue;
  final num numberOfUnits;
  final String appStoreProductIdentifier;
  final String googlePlayProductIdentifier;
  final String planDescription;
  final String planId;
  final String planName;
  final String applicationId;
  final String clientName;
  final String baseCurrency;
  final String unitSymbol;
  final String baseCurrencySymbol;
  final String status;

  String get platformPlanId {
    if (GetPlatform.isAndroid) return googlePlayProductIdentifier;
    if (GetPlatform.isIOS) return appStoreProductIdentifier;
    return '';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'currencyPlanImage': currencyPlanImage,
        'baseCurrencyValue': baseCurrencyValue,
        'numberOfUnits': numberOfUnits,
        'appStoreProductIdentifier': appStoreProductIdentifier,
        'googlePlayProductIdentifier': googlePlayProductIdentifier,
        'planDescription': planDescription,
        'planId': planId,
        'planName': planName,
        'applicationId': applicationId,
        'clientName': clientName,
        'baseCurrency': baseCurrency,
        'unitSymbol': unitSymbol,
        'baseCurrencySymbol': baseCurrencySymbol,
        'status': status,
      };
}
