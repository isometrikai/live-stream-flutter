import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveButton extends StatelessWidget {
  const IsmLiveButton({
    super.key,
    this.onTap,
    required this.label,
    this.small = false,
    this.showBorder = false,
  })  : _type = IsmLiveButtonType.primary,
        icon = null,
        secondary = false;

  const IsmLiveButton.secondary({
    super.key,
    this.onTap,
    required this.label,
    this.small = false,
    this.showBorder = false,
  })  : _type = IsmLiveButtonType.secondary,
        icon = null,
        secondary = false;

  const IsmLiveButton.icon({
    super.key,
    this.icon,
    this.secondary = false,
    this.onTap,
  })  : _type = IsmLiveButtonType.icon,
        label = '',
        small = false,
        showBorder = false,
        assert(
          icon != null,
          'icon cannot be null for IsmLiveButton.icon',
        );

  final VoidCallback? onTap;
  final String label;
  final IsmLiveButtonType _type;
  final bool small;
  final IconData? icon;
  final bool secondary;
  final bool showBorder;

  static WidgetStateProperty<TextStyle?> _textStyle(BuildContext context, bool small) => WidgetStateProperty.all(
        (small ? context.textTheme.labelSmall : context.textTheme.bodyMedium)?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );

  static WidgetStateProperty<EdgeInsetsGeometry?> _padding(BuildContext context, bool small) => WidgetStateProperty.all(
        small ? IsmLiveDimens.edgeInsets8_4 : IsmLiveDimens.edgeInsets16_8,
      );

  static WidgetStateProperty<OutlinedBorder?> _borderRadius(BuildContext context) => WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: context.liveTheme?.buttonRadius ?? BorderRadius.circular(IsmLiveDimens.twentyFive),
        ),
      );

  static WidgetStateProperty<BorderSide?> _border(BuildContext context, IsmLiveButtonType type) => WidgetStateProperty.all(
        BorderSide(
          color: type == IsmLiveButtonType.primary
              ? context.liveTheme?.primaryButtonTheme?.foregroundColor ?? IsmLiveColors.white
              : context.liveTheme?.secondaryButtonTheme?.foregroundColor ?? IsmLiveColors.primary,
        ),
      );

  @override
  Widget build(BuildContext context) => SizedBox(
        height: _type == IsmLiveButtonType.icon ? null : 48,
        width: _type == IsmLiveButtonType.icon ? null : double.maxFinite,
        child: switch (_type) {
          IsmLiveButtonType.primary => _Primary(
              label: label,
              onTap: onTap,
              small: small,
              showBorder: showBorder,
            ),
          IsmLiveButtonType.secondary => _Secondary(
              label: label,
              onTap: onTap,
              small: small,
              showBorder: showBorder,
            ),
          IsmLiveButtonType.icon => _Icon(
              icon: icon!,
              onTap: onTap,
              secondary: secondary,
            ),
        },
      );
}

class _Primary extends StatelessWidget {
  const _Primary({
    this.onTap,
    required this.label,
    this.small = false,
    this.showBorder = false,
  });

  final VoidCallback? onTap;
  final String label;
  final bool small;
  final bool showBorder;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ButtonStyle(
          padding: IsmLiveButton._padding(context, small),
          shape: IsmLiveButton._borderRadius(context),
          side: showBorder ? IsmLiveButton._border(context, IsmLiveButtonType.primary) : null,
          backgroundColor: WidgetStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return context.liveTheme?.primaryButtonTheme?.disableColor ?? IsmLiveColors.grey;
              }
              return context.liveTheme?.primaryButtonTheme?.backgroundColor ?? context.liveTheme?.primaryColor ?? IsmLiveColors.primary;
            },
          ),
          foregroundColor: WidgetStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.black;
              }
              return context.liveTheme?.primaryButtonTheme?.foregroundColor ?? IsmLiveColors.white;
            },
          ),
          textStyle: IsmLiveButton._textStyle(context, small),
        ),
        onPressed: onTap,
        child: Text(
          label,
          textAlign: TextAlign.center,
        ),
      );
}

class _Secondary extends StatelessWidget {
  const _Secondary({
    this.onTap,
    required this.label,
    this.small = false,
    this.showBorder = false,
  });

  final VoidCallback? onTap;
  final String label;
  final bool small;
  final bool showBorder;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ButtonStyle(
          padding: IsmLiveButton._padding(context, small),
          shape: IsmLiveButton._borderRadius(context),
          side: showBorder ? IsmLiveButton._border(context, IsmLiveButtonType.secondary) : null,
          backgroundColor: WidgetStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return context.liveTheme?.secondaryButtonTheme?.disableColor ?? IsmLiveColors.grey;
              }
              return context.liveTheme?.secondaryButtonTheme?.backgroundColor ?? IsmLiveColors.white;
            },
          ),
          foregroundColor: WidgetStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.white;
              }
              return context.liveTheme?.secondaryButtonTheme?.foregroundColor ?? IsmLiveColors.primary;
            },
          ),
          textStyle: IsmLiveButton._textStyle(context, small),
        ),
        onPressed: onTap,
        child: Text(
          label,
          textAlign: TextAlign.center,
        ),
      );
}

class _Icon extends StatelessWidget {
  const _Icon({
    this.onTap,
    required this.icon,
    this.secondary = false,
  });

  final VoidCallback? onTap;
  final IconData icon;
  final bool secondary;

  @override
  Widget build(BuildContext context) => IconButton(
        style: ButtonStyle(
          shape: context.theme.elevatedButtonTheme.style?.shape ??
              WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: context.liveTheme?.iconButtonRadius ?? BorderRadius.circular(IsmLiveDimens.sixteen),
                ),
              ),
          backgroundColor: WidgetStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.grey;
              }
              final primaryColor = context.theme.elevatedButtonTheme.style?.backgroundColor?.resolve(states) ??
                  context.liveTheme?.primaryColor ??
                  IsmLiveColors.primary;

              final secondaryColor = context.liveTheme?.secondaryColor ?? IsmLiveColors.secondary;

              return secondary ? secondaryColor : primaryColor;
            },
          ),
          foregroundColor: WidgetStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.black;
              }
              final primaryColor = context.theme.elevatedButtonTheme.style?.foregroundColor?.resolve(states) ??
                  context.liveTheme?.backgroundColor ??
                  IsmLiveColors.white;
              final secondaryColor = context.theme.elevatedButtonTheme.style?.backgroundColor?.resolve(states) ??
                  context.liveTheme?.primaryColor ??
                  IsmLiveColors.primary;

              return secondary ? secondaryColor : primaryColor;
            },
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon),
      );
}
