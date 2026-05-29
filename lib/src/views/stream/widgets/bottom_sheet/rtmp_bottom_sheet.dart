import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class IsmLiveRtmpSheet extends StatelessWidget {
  const IsmLiveRtmpSheet();

  static Color _textOnBackground(Color background) =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark
          ? Colors.white
          : Colors.black;

  static Color _subtitleOnBackground(Color background) {
    final onDark =
        ThemeData.estimateBrightnessForColor(background) == Brightness.dark;
    return onDark ? const Color(0xFFB0B0B0) : (Colors.grey[600] ?? Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final sheetBackground = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final textColor = _textOnBackground(sheetBackground);
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        _subtitleOnBackground(sheetBackground);

    return Container(
      decoration: BoxDecoration(
        color: sheetBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                IsmLiveDimens.thirty,
          ),
        ),
      ),
      child: GetBuilder<IsmLiveStreamController>(
        id: IsmGoLiveView.updateId,
        builder: (controller) => Padding(
          padding: IsmLiveDimens.edgeInsets16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InputField(
                label: IsmLiveStrings.rtmlUrl,
                readOnly: true,
                controller: controller.rtmlUrlDevice,
                sheetBackground: sheetBackground,
                textColor: textColor,
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: controller.rtmlUrlDevice.text),
                  );
                },
              ),
              IsmLiveDimens.boxHeight10,
              _InputField(
                label: IsmLiveStrings.streamKey,
                hint: IsmLiveStrings.streamKeyHint,
                readOnly: true,
                controller: controller.streamKeyDevice,
                sheetBackground: sheetBackground,
                textColor: textColor,
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: controller.streamKeyDevice.text),
                  );
                },
              ),
              IsmLiveDimens.boxHeight10,
              Text.rich(
                const TextSpan(
                  text: IsmLiveStrings.rtmpStreamInstruction,
                ),
                style: context.textTheme.labelMedium?.copyWith(
                  color: subtitleColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.sheetBackground,
    required this.textColor,
    this.hint,
    required this.controller,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final Color sheetBackground;
  final Color textColor;
  final String? hint;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onDarkSheet =
        ThemeData.estimateBrightnessForColor(sheetBackground) ==
            Brightness.dark;
    final borderColor = context.liveTheme?.borderColor ??
        (onDarkSheet ? const Color(0xFF1E1E1E) : IsmLiveColors.black);
    final fillColor = context.liveTheme?.cardBackgroundColor ??
        (onDarkSheet ? const Color(0xFF1E1E1E) : Colors.white);
    final hintColor = context.liveTheme?.unselectedTextColor ??
        IsmLiveRtmpSheet._subtitleOnBackground(sheetBackground);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            color: textColor,
          ),
        ),
        IsmLiveDimens.boxHeight4,
        IsmLiveInputField(
          controller: controller,
          hintText: hint ?? 'Enter $label',
          hintStyle: context.textTheme.labelLarge?.copyWith(
            color: hintColor,
          ),
          style: context.textTheme.labelLarge?.copyWith(
            color: textColor,
          ),
          onTap: onTap,
          readOnly: readOnly,
          fillColor: fillColor,
          radius: IsmLiveDimens.twelve,
          borderColor: borderColor,
          suffixIcon: Icon(
            Icons.copy,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
