import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class IsmLiveProduct extends StatelessWidget {
  const IsmLiveProduct({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: IsmLiveDimens.seventy,
            height: IsmLiveDimens.seventy,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
              IsmLiveDimens.eight,
            )),
            child: const IsmLiveImage.network(''),
          ),
          Column(
            children: [
              Row(
                children: [
                  const Text(
                    'zara',
                  ),
                  Checkbox(
                    checkColor: Colors.white,
                    value: true,
                    onChanged: (bool? value) {},
                  )
                ],
              ),
              const Text(
                'sfhdfhdsfhsdjgdshfghdgfhj',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              IsmLiveDimens.boxHeight10,
              Row(
                children: [
                  const Text('\$29.9'),
                  IsmLiveDimens.boxWidth4,
                  const Text(
                    '\$43.66',
                    style: TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.overline,
                    ),
                  ),
                  Align(
                    child: const Text('deuuu'),
                  ),
                ],
              )
            ],
          )
        ],
      );
}
