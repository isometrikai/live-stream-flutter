import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveButton extends StatelessWidget {
  const IsmLiveButton({
    super.key,
    this.onTap,
    required this.label,
    this.small = false,
  })  : _type = IsmLiveButtonType.primary,
        icon = null,
        secondary = false;

  const IsmLiveButton.secondary({
    super.key,
    this.onTap,
    required this.label,
    this.small = false,
  })  : _type = IsmLiveButtonType.secondary,
        icon = null,
        secondary = false;

  const IsmLiveButton.outlined({
    super.key,
    this.onTap,
    required this.label,
    this.small = false,
  })  : _type = IsmLiveButtonType.outlined,
        icon = null,
        secondary = false;

  const IsmLiveButton.text({
    super.key,
    this.onTap,
    required this.label,
    this.small = false,
  })  : _type = IsmLiveButtonType.text,
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

  static MaterialStateProperty<TextStyle?> _textStyle(BuildContext context, bool small) => MaterialStateProperty.all(
        (small ? context.textTheme.labelSmall : context.textTheme.bodyMedium)?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );

  static MaterialStateProperty<EdgeInsetsGeometry?> _padding(BuildContext context, bool small) => MaterialStateProperty.all(
        small ? IsmLiveDimens.edgeInsets8_4 : IsmLiveDimens.edgeInsets16_8,
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
            ),
          IsmLiveButtonType.secondary => _Secondary(
              label: label,
              onTap: onTap,
              small: small,
            ),
          IsmLiveButtonType.outlined => _Outlined(
              label: label,
              onTap: onTap,
              small: small,
            ),
          IsmLiveButtonType.text => _Text(
              label: label,
              onTap: onTap,
              small: small,
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
  });

  final VoidCallback? onTap;
  final String label;
  final bool small;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ButtonStyle(
          padding: IsmLiveButton._padding(context, small),
          shape: context.theme.elevatedButtonTheme.style?.shape ??
              MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: context.liveTheme.buttonRadius ?? BorderRadius.circular(IsmLiveDimens.sixteen),
                ),
              ),
          backgroundColor: MaterialStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.grey;
              }
              return context.theme.elevatedButtonTheme.style?.backgroundColor?.resolve(states) ??
                  context.liveTheme.primaryColor ??
                  IsmLiveColors.primary;
            },
          ),
          foregroundColor: MaterialStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.black;
              }
              return context.theme.elevatedButtonTheme.style?.foregroundColor?.resolve(states) ??
                  context.liveTheme.backgroundColor ??
                  IsmLiveColors.white;
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
  });

  final VoidCallback? onTap;
  final String label;
  final bool small;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ButtonStyle(
          padding: IsmLiveButton._padding(context, small),
          shape: context.theme.elevatedButtonTheme.style?.shape ??
              MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: context.liveTheme.buttonRadius ?? BorderRadius.circular(IsmLiveDimens.sixteen),
                ),
              ),
          backgroundColor: MaterialStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.grey;
              }
              return context.liveTheme.secondaryColor ?? IsmLiveColors.secondary;
            },
          ),
          foregroundColor: MaterialStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.black;
              }
              return context.theme.elevatedButtonTheme.style?.backgroundColor?.resolve(states) ??
                  context.liveTheme.primaryColor ??
                  IsmLiveColors.primary;
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

class _Outlined extends StatelessWidget {
  const _Outlined({
    this.onTap,
    required this.label,
    this.small = false,
  });

  final VoidCallback? onTap;
  final String label;
  final bool small;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: ButtonStyle(
          padding: IsmLiveButton._padding(context, small),
          shape: context.theme.outlinedButtonTheme.style?.shape ??
              MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: context.liveTheme.buttonRadius ?? BorderRadius.circular(IsmLiveDimens.sixteen),
                ),
              ),
          backgroundColor: MaterialStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.grey;
              }
              return Colors.transparent;
            },
          ),
          foregroundColor: MaterialStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.black;
              }
              return context.theme.outlinedButtonTheme.style?.backgroundColor?.resolve(states) ??
                  context.liveTheme.primaryColor ??
                  IsmLiveColors.primary;
            },
          ),
          side: MaterialStateProperty.resolveWith(
            (states) {
              if (states.isDisabled) {
                return BorderSide.none;
              }
              final color = context.theme.outlinedButtonTheme.style?.backgroundColor?.resolve(states) ??
                  context.liveTheme.primaryColor ??
                  IsmLiveColors.primary;
              return BorderSide(color: color, width: 2);
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

class _Text extends StatelessWidget {
  const _Text({
    this.onTap,
    required this.label,
    this.small = false,
  });

  final VoidCallback? onTap;
  final String label;
  final bool small;

  @override
  Widget build(BuildContext context) => TextButton(
        style: ButtonStyle(
          padding: IsmLiveButton._padding(context, small),
          shape: context.theme.textButtonTheme.style?.shape ??
              MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: context.liveTheme.buttonRadius ?? BorderRadius.circular(IsmLiveDimens.sixteen),
                ),
              ),
          backgroundColor: MaterialStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.grey;
              }
              return Colors.transparent;
            },
          ),
          foregroundColor: MaterialStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.black;
              }
              return context.theme.textButtonTheme.style?.backgroundColor?.resolve(states) ?? context.liveTheme.primaryColor ?? IsmLiveColors.primary;
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
              MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: context.liveTheme.iconButtonRadius ?? BorderRadius.circular(IsmLiveDimens.twelve),
                ),
              ),
          backgroundColor: MaterialStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.grey;
              }
              final primaryColor = context.theme.elevatedButtonTheme.style?.backgroundColor?.resolve(states) ??
                  context.liveTheme.primaryColor ??
                  IsmLiveColors.primary;

              final secondaryColor = context.liveTheme.secondaryColor ?? IsmLiveColors.secondary;

              return secondary ? secondaryColor : primaryColor;
            },
          ),
          foregroundColor: MaterialStateColor.resolveWith(
            (states) {
              if (states.isDisabled) {
                return IsmLiveColors.black;
              }
              final primaryColor = context.theme.elevatedButtonTheme.style?.foregroundColor?.resolve(states) ??
                  context.liveTheme.backgroundColor ??
                  IsmLiveColors.white;
              final secondaryColor = context.theme.elevatedButtonTheme.style?.backgroundColor?.resolve(states) ??
                  context.liveTheme.primaryColor ??
                  IsmLiveColors.primary;

              return secondary ? secondaryColor : primaryColor;
            },
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon),
      );
}
