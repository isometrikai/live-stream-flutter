import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkViewersSheet extends StatelessWidget {
  const IsmLivePkViewersSheet({super.key});

  static const String updateId = 'pk-viewers-sheet';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
      id: updateId,
      initState: (state) {},
      builder: (controller) => Padding(
            padding: IsmLiveDimens.edgeInsetsT16,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IsmLiveDimens.boxHeight16,
                  Text(
                    '     Viewers',
                    style: IsmLiveStyles.blackBold20,
                  ),
                  IsmLiveDimens.boxHeight10,
                  GetX<IsmLiveStreamController>(
                    initState: (state) {},
                    builder: (controller) => TabBar(
                      dividerHeight: 0,
                      indicatorColor: Colors.transparent,
                      labelPadding: IsmLiveDimens.edgeInsets8_0,
                      overlayColor:
                          WidgetStateProperty.all(Colors.transparent),
                      controller: controller.pkTabController,
                      onTap: (index) {
                        controller.pkViewers = IsmLivePkViewers.values[index];
                      },
                      tabs: IsmLivePkViewers.values.map(
                        (type) {
                          var isSelected = (type == controller.pkViewers);

                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors
                                      .black //context.liveTheme?.primaryColor
                                  : Colors.grey.shade100,
                              borderRadius:
                                  BorderRadius.circular(IsmLiveDimens.eighty),
                            ),
                            child: Padding(
                              padding: IsmLiveDimens.edgeInsets16_10,
                              child: Text(
                                type.label,
                                style: context.textTheme.titleSmall?.copyWith(
                                    color: isSelected
                                        ? IsmLiveColors
                                            .white //context.liveTheme?.selectedTextColor
                                        : IsmLiveColors
                                            .grey //context.liveTheme?.unselectedTextColor,
                                    ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.4,
                    child: GetBuilder<IsmLiveStreamController>(
                      id: updateId,
                      builder: (controller) => TabBarView(
                        controller: controller.pkViewersTabController,
                        children: [
                          IsmLiveScrollSheet(
                            showSearchBar: false,
                            showHeader: false,
                            title: '',
                            placeHolderText: 'no data found',
                            itemCount: 5,
                            itemBuilder: (context, index) => ListTile(
                              leading: IsmLiveImage.network(
                                '',
                                name: '@tayne22',
                                dimensions: IsmLiveDimens.forty,
                                isProfileImage: true,
                              ),
                              title: const Text('@tayne22'),
                              subtitle: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.remove_red_eye),
                                  Text('123'),
                                ],
                              ),
                            ),
                          ),
                          IsmLiveScrollSheet(
                            placeHolderText: 'No data found',
                            showHeader: false,
                            title: '',
                            itemCount: 5,
                            itemBuilder: (context, index) => ListTile(
                              leading: IsmLiveImage.network(
                                '',
                                name: '@tayne22',
                                dimensions: IsmLiveDimens.forty,
                                isProfileImage: true,
                              ),
                              title: const Text('@tayne22'),
                              subtitle: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.remove_red_eye),
                                  Text('123'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
}
