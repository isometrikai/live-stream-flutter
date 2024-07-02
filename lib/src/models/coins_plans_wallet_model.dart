// To parse this JSON data, do
//
//     final coinsPlansWalletModel = coinsPlansWalletModelFromJson(jsonString);

import 'dart:convert';

import 'package:get/get.dart';

CoinsPlansWalletModel coinsPlansWalletModelFromJson(String str) =>
    CoinsPlansWalletModel.fromJson(json.decode(str));

String coinsPlansWalletModelToJson(CoinsPlansWalletModel data) =>
    json.encode(data.toJson());

class CoinsPlansWalletModel {
  CoinsPlansWalletModel({
    this.status = '',
    this.message = '',
    List<CoinPlansWalletRes>? data,
    this.totalCount = 0,
  }) : data = data ?? [];

  factory CoinsPlansWalletModel.fromJson(Map<String, dynamic> json) =>
      CoinsPlansWalletModel(
        status: json['status'],
        message: json['message'],
        data: List<CoinPlansWalletRes>.from(
          json['data'].map(
            (x) => CoinPlansWalletRes.fromJson(x as Map<String, dynamic>),
          ),
        ),
        totalCount: json['totalCount'],
      );
  final String status;
  final String message;
  final List<CoinPlansWalletRes> data;
  final int totalCount;

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': List.from(
          data.map(
            (x) => x.toJson(),
          ),
        ),
        'totalCount': totalCount,
      };
}

class CoinPlansWalletRes {
  const CoinPlansWalletRes({
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

  factory CoinPlansWalletRes.fromJson(Map<String, dynamic> json) =>
      CoinPlansWalletRes(
        id: json['id'],
        currencyPlanImage: json['currencyPlanImage'],
        baseCurrencyValue: json['baseCurrencyValue']?.toDouble(),
        numberOfUnits: json['numberOfUnits'],
        appStoreProductIdentifier: json['appStoreProductIdentifier'],
        googlePlayProductIdentifier: json['googlePlayProductIdentifier'],
        planDescription: json['planDescription'],
        planId: json['planId'],
        planName: json['planName'],
        applicationId: json['applicationId'],
        clientName: json['clientName'],
        baseCurrency: json['baseCurrency'],
        unitSymbol: json['unitSymbol'],
        baseCurrencySymbol: json['baseCurrencySymbol'],
        status: json['status'],
      );
  final String id;
  final String currencyPlanImage;
  final double baseCurrencyValue;
  final int numberOfUnits;
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
    if (GetPlatform.isAndroid) {
      return googlePlayProductIdentifier;
    }
    return appStoreProductIdentifier;
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

class PurchaseBody {
  PurchaseBody({
    required this.planId,
    required this.transactionId,
    required this.deviceType,
    required this.packageName,
    required this.productId,
    required this.purchaseToken,
  });
  final String planId;
  final String transactionId;
  final String deviceType;
  final String packageName;
  final String productId;
  final String purchaseToken;

  Map<String, dynamic> toJson() => {
        'planId': planId,
        'transactionId': transactionId,
        'deviceType': deviceType,
        'packageName': packageName,
        'productId': productId,
        'purchaseToken': purchaseToken,
      };

  static PurchaseBody fromJson(Map<String, dynamic> json) => PurchaseBody(
        planId: json['planId'],
        transactionId: json['transactionId'],
        deviceType: json['deviceType'],
        packageName: json['packageName'],
        productId: json['productId'],
        purchaseToken: json['purchaseToken'],
      );
}
