import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveStreamingScrolling extends StatelessWidget {
  const IsmLiveStreamingScrolling({super.key});

  @override
  Widget build(BuildContext context) => IsmLiveTapHandler(
        onTap: () {
          var controller = Get.find<IsmLiveStreamController>();
          // if ((e.isPaid ?? false) && !(e.isBuy ?? false)) {
          //   controller.paidStreamSheet(
          //       coins: e.amount ?? 0,
          //       onTap: () async {
          //         Get.back();
          //         var res = await controller.buyStream(e.streamId ?? '');
          //         if (res) {
          //           await controller.initializeAndJoinStream(e, isCreatedByMe);
          //         }
          //       });
          // } else {

          if (controller.streams.isNotEmpty) {
            controller.initializeAndJoinStream(
              controller.streams.first,
              false,
              isScrolling: true,
            );
          }
          // }
        },
        child: Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            boxShadow: [
              const BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 3,
                  blurRadius: 3,
                  offset: Offset(0, 1)),
            ],
            borderRadius: BorderRadius.circular(IsmLiveDimens.ten),
            color: Colors.black,
          ),
          child: const Icon(
            Icons.live_tv,
            color: Colors.white,
          ),
        ),
      );
}
