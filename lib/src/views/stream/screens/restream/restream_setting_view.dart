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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.liveTheme?.backgroundColor ??
          (isDarkMode ? const Color(0xFF121212) : Colors.white),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: ismLiveBuildBackButton(
          context,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        backgroundColor: context.liveTheme?.backgroundColor ??
            (isDarkMode ? const Color(0xFF121212) : Colors.white),
        title: Text(
          type.label,
          style: context.textTheme.titleMedium?.copyWith(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (state) {
          var contr = Get.find<IsmLiveStreamController>();

          // Find existing channel matching the type
          final existingChannel =
              contr.restreamChannels.cast<dynamic>().firstWhere(
                    (element) => element.channelType == type.value,
                    orElse: () => null,
                  );

          if (existingChannel != null) {
            var lastSlashIndex =
                existingChannel.ingestUrl?.lastIndexOf('/') ?? 0;

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
                  title: '${IsmLiveStrings.enableStreamOn} ${type.label}',
                  isDark: isDarkMode,
                  onChange: (value) =>
                      controller.onChangeRestreamType(type, value),
                  value: controller.isRestreamType(type),
                ),
                IsmLiveDimens.boxHeight8,
                if (controller.isRestreamType(type)) ...[
                  _InputField(
                    label: IsmLiveStrings.rtmlUrl,
                    controller: controller.rtmlUrl,
                  ),
                  IsmLiveDimens.boxHeight16,
                  _InputField(
                    label: IsmLiveStrings.streamKey,
                    controller: controller.streamKey,
                  ),
                  IsmLiveDimens.boxHeight8,
                  Text.rich(
                    TextSpan(
                      text: IsmLiveStrings.youtubeStreamUrlInstruction,
                      style: TextStyle(
                        color: context.liveTheme?.unselectedTextColor ??
                            (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      children: [
                        TextSpan(
                          text: IsmLiveStrings.clickHereToKnowMore,
                          style: TextStyle(
                            color: context.liveTheme?.primaryColor ??
                                (isDarkMode
                                    ? Colors.lightBlue[300]
                                    : Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.liveTheme?.unselectedTextColor ??
                          (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: context.liveTheme?.backgroundColor ??
            (isDarkMode ? const Color(0xFF121212) : Colors.white),
        padding: IsmLiveDimens.edgeInsets16.copyWith(
          bottom: ismLiveBottomSheetActionBottomInset(
            context,
            designBottom: 16,
          ),
        ),
        child: IsmLiveButton(
          label: IsmLiveStrings.save,
          onTap: () {
            var contr = Get.find<IsmLiveStreamController>();

            // Find existing channel matching the type, if any
            final existingChannel =
                contr.restreamChannels.cast<dynamic>().firstWhere(
                      (element) => element.channelType == type.value,
                      orElse: () => null,
                    );

            contr.onSaveRestreamSettings(
              channelName: type.label,
              channeltype: type.value,
              enable: contr.isRestreamType(type),
              channelId: existingChannel?.channelId,
            );
          },
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hintText = label == IsmLiveStrings.rtmlUrl
        ? IsmLiveStrings.enterRtmlUrl
        : label == IsmLiveStrings.streamKey
            ? IsmLiveStrings.enterStreamKey
            : IsmLiveStrings.enterFieldFormat(label);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.liveTheme?.unselectedTextColor ??
                (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
        IsmLiveDimens.boxHeight4,
        IsmLiveInputField(
          controller: controller,
          hintText: hintText,
          radius: IsmLiveDimens.twelve,
          borderColor: context.liveTheme?.borderColor ??
              (isDarkMode ? const Color(0xFF1E1E1E) : IsmLiveColors.black),
          hintStyle: context.textTheme.labelLarge?.copyWith(
            color: context.liveTheme?.unselectedTextColor ??
                (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
