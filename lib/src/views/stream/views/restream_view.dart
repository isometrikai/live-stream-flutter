import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/res/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveRestreamView extends StatelessWidget {
  const IsmLiveRestreamView({super.key});

  static const String route = IsmLiveRoutes.restreamView;

  static const String updateId = 'ism-restream-view';

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
          IsmLiveStrings.restreamChannel,
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
        initState: (_) {
          Get.find<IsmLiveStreamController>().getRestreamChannels();
        },
        builder: (controller) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...IsmLiveRestreamType.values.map<Widget>(
              (type) => Padding(
                padding: IsmLiveDimens.edgeInsets16_8,
                child: IsmLiveRadioListTile(
                  title: '${IsmLiveStrings.restreamOn} ${type.label}',
                  isDark: isDarkMode,
                  showIcon: true,
                  onChange: (value) =>
                      controller.onTapRestreamType(type, value),
                  value: controller.isRestreamType(type),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
