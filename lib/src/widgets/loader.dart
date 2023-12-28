import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveLoader extends StatelessWidget {
  const IsmLiveLoader({
    super.key,
    this.isDialog = true,
  });

  final bool isDialog;

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          height: 60,
          width: 60,
          child: Card(
            elevation: isDialog ? null : 0,
            color: isDialog ? null : Colors.transparent,
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: CircularProgressIndicator(
                color: IsmLiveColors.primary,
              ),
            ),
          ),
        ),
      );
}
