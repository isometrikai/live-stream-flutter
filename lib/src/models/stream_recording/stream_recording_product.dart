/// SDK-owned product type for the stream recording player.
///
/// Used in the product strip, "All products" sheet, and optional share.
/// The host's onFetchStreamProducts callback returns a list of this type.
class IsmLiveStreamRecordingProduct {
  const IsmLiveStreamRecordingProduct({
    required this.id,
    required this.name,
    this.imageUrl,
    this.price,
    this.formattedPrice,
    this.currency,
    this.deepLink,
    this.description,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final num? price;
  final String? formattedPrice;
  final String? currency;
  final String? deepLink;
  final String? description;

  /// Display price: [formattedPrice] if set, otherwise [price] with [currency].
  String get displayPrice {
    if (formattedPrice != null && formattedPrice!.isNotEmpty) {
      return formattedPrice!;
    }
    if (price != null && currency != null) {
      return '$currency $price';
    }
    if (price != null) return price.toString();
    return '';
  }
}

/// Paginated result from the onFetchStreamProducts callback.
class IsmLiveStreamRecordingProductList {
  const IsmLiveStreamRecordingProductList({
    required this.items,
    this.hasMore = false,
    this.page = 1,
  });

  final List<IsmLiveStreamRecordingProduct> items;
  final bool hasMore;
  final int page;
}
