import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Bottom sheet for selecting a DeepAR face filter during a live publish.
class IsmLiveVideoEffectsSheet extends StatelessWidget {
  const IsmLiveVideoEffectsSheet({super.key});

  static const String updateId = 'ism-live-video-effects-sheet';

  static Future<void> show(BuildContext context) {
    final config = IsmLiveDelegate.deepArConfig;
    final registered = Get.isRegistered<IsmLiveStreamController>();
    final publisher = registered
        ? Get.find<IsmLiveStreamController>().deepArPublisher
        : null;
    final licensePresent = config.licenseKeyForPlatform?.isNotEmpty == true;
    IsmLiveLog.info(
      'DeepAR effects sheet open controller=$registered '
      'active=${config.isActive} enabled=${config.enabled} '
      'licensePresent=$licensePresent effects=${config.effects.length} '
      'publisher=${publisher == null ? 'null' : 'started=${publisher.isStarted}'}',
    );
    if (!config.isActive) {
      IsmLiveLog.error(
        'DeepAR effects sheet is empty: enabled=${config.enabled} '
        'licensePresent=$licensePresent',
      );
    } else if (publisher == null || !publisher.isStarted) {
      IsmLiveLog.error(
        'DeepAR effects sheet opened but publisher is not running '
        '(publisher=${publisher == null ? 'null' : 'started=false'}). '
        'Taps will not change the live video.',
      );
    }
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const IsmLiveVideoEffectsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = IsmLiveDelegate.deepArConfig;
    if (!config.isActive) {
      return const SizedBox.shrink();
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: context.liveTheme?.backgroundColor ??
            (isDarkMode ? const Color(0xFF121212) : Colors.white),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                IsmLiveDimens.thirty,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: GetBuilder<IsmLiveStreamController>(
            id: updateId,
            builder: (controller) {
              final effects = config.effects;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 104,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: effects.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final effect = effects[index];
                        final selected =
                            controller.selectedDeepArEffectId == effect.id;
                        return GestureDetector(
                          onTap: () async {
                            controller.selectedDeepArEffectId = effect.id;
                            controller.update([updateId]);
                            final publisher = controller.deepArPublisher;
                            IsmLiveLog.info(
                              'DeepAR effect tap id=${effect.id} '
                              'path=${effect.assetPath ?? 'none'} '
                              'publisher=${publisher == null ? 'null' : 'started=${publisher.isStarted}'}',
                            );
                            if (publisher == null) {
                              IsmLiveLog.error(
                                'DeepAR effect tap ignored: deepArPublisher is null',
                              );
                              return;
                            }
                            try {
                              await publisher.applyEffect(effect);
                            } catch (e, st) {
                              IsmLiveLog.error(
                                'DeepAR effect tap failed id=${effect.id}: $e',
                                st,
                              );
                            }
                          },
                          child: SizedBox(
                            width: 72,
                            child: Column(
                              children: [
                                _EffectThumb(
                                  effect: effect,
                                  selected: selected,
                                  primary:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  effect.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EffectThumb extends StatelessWidget {
  const _EffectThumb({
    required this.effect,
    required this.selected,
    required this.primary,
  });

  final IsmLiveDeepArEffect effect;
  final bool selected;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? primary : Colors.white24,
          width: selected ? 2.5 : 1,
        ),
      ),
      child: ClipOval(
        child: ColoredBox(
          color: Colors.black26,
          child: effect.isNone
              ? const Icon(Icons.block, size: 28)
              : _buildPreview(),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final path = effect.thumbnailAssetPath;
    if (path == null || path.isEmpty) {
      return Center(
        child: Text(
          effect.name.characters.first.toUpperCase(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: 64,
      height: 64,
      errorBuilder: (_, __, ___) => Center(
        child: Text(
          effect.name.characters.first.toUpperCase(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
