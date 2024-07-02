import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gif/gif.dart';

class IsmLiveGif extends StatefulWidget {
  const IsmLiveGif({
    super.key,
    required this.path,
    this.fromPackage = true,
  });

  final String path;
  final bool fromPackage;

  static Future preCache(String file) => precacheImage(
      (file.isURL
          ? NetworkImage(file)
          : AssetImage(
              file,
              package: IsmLiveConstants.packageName,
            )) as ImageProvider,
      Get.context!);

  @override
  State<IsmLiveGif> createState() => _IsmLiveGifState();
}

class _IsmLiveGifState extends State<IsmLiveGif>
    with SingleTickerProviderStateMixin {
  late final GifController controller;

  @override
  void initState() {
    super.initState();
    controller = GifController(vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Gif(
        controller: controller,
        image: (widget.path.isURL
            ? NetworkImage(widget.path)
            : AssetImage(
                widget.path,
                package: IsmLiveConstants.packageName,
              )) as ImageProvider,
        onFetchCompleted: () {
          if (mounted) {
            controller.repeat();
          }
        },
      );
}
