import 'dart:io';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class IsmLiveImage extends StatelessWidget {
  const IsmLiveImage.asset(
    this.path, {
    super.key,
    this.name = 'U',
    this.isProfileImage = false,
    this.dimensions,
    this.height,
    this.width,
    this.radius,
    this.borderRadius,
    this.border,
    this.fromPackage = true,
  })  : _imageType = IsmLiveImageType.asset,
        showError = false,
        color = null;

  const IsmLiveImage.svg(
    this.path, {
    super.key,
    this.name = 'U',
    this.isProfileImage = false,
    this.dimensions,
    this.height,
    this.width,
    this.radius,
    this.color,
    this.borderRadius,
    this.border,
    this.fromPackage = true,
  })  : _imageType = IsmLiveImageType.svg,
        showError = false;

  const IsmLiveImage.network(
    this.path, {
    super.key,
    required this.name,
    this.isProfileImage = false,
    this.dimensions,
    this.height,
    this.width,
    this.radius,
    this.borderRadius,
    this.border,
    this.fromPackage = true,
    this.showError = true,
  })  : _imageType = IsmLiveImageType.network,
        color = null;

  const IsmLiveImage.file(
    this.path, {
    super.key,
    this.name = 'U',
    this.isProfileImage = true,
    this.dimensions,
    this.height,
    this.width,
    this.radius,
    this.borderRadius,
    this.border,
    this.fromPackage = true,
  })  : _imageType = IsmLiveImageType.file,
        showError = false,
        color = null;

  final String path;
  final String name;
  final bool isProfileImage;
  final double? dimensions;
  final double? height;
  final double? width;
  final double? radius;
  final Color? color;
  final BorderRadius? borderRadius;
  final IsmLiveImageType _imageType;
  final bool fromPackage;
  final Border? border;
  final bool showError;

  @override
  Widget build(BuildContext context) => Container(
        height: height ?? dimensions,
        width: width ?? dimensions,
        decoration: BoxDecoration(
          borderRadius: isProfileImage
              ? null
              : borderRadius ?? BorderRadius.circular(radius ?? 0),
          shape: isProfileImage ? BoxShape.circle : BoxShape.rectangle,
          border: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: switch (_imageType) {
          IsmLiveImageType.asset => _Asset(path, fromPackage: fromPackage),
          IsmLiveImageType.svg =>
            _Svg(path, fromPackage: fromPackage, color: color),
          IsmLiveImageType.file => _File(path),
          IsmLiveImageType.network => _Network(
              path,
              isProfileImage: isProfileImage,
              name: name,
              showError: showError,
            ),
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
        package: fromPackage ? IsmLiveConstants.packageName : null,
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
    required this.showError,
  });

  final String imageUrl;
  final String name;
  final bool isProfileImage;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    try {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        cacheKey: imageUrl,
        imageBuilder: (_, image) {
          try {
            if (imageUrl.isEmpty) {
              return _ErrorImage(
                isProfileImage: isProfileImage,
                name: name,
                showError: showError,
              );
            }
            return Container(
              decoration: BoxDecoration(
                shape: isProfileImage ? BoxShape.circle : BoxShape.rectangle,
                image: DecorationImage(image: image, fit: BoxFit.cover),
              ),
            );
          } catch (e, st) {
            IsmLiveLog.error(e, st);
            return _ErrorImage(
              isProfileImage: isProfileImage,
              name: name,
              showError: showError,
            );
          }
        },
        placeholder: (context, url) => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: IsmLiveColors.black.withOpacity(0.2),
            shape: isProfileImage ? BoxShape.circle : BoxShape.rectangle,
          ),
          child: isProfileImage && name.trim().isNotEmpty
              ? Text(
                  name[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: IsmLiveColors.black,
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
        ),
        errorWidget: (context, url, error) => _ErrorImage(
          isProfileImage: isProfileImage,
          name: name,
          showError: showError,
        ),
      );
    } catch (e) {
      IsmLiveLog('----------> $e ');
      return _ErrorImage(
        isProfileImage: isProfileImage,
        name: name,
        showError: showError,
      );
    }
  }
}

class _Svg extends StatelessWidget {
  const _Svg(
    this.path, {
    this.color,
    required this.fromPackage,
  });

  final String path;
  final Color? color;

  final bool fromPackage;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        path,
        colorFilter: color != null
            ? ColorFilter.mode(
                color!,
                BlendMode.srcIn,
              )
            : null,
        package: fromPackage ? IsmLiveConstants.packageName : null,
      );
}

class _ErrorImage extends StatelessWidget {
  const _ErrorImage({
    required this.isProfileImage,
    required this.name,
    required this.showError,
  });

  final bool isProfileImage;
  final String name;
  final bool showError;

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isProfileImage ? IsmLiveColors.black : IsmLiveColors.secondary,
          shape: isProfileImage ? BoxShape.circle : BoxShape.rectangle,
        ),
        child: !showError || isProfileImage
            ? Text(
                name[0],
                style: !isProfileImage
                    ? context.textTheme.displayMedium?.copyWith(
                        color: IsmLiveColors.black,
                        fontWeight: FontWeight.bold,
                      )
                    : context.textTheme.titleSmall?.copyWith(
                        color: IsmLiveColors.white,
                      ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: IsmLiveColors.secondary,
                  borderRadius: BorderRadius.circular(
                    IsmLiveDimens.eight,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  IsmLiveStrings.errorLoadingImage,
                ),
              ),
      );
}
