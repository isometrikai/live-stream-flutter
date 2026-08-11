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

  static Future preCache(
    String file,
    BuildContext context, {
    bool fromPackage = true,
  }) =>
      precacheImage(_provider(file, fromPackage: fromPackage), context);

  static ImageProvider _provider(String path, {required bool fromPackage}) {
    if (path.isURL) {
      return NetworkImage(path);
    }
    return AssetImage(
      path,
      package: fromPackage ? IsmLiveConstants.packageName : null,
    );
  }

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
  Widget build(BuildContext context) {
    if (widget.path.isEmpty) {
      return const SizedBox.shrink();
    }
    return Gif(
      controller: controller,
      image: IsmLiveGif._provider(
        widget.path,
        fromPackage: widget.fromPackage,
      ),
      onFetchCompleted: () {
        if (mounted) {
          controller.repeat();
        }
      },
    );
  }
}
