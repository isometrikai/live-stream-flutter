import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flavor_example/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// A class that represents image message widget. Supports different
/// aspect ratios, renders blurred image as a background which is visible
/// if the image is narrow, renders image in form of a file if aspect
/// ratio is very small or very big.
class VideoMessage extends StatefulWidget {
  /// Creates an image message widget based on [types.VideoMessage]
  const VideoMessage({
    Key? key,
    required this.message,
    required this.messageWidth,
  }) : super(key: key);

  /// [types.VideoMessage]
  final types.VideoMessage message;

  /// Maximum message width
  final int messageWidth;

  @override
  _VideoMessageState createState() => _VideoMessageState();
}

/// [VideoMessage] widget state
class _VideoMessageState extends State<VideoMessage> {
  // final _homeController = Get.find<HomeController>();

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              child: CachedNetworkImage(
                imageUrl: '',
                // '${_homeController.mediaBaseUrl}/${widget.message.thumbnail}',
                imageBuilder: (context, imageProvider) => ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    height: 120,
                    width: 170,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, _, dynamic val) => Container(
                  // padding: Dimens.edgeInsets12,
                  height: 120,
                  width: 170,
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.black45,
                  border: Border.all(
                    color: Colors.black45,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(50))),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 50,
              ),
            )
          ],
        ),
        Container(
          // margin: Dimens.edgeInsets0_0_05_5,
          child: Text(
            // '${DateFormat().format(DateF) message.createdAt}',
            '${DateFormat('h:mm a').format(DateTime.fromMicrosecondsSinceEpoch((int.tryParse(widget.message.deliveredAt.toString()) ?? 0) * 1000))}',
            // style: Styles.grey10.copyWith(
            //   color: widget.message.initiated == true
            //       ? Colors.black.withOpacity(.8)
            //       : Colors.grey,
            //   fontStyle: FontStyle.italic,
            // ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
