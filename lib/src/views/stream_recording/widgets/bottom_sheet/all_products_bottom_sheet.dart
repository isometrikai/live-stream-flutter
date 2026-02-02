import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Bottom sheet listing all products for the current stream.
class IsmLiveStreamRecordingAllProductsSheet extends StatefulWidget {
  const IsmLiveStreamRecordingAllProductsSheet({
    super.key,
    required this.products,
    required this.hasMore,
    required this.page,
    required this.onLoadMore,
    required this.config,
    required this.recording,
  });

  final List<IsmLiveStreamRecordingProduct> products;
  final bool hasMore;
  final int page;
  final VoidCallback onLoadMore;
  final IsmLiveStreamRecordingPlayerConfig config;
  final IsmLiveStreamRecordingItem recording;

  @override
  State<IsmLiveStreamRecordingAllProductsSheet> createState() =>
      _IsmLiveStreamRecordingAllProductsSheetState();
}

class _IsmLiveStreamRecordingAllProductsSheetState
    extends State<IsmLiveStreamRecordingAllProductsSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = IsmLiveDelegate.bottomSheetBorderRadius ??
        const BorderRadius.vertical(top: Radius.circular(16));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'All products',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Flexible(
            child: widget.products.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No products',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        widget.products.length + (widget.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == widget.products.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: TextButton(
                              onPressed: widget.onLoadMore,
                              child: const Text('Load more'),
                            ),
                          ),
                        );
                      }
                      final product = widget.products[index];
                      return _ProductTile(
                        product: product,
                        onTap: () {
                          if (widget.config.onShare != null) {
                            widget.config.onShare!(product, widget.recording);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.onTap,
  });

  final IsmLiveStreamRecordingProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.imageUrl!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const SizedBox(
                      width: 72,
                      height: 72,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => const SizedBox(
                      width: 72,
                      height: 72,
                      child: Icon(Icons.image_not_supported),
                    ),
                  )
                : const SizedBox(
                    width: 72,
                    height: 72,
                    child: Icon(Icons.image),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.displayPrice.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.displayPrice,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
