import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class YourLiveSheet extends StatelessWidget {
  const YourLiveSheet({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.topCenter,
        children: [
          // Bottom Sheet Background
          Container(
            margin: const EdgeInsets.only(top: 40),
            // push down to make room for circle
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            // top padding for content
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  IsmLiveStrings.youAreLiveNow,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  IsmLiveStrings.weSentNotificationToFollowersText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: IsmLiveButton(
                    onTap: () {
                      IsmLiveRoute.pop();
                      onTap?.call();
                    },
                    label: IsmLiveStrings.tvContinue,
                  ),
                ),
              ],
            ),
          ),
          // Circle Icon Overlapping Top
          if( IsmLiveDelegate.logoSvg != null && IsmLiveDelegate.logoSvg!.isNotEmpty) ...[
             CircleAvatar(
              radius: 40,
              backgroundColor: Colors.transparent,
              child: SizedBox(
                width: 80,
                height: 80,
                child: ClipOval(
                  child: IsmLiveImage.svg(
                     IsmLiveDelegate.logoSvg!,
                  ),
                ),
              ),
            ),
          ]
        ],
      );
}
