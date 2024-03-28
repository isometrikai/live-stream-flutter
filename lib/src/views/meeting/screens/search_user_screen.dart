import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchUserScreen extends StatelessWidget {
  const SearchUserScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'Search User',
            style: IsmLiveStyles.black16,
          ),
          centerTitle: true,
        ),
        body: GetBuilder<IsmLiveMeetingController>(
          initState: (_) {
            Get.find<IsmLiveMeetingController>().userDetailsList.clear();
            WidgetsBinding.instance
                .addPostFrameCallback((_) async => await Get.find<IsmLiveMeetingController>().getMembersList(skip: 0, limit: 30, searchTag: ''));
          },
          builder: (controller) => Column(
            children: [
              Padding(
                padding: IsmLiveDimens.edgeInsets16,
                child: IsmLiveInputField(
                  prefixIcon: const Icon(Icons.search),
                  controller: TextEditingController(),
                  onchange: (value) async {
                    controller.debouncer.run(() async {
                      controller.userDetailsList.clear();
                      await controller.getMembersList(skip: 0, limit: 30, searchTag: value);
                    });
                  },
                ),
              ),
              const Divider(),
              controller.userDetailsList.isEmpty
                  ? const Center(
                      child: Text('No User found'),
                    )
                  : Expanded(
                      child: SmartRefresher(
                        enablePullUp: true,
                        enablePullDown: true,
                        controller: controller.userRefreshController,
                        onRefresh: () async {
                          controller.userDetailsList.clear();
                          await controller.getMembersList(skip: 0, limit: 30, searchTag: '');
                          controller.userRefreshController.refreshCompleted();
                        },
                        onLoading: () async {
                          await controller.getMembersList(skip: controller.userDetailsList.length, limit: 30, searchTag: '');
                          controller.userRefreshController.refreshCompleted();
                          controller.userRefreshController.loadComplete();
                        },
                        child: Container(
                          color: Colors.white,
                          child: ListView.separated(
                            controller: controller.userListController,
                            padding: IsmLiveDimens.edgeInsets16,
                            shrinkWrap: true,
                            itemBuilder: (context, index) => CheckboxListTile(
                              title: Text(controller.userDetailsList[index].userName),
                              value: controller.membersSelectedList.contains(controller.userDetailsList[index].userId),
                              onChanged: (value) {
                                IsmLiveLog('length ${controller.userDetailsList.length}');
                                if (value != null) {
                                  controller.onMemberSelected(
                                      value, controller.userDetailsList[index].userId, controller.userDetailsList[index].userName);
                                }
                              },
                            ),
                            separatorBuilder: (context, index) => const Divider(),
                            itemCount: controller.userDetailsList.length,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      );
}
