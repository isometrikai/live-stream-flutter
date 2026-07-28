import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveVideoEffectsSheet extends StatelessWidget {
  const IsmLiveVideoEffectsSheet({super.key});

  static const String updateId = 'ism-live-video-effects-sheet';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textIconColor = isDarkMode ? Colors.white : Colors.black;
    final presets = IsmLiveVideoEffectPreset.values;

    return GetBuilder<IsmLiveStreamController>(
      id: updateId,
      builder: (controller) {
        final isApplying = controller.isApplyingVideoEffect;
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
          child: Padding(
            padding: IsmLiveDimens.edgeInsets16_0_16_20.copyWith(bottom: 0),
            child: IsmLiveScrollSheet(
              separatedWidgat: IsmLiveDimens.boxHeight16,
              title: 'Video Effects',
              showHeader: false,
              showCancelIcon: true,
              cancelIconColor: textIconColor,
              itemCount: presets.length,
              itemBuilder: (context, index) {
                final preset = presets[index];
                final isSelected =
                    controller.selectedVideoEffectPreset == preset;
                return Opacity(
                  opacity: isApplying && !isSelected ? 0.45 : 1,
                  child: IsmLiveTapHandler(
                    onTap: isApplying
                        ? null
                        : () => controller.selectVideoEffectPreset(preset),
                    child: Row(
                      children: [
                        Icon(
                          controller.iconForVideoEffectPreset(preset),
                          color: textIconColor,
                          size: IsmLiveDimens.twentyFour,
                        ),
                        IsmLiveDimens.boxWidth10,
                        Expanded(
                          child: Text(
                            controller.labelForVideoEffectPreset(preset),
                            style:
                                context.dynamicTextTheme.bodyMedium?.copyWith(
                              color: textIconColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isSelected && isApplying)
                          SizedBox(
                            width: IsmLiveDimens.twentyFour,
                            height: IsmLiveDimens.twentyFour,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        else if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: context.theme.primaryColor,
                            size: IsmLiveDimens.twentyFour,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
