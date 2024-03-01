import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveProductContainner extends StatelessWidget {
  const IsmLiveProductContainner({super.key});

  @override
  Widget build(BuildContext context) => Container(
        child: Stack(
          children: [
            Column(
              children: [
                const IsmLiveImage.network(''),
                const Text('SOLD'),
                Text(
                  'sfhdfhdsfhsdjgdshfghdgfhjakjdshfjskjdfhsdfhdjfjdfsdhfkjhsdkhfshdfkjkjsdkj',
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge,
                  maxLines: 1,
                ),
                IsmLiveDimens.boxHeight10,
                Row(
                  children: [
                    Text(
                      '\$29.9',
                      style: context.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IsmLiveDimens.boxWidth4,
                    const Text(
                      '\$43.66',
                      style: TextStyle(
                        color: IsmLiveColors.lightGray,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: IsmLiveColors.lightGray,
                      ),
                    ),
                    const Text('15% Off'),
                  ],
                )
              ],
            ),
          ],
        ),
      );
}
