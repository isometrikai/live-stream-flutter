import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class NoVideoWidget extends StatelessWidget {
  const NoVideoWidget({
    super.key,
    required this.imageUrl,
    this.name = 'U',
  }) : assert(name.length > 0, 'Length of the name should be atleast 1');
  final String name;
  final String imageUrl;

  @override
  Widget build(BuildContext context) => IsmLiveImage.network(
        imageUrl,
        name: name,
        isProfileImage: false,
        showError: false,
      );
}
