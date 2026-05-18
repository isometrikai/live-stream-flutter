import 'dart:math';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class NoVideoWidget extends StatelessWidget {
  const NoVideoWidget({
    super.key,
    required this.imageUrl,
    this.name = '',
    this.showConnectingState = false,
    this.connectingText,
    this.initials,
  });
  final String name;
  final String imageUrl;
  final bool showConnectingState;
  final String? connectingText;
  final String? initials;

  String get _resolvedInitials => IsmLiveInitials.fromNames(
        primary: initials,
        secondary: name,
      );

  bool _isCompactLayout(BoxConstraints constraints) {
    final maxH = constraints.maxHeight;
    final maxW = constraints.maxWidth;
    if (maxH.isFinite && maxH > 0 && maxH < 108) {
      return true;
    }
    if (maxW.isFinite && maxW > 0 && maxW < 88) {
      return true;
    }
    return false;
  }

  double _avatarSize(BoxConstraints constraints, {required bool compact}) {
    final maxW = constraints.maxWidth.isFinite && constraints.maxWidth > 0
        ? constraints.maxWidth
        : IsmLiveDimens.hundred;
    final maxH = constraints.maxHeight.isFinite && constraints.maxHeight > 0
        ? constraints.maxHeight
        : IsmLiveDimens.hundred;

    if (compact) {
      return (min(maxW, maxH) * 0.88).clamp(28.0, 80.0);
    }

    final heightBudget = showConnectingState ? maxH * 0.42 : maxH * 0.52;
    return min(
      IsmLiveDimens.hundred,
      min(maxW * 0.5, heightBudget),
    ).clamp(40.0, IsmLiveDimens.hundred);
  }

  Widget _avatar(double size) => IsmLiveImage.network(
        IsmLiveDelegate.getUserProfileUrl?.call(imageUrl) ?? imageUrl,
        name: name,
        isProfileImage: true,
        initials: _resolvedInitials,
        height: size,
        width: size,
        showError: false,
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = _isCompactLayout(constraints);
          final avatarSize = _avatarSize(constraints, compact: compact);

          if (compact) {
            return Center(child: _avatar(avatarSize));
          }

          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: IsmLiveDimens.eight,
                  vertical: IsmLiveDimens.four,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _avatar(avatarSize),
                    IsmLiveDimens.boxHeight10,
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: IsmLiveStyles.blackBold16.copyWith(
                        color: IsmLiveColors.white,
                      ),
                    ),
                    if (showConnectingState) ...[
                      IsmLiveDimens.boxHeight8,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                IsmLiveColors.white,
                              ),
                            ),
                          ),
                          IsmLiveDimens.boxWidth8,
                          Text(
                            connectingText ?? IsmLiveStrings.joiningLiveStream,
                            style: IsmLiveStyles.blackBold16.copyWith(
                              fontSize: 14,
                              color: IsmLiveColors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );
}

class NoVideoIconWidget extends StatelessWidget {
  const NoVideoIconWidget();

  @override
  Widget build(BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0.1),
          color: Colors.black,
        ),
        width: MediaQuery.of(context).size.width / 4,
        child: const Center(
          child: Icon(
            Icons.person_add,
            color: Colors.white,
          ),
        ),
      );
}
