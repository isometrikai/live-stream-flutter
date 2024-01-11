import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveGiftsSheet extends StatelessWidget {
  const IsmLiveGiftsSheet({
    super.key,
    required this.list,
    required this.onTap,
  });
  final List<String> list;
  final void Function(String body) onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: IsmLiveDimens.edgeInsets0,
              title: Text(
                'My Balance',
                style: context.textTheme.headlineSmall,
              ),
              trailing: SizedBox(
                width: IsmLiveDimens.oneHundredTwenty,
                height: IsmLiveDimens.forty,
                child: IsmLiveButton(
                  label: 'Add Coins',
                  onTap: () {},
                ),
              ),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: IsmLiveDimens.twentyFive,
                    width: IsmLiveDimens.twentyFive,
                    child: const IsmLiveImage.svg(IsmLiveAssetConstants.coin),
                  ),
                  IsmLiveDimens.boxWidth4,
                  Text(
                    '135',
                    style: context.textTheme.bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IsmLiveDimens.boxHeight16,
            SizedBox(
              height: Get.height * 0.32,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: IsmLiveDimens.five,
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) => CustomIconButton(
                  radius: IsmLiveDimens.ten,
                  icon: Padding(
                    padding: IsmLiveDimens.edgeInsets0_8,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(
                        height: IsmLiveDimens.fifty,
                        width: IsmLiveDimens.fifty,
                        child: IsmLiveImage.asset(
                          list[index],
                        ),
                      ),
                      IsmLiveDimens.boxHeight5,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const IsmLiveImage.svg(IsmLiveAssetConstants.coin),
                          IsmLiveDimens.boxWidth2,
                          const Text('10'),
                        ],
                      ),
                    ]),
                  ),
                  onTap: () async {
                    onTap(list[index]);
                  },
                  color: const Color.fromARGB(255, 203, 197, 214),
                ),
                itemCount: list.length,
              ),
            ),
          ],
        ),
      );
}
