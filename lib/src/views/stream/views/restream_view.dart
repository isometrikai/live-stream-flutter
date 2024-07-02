import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveRestreamView extends StatelessWidget {
  const IsmLiveRestreamView({super.key});

  static const String route = IsmLiveRoutes.restreamView;

  static const String updateId = 'ism-restream-view';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Restream Channel',
            style: context.textTheme.titleMedium,
          ),
          centerTitle: true,
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
                  padding: IsmLiveDimens.edgeInsets4,
                  child: IsmLiveRadioListTile(
                    title: 'Restream on ${type.label}',
                    isDark: false,
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
