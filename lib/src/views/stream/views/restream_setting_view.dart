import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveRestreamSettingsView extends StatelessWidget {
  IsmLiveRestreamSettingsView({super.key}) : type = Get.arguments;

  final IsmLiveRestreamType type;

  static const String route = IsmLiveRoutes.restreamSettingsView;

  static const String updateId = 'ism-restream-settings-view';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            type.label,
            style: context.textTheme.titleMedium,
          ),
          centerTitle: true,
        ),
        bottomNavigationBar: Padding(
          padding: IsmLiveDimens.edgeInsets16,
          child: IsmLiveButton(
              label: 'Save',
              onTap: () {
                var contr = Get.find<IsmLiveStreamController>();
                contr.onSaveRestreamSettings(
                    channelName: type.label,
                    channeltype: type.value,
                    enable: contr.isRestreamType(type),
                    channelId: contr.restreamChannels.isEmpty
                        ? null
                        : contr.restreamChannels
                            .firstWhere(
                              (element) => element.channelType == type.value,
                            )
                            .channelId);
              }),
        ),
        body: GetBuilder<IsmLiveStreamController>(
          id: updateId,
          initState: (state) {
            var contr = Get.find<IsmLiveStreamController>();
            if (contr.restreamChannels.any(
              (element) => element.channelType == type.value,
            )) {
              var a = contr.restreamChannels.firstWhere(
                (element) => element.channelType == type.value,
              );

              var lastSlashIndex = a.ingestUrl?.lastIndexOf('/') ?? 0;

              contr.rtmlUrl.text =
                  a.ingestUrl?.substring(0, lastSlashIndex) ?? '';
              contr.streamKey.text =
                  a.ingestUrl?.substring(lastSlashIndex + 1) ?? '';
            } else {
              contr.rtmlUrl.clear();
              contr.streamKey.clear();
            }
          },
          builder: (controller) => Padding(
            padding: IsmLiveDimens.edgeInsets16_8,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IsmLiveRestreamLinkTile(type),
                  IsmLiveDimens.boxHeight10,
                  IsmLiveRadioListTile(
                    title: 'Enable stream on ${type.label}',
                    isDark: false,
                    onChange: (value) =>
                        controller.onChangeRestreamType(type, value),
                    value: controller.isRestreamType(type),
                  ),
                  IsmLiveDimens.boxHeight8,
                  if (controller.isRestreamType(type)) ...[
                    _InputField(
                      label: 'RTML URL',
                      controller: controller.rtmlUrl,
                    ),
                    IsmLiveDimens.boxHeight16,
                    _InputField(
                      label: 'Stream key',
                      controller: controller.streamKey,
                    ),
                    IsmLiveDimens.boxHeight8,
                    Text.rich(
                      TextSpan(
                        text:
                            'You have to enter the youtube stream url here,\n',
                        children: [
                          TextSpan(
                            text: 'click here to know more.',
                            style:
                                const TextStyle().copyWith(color: Colors.blue),
                          ),
                        ],
                      ),
                      style: context.textTheme.labelMedium,
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      );
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.liveTheme?.unselectedTextColor,
            ),
          ),
          IsmLiveDimens.boxHeight4,
          IsmLiveInputField(
            controller: controller,
            hintText: 'Enter $label',
            radius: IsmLiveDimens.twelve,
            borderColor: context.liveTheme?.unselectedTextColor,
            hintStyle: context.textTheme.labelLarge?.copyWith(
              color: context.liveTheme?.unselectedTextColor,
            ),
          ),
        ],
      );
}
