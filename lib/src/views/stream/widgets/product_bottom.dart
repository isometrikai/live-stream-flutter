import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveProductBottom extends StatelessWidget {
  const IsmLiveProductBottom({super.key});

  @override
  Widget build(BuildContext context) => Container(
        color: IsmLiveColors.white,
        padding: IsmLiveDimens.edgeInsets16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selected (2)'),
            SizedBox(
              height: IsmLiveDimens.seventy,
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) => Container(
                  margin: IsmLiveDimens.edgeInsetsR10,
                  width: IsmLiveDimens.sixty,
                  height: IsmLiveDimens.sixty,
                  child: Stack(
                    children: [
                      IsmLiveImage.network(
                        '',
                        radius: IsmLiveDimens.ten,
                      ),
                      Positioned(
                        top: -15,
                        right: -15,
                        child: IconButton(
                          padding: IsmLiveDimens.edgeInsets0,
                          onPressed: () {},
                          icon: const Icon(
                            Icons.cancel,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                itemCount: 2,
                scrollDirection: Axis.horizontal,
              ),
            ),
            IsmLiveDimens.boxHeight10,
            const IsmLiveButton(
              label: 'Continue',
            ),
          ],
        ),
      );
}
