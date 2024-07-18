import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class IsmLiveRtmpSheet extends StatelessWidget {
  const IsmLiveRtmpSheet();

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmGoLiveView.updateId,
        builder: (controller) => Padding(
          padding: IsmLiveDimens.edgeInsets16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InputField(
                label: 'RTML URL',
                readOnly: true,
                controller: controller.rtmlUrlDevice,
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: controller.rtmlUrlDevice.text),
                  );
                },
                suffixIcon: const Icon(Icons.copy),
              ),
              IsmLiveDimens.boxHeight10,
              _InputField(
                label: 'Stream Key',
                hint: 'Key will be generated after you start a new stream',
                readOnly: true,
                controller: controller.streamKeyDevice,
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: controller.streamKeyDevice.text),
                  );
                },
                suffixIcon: const Icon(Icons.copy),
              ),
              IsmLiveDimens.boxHeight10,
              Text.rich(
                const TextSpan(
                  text:
                      'Please copy and paste the STREAM KEY and the STREAM URL into your RTMP streaming device.',
                ),
                style: context.textTheme.labelMedium?.copyWith(
                  color: IsmLiveColors.black,
                ),
              )
            ],
          ),
        ),
      );
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    this.hint,
    required this.controller,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool readOnly;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: IsmLiveColors.black,
            ),
          ),
          IsmLiveDimens.boxHeight4,
          IsmLiveInputField(
            controller: controller,
            hintText: hint ?? 'Enter $label',
            hintStyle: context.textTheme.labelLarge?.copyWith(
              color: IsmLiveColors.black,
            ),
            style: context.textTheme.labelLarge?.copyWith(
              color: IsmLiveColors.black,
            ),
            onTap: onTap,
            readOnly: readOnly,
            fillColor: Colors.white,
            radius: IsmLiveDimens.twelve,
            borderColor: IsmLiveColors.black,
            suffixIcon: suffixIcon,
          ),
        ],
      );
}
