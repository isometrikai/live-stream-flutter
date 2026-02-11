import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/res/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveRestreamSettingsView extends StatelessWidget {
  const IsmLiveRestreamSettingsView({super.key, required this.type});

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
                
                // Find existing channel matching the type, if any
                final existingChannel = contr.restreamChannels
                    .cast<dynamic>()
                    .firstWhere(
                      (element) => element.channelType == type.value,
                      orElse: () => null,
                    );
                
                contr.onSaveRestreamSettings(
                  channelName: type.label,
                  channeltype: type.value,
                  enable: contr.isRestreamType(type),
                  channelId: existingChannel?.channelId,
                );
              }),
        ),
        body: GetBuilder<IsmLiveStreamController>(
          id: updateId,
          initState: (state) {
            var contr = Get.find<IsmLiveStreamController>();
            
            // Find existing channel matching the type
            final existingChannel = contr.restreamChannels
                .cast<dynamic>()
                .firstWhere(
                  (element) => element.channelType == type.value,
                  orElse: () => null,
                );
            
            if (existingChannel != null) {
              var lastSlashIndex = existingChannel.ingestUrl?.lastIndexOf('/') ?? 0;

              contr.rtmlUrl.text =
                  existingChannel.ingestUrl?.substring(0, lastSlashIndex) ?? '';
              contr.streamKey.text =
                  existingChannel.ingestUrl?.substring(lastSlashIndex + 1) ?? '';
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
