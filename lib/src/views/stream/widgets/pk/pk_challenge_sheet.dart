import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkChallengeSheet extends StatelessWidget {
  const IsmLivePkChallengeSheet({super.key});

  static const List<String> _durations = ['1', '3', '5', '10'];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final titleColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);

    final selectedBorderColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final chipBg = context.liveTheme?.cardBackgroundColor ??
        (isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade100);

    final infoBg = Colors.green.withValues(alpha: isDarkMode ? 0.18 : 0.12);
    final infoTextColor = Colors.green;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                IsmLiveDimens.thirty,
          ),
        ),
      ),
      child: Padding(
        padding: IsmLiveDimens.edgeInsets16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IsmLiveDimens.boxHeight10,
            Text(
              IsmLiveStrings.pkChallengeSettings,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            IsmLiveDimens.boxHeight2,
            Text(
              IsmLiveStrings.pkChallengeSettingsDescription,
              style: context.textTheme.bodySmall?.copyWith(
                color: subtitleColor,
              ),
            ),
            IsmLiveDimens.boxHeight20,
            Container(
              decoration: BoxDecoration(
                color: infoBg,
                borderRadius: BorderRadius.circular(IsmLiveDimens.eight),
              ),
              child: ListTile(
                leading: IsmLiveImage.svg(
                  IsmLiveAssetConstants.cup,
                  color: infoTextColor,
                ),
                title: Text(
                  IsmLiveStrings.winnerTakesAll,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: infoTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  IsmLiveStrings.winnerTakesAllDescription,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: subtitleColor,
                  ),
                ),
              ),
            ),
            IsmLiveDimens.boxHeight32,
            Text(
              IsmLiveStrings.choosePkChallengeDuration,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            IsmLiveDimens.boxHeight20,
            SizedBox(
              height: IsmLiveDimens.thirty,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _durations.length,
                itemBuilder: (context, index) {
                  final time = _durations[index];
                  return GetX<IsmLivePkController>(
                    builder: (controller) {
                      final isSelected = controller.pkSelectTime == time;
                      final selectedBg =
                          selectedBorderColor.withValues(alpha: 0.12);
                      final effectiveBg = isSelected ? selectedBg : chipBg;
                      final chipTextColor = isSelected
                          ? selectedBorderColor
                          : Colors.black;

                      return IsmLiveTapHandler(
                        onTap: () {
                          controller.pkSelectTime = time;
                        },
                        child: Container(
                          margin: IsmLiveDimens.edgeInsets10_0,
                          width: IsmLiveDimens.seventy,
                          decoration: BoxDecoration(
                            color: effectiveBg,
                            border: isSelected
                                ? Border.all(color: selectedBorderColor)
                                : null,
                            borderRadius:
                                BorderRadius.circular(IsmLiveDimens.fifty),
                          ),
                          child: Center(
                            child: Text(
                              '$time ${IsmLiveStrings.minShort}',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: chipTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            IsmLiveDimens.boxHeight32,
            IsmLiveButton(
              label: IsmLiveStrings.confirmAndStart,
              small: true,
              onTap: Get.find<IsmLivePkController>().startPkBattle,
            ),
          ],
        ),
      ),
    );
  }
}
