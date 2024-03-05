// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class IsmLiveProductDetailModel {
  final String? priceCurrency;
  final String? productAvailability;
  final String? productBrand;
  final String? productColor;
  final String? productDescription;
  final List<String>? productImage;
  final String? productMPN;
  final String? productMSRP;
  final String? productMaterial;
  final String? productName;
  final String productRatingValue;
  final int? productReviewCount;
  final List<IsmLiveProductReviewModel>? productReviews;
  final String? productSize;
  final String? productSku;
  final String? productURL;
  IsmLiveProductDetailModel({
    this.priceCurrency,
    this.productAvailability,
    this.productBrand,
    this.productColor,
    this.productDescription,
    this.productImage,
    this.productMPN,
    this.productMSRP,
    this.productMaterial,
    this.productName,
    required this.productRatingValue,
    this.productReviewCount,
    this.productReviews,
    this.productSize,
    this.productSku,
    this.productURL,
  });

  IsmLiveProductDetailModel copyWith({
    String? priceCurrency,
    String? productAvailability,
    String? productBrand,
    String? productColor,
    String? productDescription,
    List<String>? productImage,
    String? productMPN,
    String? productMSRP,
    String? productMaterial,
    String? productName,
    String? productRatingValue,
    int? productReviewCount,
    List<IsmLiveProductReviewModel>? productReviews,
    String? productSize,
    String? productSku,
    String? productURL,
  }) =>
      IsmLiveProductDetailModel(
        priceCurrency: priceCurrency ?? this.priceCurrency,
        productAvailability: productAvailability ?? this.productAvailability,
        productBrand: productBrand ?? this.productBrand,
        productColor: productColor ?? this.productColor,
        productDescription: productDescription ?? this.productDescription,
        productImage: productImage ?? this.productImage,
        productMPN: productMPN ?? this.productMPN,
        productMSRP: productMSRP ?? this.productMSRP,
        productMaterial: productMaterial ?? this.productMaterial,
        productName: productName ?? this.productName,
        productRatingValue: productRatingValue ?? this.productRatingValue,
        productReviewCount: productReviewCount ?? this.productReviewCount,
        productReviews: productReviews ?? this.productReviews,
        productSize: productSize ?? this.productSize,
        productSku: productSku ?? this.productSku,
        productURL: productURL ?? this.productURL,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'priceCurrency': priceCurrency,
        'productAvailability': productAvailability,
        'productBrand': productBrand,
        'productColor': productColor,
        'productDescription': productDescription,
        'productImage': productImage,
        'productMPN': productMPN,
        'productMSRP': productMSRP,
        'productMaterial': productMaterial,
        'productName': productName,
        'productRatingValue': productRatingValue,
        'productReviewCount': productReviewCount,
        'productReviews': productReviews,
        'productSize': productSize,
        'productSku': productSku,
        'productURL': productURL,
      };

  factory IsmLiveProductDetailModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveProductDetailModel(
        priceCurrency: map['priceCurrency'] != null
            ? map['priceCurrency'] as String
            : null,
        productAvailability: map['productAvailability'] != null
            ? map['productAvailability'] as String
            : null,
        productBrand:
            map['productBrand'] != null ? map['productBrand'] as String : null,
        productColor:
            map['productColor'] != null ? map['productColor'] as String : null,
        productDescription: map['productDescription'] != null
            ? map['productDescription'] as String
            : null,
        productImage: map['productImage'] != null
            ? List<String>.from(map['productImage'] as List<String>)
            : null,
        productMPN:
            map['productMPN'] != null ? map['productMPN'] as String : null,
        productMSRP:
            map['productMSRP'] != null ? map['productMSRP'] as String : null,
        productMaterial: map['productMaterial'] != null
            ? map['productMaterial'] as String
            : null,
        productName:
            map['productName'] != null ? map['productName'] as String : null,
        productRatingValue: map['productRatingValue'] as String,
        productReviewCount: map['productReviewCount'] != null
            ? map['productReviewCount'] as int
            : null,
        productReviews: map['productReviews'] != null
            ? List<IsmLiveProductReviewModel>.from(
                (map['productReviews'] as List<IsmLiveProductReviewModel>)
                    .map<IsmLiveProductReviewModel?>(
                  (x) => IsmLiveProductReviewModel.fromMap(
                      x as Map<String, dynamic>),
                ),
              )
            : null,
        productSize:
            map['productSize'] != null ? map['productSize'] as String : null,
        productSku:
            map['productSku'] != null ? map['productSku'] as String : null,
        productURL:
            map['productURL'] != null ? map['productURL'] as String : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveProductDetailModel.fromJson(String source) =>
      IsmLiveProductDetailModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveProductModel(priceCurrency: $priceCurrency, productAvailability: $productAvailability, productBrand: $productBrand, productColor: $productColor, productDescription: $productDescription, productImage: $productImage, productMPN: $productMPN, productMSRP: $productMSRP, productMaterial: $productMaterial, productName: $productName, productRatingValue: $productRatingValue, productReviewCount: $productReviewCount, productReviews: $productReviews, productSize: $productSize, productSku: $productSku, productURL: $productURL)';

  @override
  bool operator ==(covariant IsmLiveProductDetailModel other) {
    if (identical(this, other)) return true;

    return other.priceCurrency == priceCurrency &&
        other.productAvailability == productAvailability &&
        other.productBrand == productBrand &&
        other.productColor == productColor &&
        other.productDescription == productDescription &&
        listEquals(other.productImage, productImage) &&
        other.productMPN == productMPN &&
        other.productMSRP == productMSRP &&
        other.productMaterial == productMaterial &&
        other.productName == productName &&
        other.productRatingValue == productRatingValue &&
        other.productReviewCount == productReviewCount &&
        listEquals(other.productReviews, productReviews) &&
        other.productSize == productSize &&
        other.productSku == productSku &&
        other.productURL == productURL;
  }

  @override
  int get hashCode =>
      priceCurrency.hashCode ^
      productAvailability.hashCode ^
      productBrand.hashCode ^
      productColor.hashCode ^
      productDescription.hashCode ^
      productImage.hashCode ^
      productMPN.hashCode ^
      productMSRP.hashCode ^
      productMaterial.hashCode ^
      productName.hashCode ^
      productRatingValue.hashCode ^
      productReviewCount.hashCode ^
      productReviews.hashCode ^
      productSize.hashCode ^
      productSku.hashCode ^
      productURL.hashCode;
}

class IsmLiveProductReviewModel {
  final String? author;
  final String? datePublished;
  final int? ratingValue;
  final String? reviewBody;
  IsmLiveProductReviewModel({
    this.author,
    this.datePublished,
    this.ratingValue,
    this.reviewBody,
  });

  IsmLiveProductReviewModel copyWith({
    String? author,
    String? datePublished,
    int? ratingValue,
    String? reviewBody,
  }) =>
      IsmLiveProductReviewModel(
        author: author ?? this.author,
        datePublished: datePublished ?? this.datePublished,
        ratingValue: ratingValue ?? this.ratingValue,
        reviewBody: reviewBody ?? this.reviewBody,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'author': author,
        'datePublished': datePublished,
        'ratingValue': ratingValue,
        'reviewBody': reviewBody,
      };

  factory IsmLiveProductReviewModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveProductReviewModel(
        author: map['author'] != null ? map['author'] as String : null,
        datePublished: map['datePublished'] != null
            ? map['datePublished'] as String
            : null,
        ratingValue:
            map['ratingValue'] != null ? map['ratingValue'] as int : null,
        reviewBody:
            map['reviewBody'] != null ? map['reviewBody'] as String : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveProductReviewModel.fromJson(String source) =>
      IsmLiveProductReviewModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveProductReviewModel(author: $author, datePublished: $datePublished, ratingValue: $ratingValue, reviewBody: $reviewBody)';

  @override
  bool operator ==(covariant IsmLiveProductReviewModel other) {
    if (identical(this, other)) return true;

    return other.author == author &&
        other.datePublished == datePublished &&
        other.ratingValue == ratingValue &&
        other.reviewBody == reviewBody;
  }

  @override
  int get hashCode =>
      author.hashCode ^
      datePublished.hashCode ^
      ratingValue.hashCode ^
      reviewBody.hashCode;
}
