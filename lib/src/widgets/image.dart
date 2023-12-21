import 'dart:io';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class IsmLiveImage extends StatelessWidget {
  const IsmLiveImage.asset(
    this.path, {
    super.key,
    this.name = '',
    this.isProfileImage = false,
    this.height,
    this.width,
    this.radius,
    this.borderRadius,
    this.fromPackage = true,
  }) : _imageType = IsmLiveImageType.asset;

  const IsmLiveImage.network(
    this.path, {
    super.key,
    this.name = '',
    this.isProfileImage = false,
    this.height,
    this.width,
    this.radius,
    this.borderRadius,
    this.fromPackage = true,
  }) : _imageType = IsmLiveImageType.network;

  const IsmLiveImage.file(
    this.path, {
    super.key,
    this.name = '',
    this.isProfileImage = true,
    this.height,
    this.width,
    this.radius,
    this.borderRadius,
    this.fromPackage = true,
  }) : _imageType = IsmLiveImageType.file;

  final String path;
  final String name;
  final bool isProfileImage;
  final double? height;
  final double? width;
  final double? radius;
  final BorderRadius? borderRadius;
  final IsmLiveImageType _imageType;
  final bool fromPackage;

  @override
  Widget build(BuildContext context) => Container(
        height: height ?? IsmLiveDimens.forty,
        width: width ?? IsmLiveDimens.forty,
        decoration: BoxDecoration(
          borderRadius: isProfileImage ? null : borderRadius ?? BorderRadius.circular(radius ?? 0),
          shape: isProfileImage ? BoxShape.circle : BoxShape.rectangle,
        ),
        clipBehavior: Clip.antiAlias,
        child: switch (_imageType) {
          IsmLiveImageType.asset => _Asset(path, fromPackage: fromPackage),
          IsmLiveImageType.file => _File(path),
          IsmLiveImageType.network => _Network(path, isProfileImage: isProfileImage, name: name),
        },
      );
}

class _Asset extends StatelessWidget {
  const _Asset(this.path, {required this.fromPackage});

  final String path;
  final bool fromPackage;

  @override
  Widget build(BuildContext context) => Image.asset(
        path,
        package: fromPackage ? null : 'appscrip_live_stream_component',
      );
}

class _File extends StatelessWidget {
  const _File(this.path);

  final String path;

  @override
  Widget build(BuildContext context) => Image.file(
        File(path),
        fit: BoxFit.cover,
      );
}

class _Network extends StatelessWidget {
  const _Network(
    this.imageUrl, {
    required this.name,
    required this.isProfileImage,
  });

  final String imageUrl;
  final String name;
  final bool isProfileImage;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        cacheKey: imageUrl,
        imageBuilder: (_, image) {
          try {
            if (imageUrl.isEmpty) {
              _ErrorImage(isProfileImage: isProfileImage, name: name);
            }
            return Container(
              decoration: BoxDecoration(
                shape: isProfileImage ? BoxShape.circle : BoxShape.rectangle,
                color: IsmLiveColors.secondary,
                image: DecorationImage(image: image, fit: BoxFit.cover),
              ),
            );
          } catch (e, st) {
            IsmLiveLog.error(e, st);
            return _ErrorImage(isProfileImage: isProfileImage, name: name);
          }
        },
        placeholder: (context, url) => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: IsmLiveColors.primary.withOpacity(0.2),
            shape: isProfileImage ? BoxShape.circle : BoxShape.rectangle,
          ),
          child: isProfileImage && name.trim().isNotEmpty
              ? Text(
                  name[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: IsmLiveColors.primary,
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
        ),
        errorWidget: (context, url, error) {
          IsmLiveLog.error('ImageError - $url\n$error');
          return _ErrorImage(isProfileImage: isProfileImage, name: name);
        },
      );
}

class _ErrorImage extends StatelessWidget {
  const _ErrorImage({
    required this.isProfileImage,
    required this.name,
  });

  final bool isProfileImage;
  final String name;

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: IsmLiveColors.primary.withOpacity(0.2),
          shape: isProfileImage ? BoxShape.circle : BoxShape.rectangle,
        ),
        child: isProfileImage
            ? Text(
                name[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: IsmLiveColors.primary,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: IsmLiveColors.secondary,
                  borderRadius: BorderRadius.circular(IsmLiveDimens.eight),
                ),
                alignment: Alignment.center,
                child: const Text(
                  IsmLiveStrings.errorLoadingImage,
                ),
              ),
      );
}
