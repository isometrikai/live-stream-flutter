import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/res/theme/colors.dart';
import 'package:flutter/material.dart';

/// [CustomButton] widget is a custom Button.
///
/// `width` is the width of [CustomButton].
///
/// `height` is the height of [CustomButton].
///
/// `onPress` is the callback when the [CustomButton] is pressed.
///
/// `buttonType` is to define if the button is `active` or `cancelled`.
///
/// `title` is the title of the button.
///
/// `borderWidth` is the border width of the button.
///
/// `titleWidget` is the custom widget for tilte. if `titleWidget` is null `title` will be used.
///
class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    this.width,
    this.onPress,
    this.title,
    this.color,
    this.textColor,
    this.borderColor,
    this.padding,
    this.borderWidth,
    this.titleWidget,
    this.isDisable = false,
    this.margin,
    this.height,
    this.textAlign,
    this.radius,
    this.elevation,
    this.onlyBorder = false,
  }) : super(key: key);

  final String? title;
  final double? width;
  final double? height;
  final double? radius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Function()? onPress;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;
  final Widget? titleWidget;
  final bool isDisable;
  final TextAlign? textAlign;
  final double? elevation;
  final bool onlyBorder;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.all(
      Radius.circular(
        radius ?? IsmLiveDimens.twelve,
      ),
    );
    return Container(
      margin: margin,
      height: height,
      constraints: BoxConstraints(
        maxHeight: IsmLiveDimens.fourtyFour,
      ),
      child: Material(
        elevation: elevation ?? IsmLiveDimens.zero,
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisable
              ? null
              : () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  if (onPress != null) {
                    onPress!();
                  }
                },
          splashColor: isDisable ? null : IsmLiveColors.lightGray,
          borderRadius: borderRadius,
          child: Ink(
            width: width ?? double.infinity,
            height: height ?? double.infinity,
            padding: padding ?? IsmLiveDimens.edgeInsetsAll(IsmLiveDimens.zero),
            decoration: BoxDecoration(
              gradient: !isDisable
                  ? ColorsValue.buttonTopBottomGradient
                  : ColorsValue.disableButtonTopBottomGradient,
              borderRadius: borderRadius,
              // border: Border.all(
              //   width: borderWidth ?? 1,
              //   color: isDisable
              //       ? IsmLiveColors.colorEEEEEE
              //       : borderColor ?? color ?? Get.theme.primaryColor,
              // ),
            ),
            child: titleWidget ??
                (onlyBorder
                    ? Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                            decoration: BoxDecoration(
                              color: IsmLiveColors.white,
                              borderRadius: borderRadius,
                            ),
                            alignment: Alignment.center,
                            child: ShaderMask(
                              shaderCallback: (bounds) => ColorsValue
                                  .buttonTopBottomGradient
                                  .createShader(Rect.fromLTWH(
                                      0, 0, bounds.width, bounds.height)),
                              child: Text(
                                '$title',
                                style: TextStyle(
                                  fontSize: IsmLiveDimens.fifteen,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Colors.white, // required for ShaderMask
                                ),
                              ),
                            )),
                      )
                    : Center(
                        child: Text(
                          '$title',
                          style: color != null
                              ? textColor != null
                                  ? IsmLiveStyles.whiteBold15
                                      .copyWith(color: textColor)
                                  : IsmLiveStyles.whiteBold15
                                      .copyWith(color: color)
                              : IsmLiveStyles.whiteBold15
                                  .copyWith(color: IsmLiveColors.white),
                          textAlign: textAlign,
                        ),
                      )),
          ),
        ),
      ),
    );
  }
}
