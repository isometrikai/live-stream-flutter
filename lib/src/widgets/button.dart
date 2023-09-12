import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveButton extends StatelessWidget {
  const IsmLiveButton({
    Key? key,
    required this.onTap,
    required this.label,
  })  : _type = IsmLiveButtonType.primary,
        super(key: key);

  const IsmLiveButton.secondary({
    Key? key,
    required this.onTap,
    required this.label,
  })  : _type = IsmLiveButtonType.secondary,
        super(key: key);

  const IsmLiveButton.outlined({
    Key? key,
    required this.onTap,
    required this.label,
  })  : _type = IsmLiveButtonType.outlined,
        super(key: key);

  const IsmLiveButton.text({
    Key? key,
    required this.onTap,
    required this.label,
  })  : _type = IsmLiveButtonType.text,
        super(key: key);

  final VoidCallback onTap;
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
    required this.onTap,
    required this.label,
  });

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: IsmLiveColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              IsmLiveDimens.sixteen,
            ),
          ),
          foregroundColor: IsmLiveColors.white,
        ),
        onPressed: onTap,
        child: Text(label),
      );
}

class _Secondary extends StatelessWidget {
  const _Secondary({
    required this.onTap,
    required this.label,
  });

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: IsmLiveColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              IsmLiveDimens.sixteen,
            ),
          ),
          foregroundColor: IsmLiveColors.primary,
        ),
        onPressed: onTap,
        child: Text(label),
      );
}

class _Outlined extends StatelessWidget {
  const _Outlined({
    required this.onTap,
    required this.label,
  });

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: IsmLiveColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              IsmLiveDimens.sixteen,
            ),
          ),
          foregroundColor: IsmLiveColors.primary,
        ),
        onPressed: onTap,
        child: Text(label),
      );
}

class _Text extends StatelessWidget {
  const _Text({
    required this.onTap,
    required this.label,
  });

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              IsmLiveDimens.sixteen,
            ),
          ),
          foregroundColor: IsmLiveColors.primary,
        ),
        onPressed: onTap,
        child: Text(label),
      );
}
