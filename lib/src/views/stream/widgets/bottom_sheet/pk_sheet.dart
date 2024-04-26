import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkSheet extends StatelessWidget {
  const IsmLivePkSheet({super.key});

  static const String updateId = 'stream-pk-sheet';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
      id: updateId,
      initState: (state) {
        Get.find<IsmLiveStreamController>().getUsersToInviteForPK();
      },
      builder: (controller) => Padding(
            padding: IsmLiveDimens.edgeInsetsT16,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IsmLiveDimens.boxHeight16,
                  Text(
                    '     PK With Friends',
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
                          MaterialStateProperty.all(Colors.transparent),
                      controller: controller.pkTabController,
                      onTap: (index) {
                        controller.pk = IsmLivePk.values[index];
                      },
                      tabs: IsmLivePk.values.map(
                        (type) {
                          var isSelected = (type == controller.pk);

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
                        controller: controller.pkTabController,
                        children: [
                          IsmLiveScrollSheet(
                            showSearchBar: true,
                            onPressClearIcon: () {},
                            showHeader: false,
                            textEditingController: TextEditingController(),
                            hintText: 'search',
                            onchange: (value) {},
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
                              trailing: SizedBox(
                                width: 100,
                                child: IsmLiveButton.secondary(
                                  showBorder: true,
                                  label: 'invite',
                                  onTap: () {},
                                ),
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
                              trailing: SizedBox(
                                width: IsmLiveDimens.hundred,
                                child: IsmLiveButton(
                                  label: 'Accept',
                                  onTap: () {
                                    Get.back();
                                    controller.pkInviteSheet();
                                  },
                                ),
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
