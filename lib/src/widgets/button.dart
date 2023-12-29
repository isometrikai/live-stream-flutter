import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveButton extends StatelessWidget {
  const IsmLiveButton({
    super.key,
    this.onTap,
    required this.label,
  }) : _type = IsmLiveButtonType.primary;

  const IsmLiveButton.secondary({
    super.key,
    this.onTap,
    required this.label,
  }) : _type = IsmLiveButtonType.secondary;

  const IsmLiveButton.outlined({
    super.key,
    this.onTap,
    required this.label,
  }) : _type = IsmLiveButtonType.outlined;

  const IsmLiveButton.text({
    super.key,
    this.onTap,
    required this.label,
  }) : _type = IsmLiveButtonType.text;

  final VoidCallback? onTap;
  final String label;
  final IsmLiveButtonType _type;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48,
        width: double.maxFinite,
        child: switch (_type) {
          IsmLiveButtonType.primary => _Primary(label: label, onTap: onTap),
          IsmLiveButtonType.secondary => _Secondary(label: label, onTap: onTap),
          IsmLiveButtonType.outlined => _Outlined(label: label, onTap: onTap),
          IsmLiveButtonType.text => _Text(label: label, onTap: onTap),
        },
      );
}

class _Primary extends StatelessWidget {
  const _Primary({
    this.onTap,
    required this.label,
  });

  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ButtonStyle(
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
          textStyle: MaterialStateProperty.all(
            context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      );
}

class _Secondary extends StatelessWidget {
  const _Secondary({
    this.onTap,
    required this.label,
  });

  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ButtonStyle(
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
          textStyle: MaterialStateProperty.all(
            context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      );
}

class _Outlined extends StatelessWidget {
  const _Outlined({
    this.onTap,
    required this.label,
  });

  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: ButtonStyle(
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
          textStyle: MaterialStateProperty.all(
            context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      );
}

class _Text extends StatelessWidget {
  const _Text({
    this.onTap,
    required this.label,
  });

  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) => TextButton(
        style: ButtonStyle(
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
          textStyle: MaterialStateProperty.all(
            context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      );
}
