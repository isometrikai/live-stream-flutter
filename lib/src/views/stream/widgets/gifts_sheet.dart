import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveGiftsSheet extends StatelessWidget {
  const IsmLiveGiftsSheet({
    super.key,
    required this.onTap,
  });
  final void Function(IsmLiveGifts) onTap;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IsmLiveDimens.boxHeight16,
          ListTile(
            title: Text(
              'My Balance',
              style: context.textTheme.headlineSmall,
            ),
            trailing: SizedBox(
              width: IsmLiveDimens.oneHundredTwenty,
              height: IsmLiveDimens.forty,
              child: const IsmLiveButton(
                label: 'Add Coins',
                // onTap: () {},
              ),
            ),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: IsmLiveDimens.twentyFive,
                  width: IsmLiveDimens.twentyFive,
                  child: const IsmLiveImage.svg(IsmLiveAssetConstants.coinSvg),
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
          IsmLiveDimens.boxHeight10,
          GetX<IsmLiveStreamController>(
            builder: (controller) => TabBar(
              dividerHeight: 0,
              indicatorColor: Colors.transparent,
              labelPadding: IsmLiveDimens.edgeInsets8_0,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              controller: controller.giftsTabController,
              onTap: (index) {
                controller.giftType = IsmLiveGiftType.values[index];
              },
              tabs: IsmLiveGiftType.values.map(
                (type) {
                  var isSelected = type == controller.giftType;
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.liveTheme?.primaryColor
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(IsmLiveDimens.eighty),
                    ),
                    child: Padding(
                      padding: IsmLiveDimens.edgeInsets16_10,
                      child: Text(
                        type.label,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: isSelected
                              ? context.liveTheme?.selectedTextColor
                              : context.liveTheme?.unselectedTextColor,
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          SizedBox(
            height: Get.height * 0.4,
            child: GetBuilder<IsmLiveStreamController>(
              builder: (controller) => TabBarView(
                controller: controller.giftsTabController,
                children: IsmLiveGiftType.values
                    .map(
                      (e) => GridView.builder(
                        padding: IsmLiveDimens.edgeInsets16,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: IsmLiveDimens.eight,
                          mainAxisSpacing: IsmLiveDimens.eight,
                          crossAxisCount: 3,
                        ),
                        itemBuilder: (_, index) {
                          final gift = e.gifts[index];
                          return _GiftItem(
                            key: ValueKey(gift),
                            gift: gift,
                            onTap: () {
                              Get.back();
                              Get.find<IsmLivePkController>().sendGift();
                              onTap(gift);
                            },
                          );
                        },
                        itemCount: e.gifts.length,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      );
}

class _GiftItem extends StatelessWidget {
  const _GiftItem({
    super.key,
    required this.gift,
    required this.onTap,
  });

  final IsmLiveGifts gift;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CustomIconButton(
        onTap: onTap,
        radius: IsmLiveDimens.sixteen,
        color: context.liveTheme?.cardBackgroundColor,
        icon: Padding(
          padding: IsmLiveDimens.edgeInsets0_8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: IsmLiveDimens.forty,
                width: IsmLiveDimens.forty,
                // child: IsmLiveImage.asset(gift.path),
                child: gift.path.endsWith('gif')
                    ? IsmLiveGif(path: gift.path)
                    : IsmLiveImage.asset(gift.path),
              ),
              IsmLiveDimens.boxHeight8,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const IsmLiveImage.svg(IsmLiveAssetConstants.coinSvg),
                  IsmLiveDimens.boxWidth4,
                  const Text('10'),
                ],
              ),
            ],
          ),
        ),
      );
}
