import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class LKTextField extends StatelessWidget {
  const LKTextField({
    required this.label,
    this.ctrl,
    Key? key,
  }) : super(key: key);
  final String label;
  final TextEditingController? ctrl;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: IsmLiveDimens.edgeInsetsB10,
            child: Text(label, style: IsmLiveStyles.blackBold16),
          ),
          Container(
            padding: IsmLiveDimens.edgeInsets16,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.white.withOpacity(.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: ctrl,
              decoration: const InputDecoration.collapsed(
                hintText: '',
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
          ),
        ],
      );
}
