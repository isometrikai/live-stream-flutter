part of '../live_delegate.dart';

class IsmLiveEcomConfigure {
  IsmLiveEcomConfigure({
    this.addProductViewBuilder,
    this.pinnedProductBuilder,
    this.hasPinnedProductGetter,
    this.buyNowButtonBuilder,
    this.hostArrowButtonsBuilder,
    this.hostArrowButtonsSize,
    this.pinItemCallback,
    this.buyNowCallback,
  });

  final AddProductViewBuilder? addProductViewBuilder;
  final Widget? Function(
          BuildContext context, IsmLiveStreamController controller)?
      pinnedProductBuilder;
  final bool Function()? hasPinnedProductGetter;
  final BuyNowButtonBuilder? buyNowButtonBuilder;
  final HostArrowButtonsBuilder? hostArrowButtonsBuilder;
  final double? hostArrowButtonsSize;
  final PinItemCallback? pinItemCallback;
  final BuyNowCallback? buyNowCallback;

  /// Gets the current pinned product status dynamically
  bool get hasPinnedProduct => hasPinnedProductGetter?.call() ?? false;
}