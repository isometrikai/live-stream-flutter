import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class YourLiveSheet extends StatelessWidget {
  const YourLiveSheet({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Bottom Sheet Background
        Container(
          margin: const EdgeInsets.only(top: 40),
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
          decoration: BoxDecoration(
            color: context.liveTheme?.backgroundColor ??
                (isDarkMode ? const Color(0xFF121212) : Colors.white),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                IsmLiveStrings.youAreLiveNow,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                IsmLiveStrings.weSentNotificationToFollowersText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: subtitleColor),
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
        if (IsmLiveDelegate.streamScreenConfigure.logoWidget != null) ...[
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.transparent,
            child: SizedBox(
              width: 80,
              height: 80,
              child: ClipOval(
                child: IsmLiveDelegate.streamScreenConfigure.logoWidget!,
              ),
            ),
          ),
        ]
      ],
    );
  }
}
