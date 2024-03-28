import 'dart:convert';

class IsmLiveProductModel {
  IsmLiveProductModel({
    required this.productName,
    required this.productId,
    required this.metadata,
    this.externalProductId,
    this.count,
  });

  factory IsmLiveProductModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveProductModel(
        productName: map['productName'] as String,
        productId: map['productId'] as String,
        metadata: IsmLiveProductMetaData.fromMap(
            map['metadata'] as Map<String, dynamic>),
        externalProductId: map['externalProductId'] != null
            ? map['externalProductId'] as String
            : null,
        count: map['count'] != null ? map['count'] as num : null,
      );

  factory IsmLiveProductModel.fromJson(String source) =>
      IsmLiveProductModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final String productName;
  final String productId;
  final IsmLiveProductMetaData metadata;
  final String? externalProductId;
  final num? count;

  IsmLiveProductModel copyWith({
    String? productName,
    String? productId,
    IsmLiveProductMetaData? metadata,
    String? externalProductId,
    num? count,
  }) =>
      IsmLiveProductModel(
        productName: productName ?? this.productName,
        productId: productId ?? this.productId,
        metadata: metadata ?? this.metadata,
        externalProductId: externalProductId ?? this.externalProductId,
        count: count ?? this.count,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'productName': productName,
        'productId': productId,
        'metadata': metadata.toMap(),
        'externalProductId': externalProductId,
        'count': count,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveProductModel(productName: $productName, productId: $productId, metadata: $metadata, externalProductId: $externalProductId, count: $count)';

  @override
  bool operator ==(covariant IsmLiveProductModel other) {
    if (identical(this, other)) return true;

    return other.productName == productName &&
        other.productId == productId &&
        other.metadata == metadata &&
        other.externalProductId == externalProductId &&
        other.count == count;
  }

  @override
  int get hashCode =>
      productName.hashCode ^
      productId.hashCode ^
      metadata.hashCode ^
      externalProductId.hashCode ^
      count.hashCode;
}

class IsmLiveProductMetaData {
  IsmLiveProductMetaData({
    this.price,
    this.description,
    this.currencySymbol,
    this.category,
    this.productImageUrl,
  });

  factory IsmLiveProductMetaData.fromMap(Map<String, dynamic> map) =>
      IsmLiveProductMetaData(
        price: map['price'] != null ? map['price'] as num : null,
        description:
            map['description'] != null ? map['description'] as String : null,
        currencySymbol: map['currencySymbol'] != null
            ? map['currencySymbol'] as String
            : null,
        category: map['category'] != null ? map['category'] as String : null,
        productImageUrl: map['productImageUrl'] != null
            ? map['productImageUrl'] as String
            : null,
      );

  factory IsmLiveProductMetaData.fromJson(String source) =>
      IsmLiveProductMetaData.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final num? price;
  final String? description;
  final String? currencySymbol;
  final String? category;
  final String? productImageUrl;

  IsmLiveProductMetaData copyWith({
    num? price,
    String? description,
    String? currencySymbol,
    String? category,
    String? productImageUrl,
  }) =>
      IsmLiveProductMetaData(
        price: price ?? this.price,
        description: description ?? this.description,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        category: category ?? this.category,
        productImageUrl: productImageUrl ?? this.productImageUrl,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'price': price,
        'description': description,
        'currencySymbol': currencySymbol,
        'category': category,
        'productImageUrl': productImageUrl,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveProductMetaData(price: $price, description: $description, currencySymbol: $currencySymbol, category: $category, productImageUrl: $productImageUrl)';

  @override
  bool operator ==(covariant IsmLiveProductMetaData other) {
    if (identical(this, other)) return true;

    return other.price == price &&
        other.description == description &&
        other.currencySymbol == currencySymbol &&
        other.category == category &&
        other.productImageUrl == productImageUrl;
  }

  @override
  int get hashCode =>
      price.hashCode ^
      description.hashCode ^
      currencySymbol.hashCode ^
      category.hashCode ^
      productImageUrl.hashCode;
}
