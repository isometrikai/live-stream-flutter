import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Default Go Live button widget (lines 15-120 of original IsmGoLiveNavBar)
class _DefaultGoLiveButton extends StatelessWidget {
  const _DefaultGoLiveButton({
    required this.onGoLivePressed,
    required this.isEnabled,
  });

  final VoidCallback onGoLivePressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16_0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isEnabled
                ? IsmLiveColors.red
                : IsmLiveColors.red.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(IsmLiveDimens.twentyFive),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: IsmLiveDimens.edgeInsets4,
                child: Text(
                  'Broadcasters under 18 are not permitted',
                  style: context.dynamicTextTheme.bodySmall?.copyWith(
                    color: isEnabled ? Colors.white : Colors.white70,
                  ),
                ),
              ),
              IsmLiveButton(
                label: 'Go Live',
                showBorder: true,
                onTap: isEnabled ? onGoLivePressed : null,
              ),
            ],
          ),
        ),
      );
}

/// Tab selector widget (lines 121-173 of original IsmGoLiveNavBar)
class _GoLiveTabSelector extends StatelessWidget {
  const _GoLiveTabSelector();

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmGoLiveView.updateId,
        builder: (controller) => (!(controller
                        .streamDetails?.isScheduledStream ??
                    false) &&
                (IsmLiveDelegate.multiLiveStream ?? true))
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: IsmGoLiveTabItem.values.map((e) {
                  final isSelected = controller.selectedGoLiveTabItem == e;
                  return Expanded(
                    child: IsmLiveTapHandler(
                      onTap: () {
                        controller.selectedGoLiveTabItem = e;

                        controller.onChangeRtmp(
                            controller.selectedGoLiveTabItem ==
                                IsmGoLiveTabItem.liveFromDevice);
                        controller.onChangePersistent(false);

                        // Update both IDs: updateId for general UI, cameraUpdateId for camera preview visibility
                        controller.update([
                          IsmGoLiveView.updateId,
                          IsmGoLiveView.cameraUpdateId,
                        ]);
                      },
                      child: Padding(
                        padding: IsmLiveDimens.edgeInsets0_4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              e.label,
                              style: (isSelected
                                      ? IsmLiveDelegate.goLiveScreenConfigure
                                          ?.tabSelectedTextStyle
                                      : IsmLiveDelegate.goLiveScreenConfigure
                                          ?.tabUnselectedTextStyle) ??
                                  context.dynamicTextTheme.labelLarge?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white54,
                                  ),
                            ),
                            if (isSelected) ...[
                              IsmLiveDimens.boxHeight4,
                              Container(
                                height: 2,
                                width: MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
            : const SizedBox.shrink(),
      );
}

/// Complete navigation bar that combines Go Live button and tab selector
class IsmGoLiveNavBar extends StatelessWidget {
  const IsmGoLiveNavBar({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: GetBuilder<IsmLiveStreamController>(
          id: IsmGoLiveView.buttonUpdateId,
          builder: (controller) {
            final isEnabled = controller.isGoLiveButtonEnabled;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Use custom Go Live button builder if provided, otherwise use default
                IsmLiveDelegate.goLiveScreenConfigure?.goLiveButtonBuilder?.call(
                      context,
                      controller,
                      () => controller.handleGoLivePress(context),
                      isEnabled,
                    ) ??
                    _DefaultGoLiveButton(
                      onGoLivePressed: () =>
                          controller.handleGoLivePress(context),
                      isEnabled: isEnabled,
                    ),
                const Divider(),
                // Tab selector (always use default implementation)
                const _GoLiveTabSelector(),
              ],
            );
          },
        ),
      );
}
