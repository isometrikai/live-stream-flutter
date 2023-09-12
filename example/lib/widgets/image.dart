import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  const AppImage.asset(
    this.path, {
    super.key,
    this.name = '',
    this.isProfileImage = false,
    this.height,
    this.width,
    this.radius,
    this.borderRadius,
  }) : _imageType = IsmLiveImageType.asset;

  const AppImage.network(
    this.path, {
    super.key,
    this.name = '',
    this.isProfileImage = false,
    this.height,
    this.width,
    this.radius,
    this.borderRadius,
  }) : _imageType = IsmLiveImageType.network;

  const AppImage.file(
    this.path, {
    super.key,
    this.name = '',
    this.isProfileImage = true,
    this.height,
    this.width,
    this.radius,
    this.borderRadius,
  }) : _imageType = IsmLiveImageType.file;

  final String path;
  final String name;
  final bool isProfileImage;
  final double? height;
  final double? width;
  final double? radius;
  final BorderRadius? borderRadius;
  final IsmLiveImageType _imageType;

  @override
  Widget build(BuildContext context) => switch (_imageType) {
        IsmLiveImageType.asset => IsmLiveImage.asset(
            path,
            fromPackage: false,
            borderRadius: borderRadius,
            radius: radius,
            height: height,
            width: width,
            isProfileImage: isProfileImage,
            name: name,
          ),
        IsmLiveImageType.file => IsmLiveImage.file(
            path,
            fromPackage: false,
            borderRadius: borderRadius,
            radius: radius,
            height: height,
            width: width,
            isProfileImage: isProfileImage,
            name: name,
          ),
        IsmLiveImageType.network => IsmLiveImage.network(
            path,
            fromPackage: false,
            borderRadius: borderRadius,
            radius: radius,
            height: height,
            width: width,
            isProfileImage: isProfileImage,
            name: name,
          ),
      };
}
