import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveProductContainer extends StatelessWidget {
  const IsmLiveProductContainer({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: Get.width * .43,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: IsmLiveImage.network(''),
                ),
                IsmLiveDimens.boxHeight10,
                Padding(
                  padding: IsmLiveDimens.edgeInsets8_0,
                  child: const Text('SOLD'),
                ),
                Padding(
                  padding: IsmLiveDimens.edgeInsets8_0,
                  child: Text(
                    'sfhdfhdsfhsdjgdshfghdgfhjakjdshfjskjdfhsdfhdjfjdfsdhfkjhsdkhfshdfkjkjsdkj',
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyLarge,
                    maxLines: 1,
                  ),
                ),
                IsmLiveDimens.boxHeight10,
                Padding(
                  padding: IsmLiveDimens.edgeInsets8_0,
                  child: Row(
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
                  ),
                ),
              ],
            ),
            Positioned(
              right: -10,
              top: -10,
              child: IconButton(
                padding: IsmLiveDimens.edgeInsets0,
                onPressed: () {},
                icon: Icon(
                  Icons.cancel,
                  size: IsmLiveDimens.twenty,
                ),
              ),
            ),
          ],
        ),
      );
}
