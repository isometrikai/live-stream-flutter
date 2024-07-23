import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveGiftsSheet extends StatelessWidget {
  IsmLiveGiftsSheet({
    super.key,
    required this.onTap,
  });
  final void Function(IsmLiveGiftsCategoryModel) onTap;
  IsmLivePkController get pkController => Get.find<IsmLivePkController>();

  static const updateId = 'gift-sheet';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (state) async {
          await Get.find<IsmLiveStreamController>().totalWalletCoins();

          IsmLiveUtility.updateLater(() {
            pkController.getGiftCategories();
          });
        },
        builder: (controller) => Column(
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
                  onTap: IsmLiveRouteManagement.goToCoinsPlanWallet,
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
                  Obx(() => Text(
                        controller.giftcoinBalance.formatWithKAndL(),
                        style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            ),
            IsmLiveDimens.boxHeight10,
            SizedBox(
              height: IsmLiveDimens.hundred,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  var categoryDetails = pkController.giftCategoriesList[index];
                  return IsmLiveTapHandler(
                    onTap: () async {
                      controller.giftType = index;

                      await pkController.getGiftsForACategory(
                        giftGroupId: categoryDetails.id ?? '',
                      );
                      controller.update([updateId]);
                    },
                    child: CategoryType(
                      giftImage: categoryDetails.giftImage ?? '',
                      giftTitle: categoryDetails.giftTitle ?? '',
                      isSelected: controller.giftType == index,
                    ),
                  );
                },
                itemCount: pkController.giftCategoriesList.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
              ),
            ),
            SizedBox(
              height: Get.height * 0.4,
              child: pkController.localGift?[controller.giftType]?.isEmpty ?? true
                  ? const Center(child: Text('No data'))
                  : GridView.builder(
                      controller: pkController.giftController,
                      padding: IsmLiveDimens.edgeInsets16,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: IsmLiveDimens.eight,
                        mainAxisSpacing: IsmLiveDimens.eight,
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (_, index) {
                        final gift = pkController.localGift?[controller.giftType]?[index];
                        final giftCategory = pkController.giftCategoriesList[controller.giftType];
                        return _GiftItem(
                          key: ValueKey(gift),
                          gift: gift!,
                          onTap: () {
                            Get.back();

                            if (giftCategory.giftTitle == '3D') {
                              onTap(gift);
                            }

                            pkController.sendGift(
                                giftAnimationImage: gift.giftAnimationImage ?? '',
                                giftId: gift.id ?? '',
                                amount: gift.virtualCurrency ?? 0,
                                giftImage: gift.giftImage ?? '',
                                giftTitle: gift.giftTitle ?? '');
                          },
                        );
                      },
                      itemCount: pkController.localGift?[controller.giftType]?.length,
                    ),
            ),
          ],
        ),
      );
}

class _GiftItem extends StatelessWidget {
  const _GiftItem({
    super.key,
    required this.gift,
    required this.onTap,
  });

  final IsmLiveGiftsCategoryModel gift;
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
                child: IsmLiveImage.network(gift.giftImage ?? '', name: gift.giftTitle ?? ''),
              ),
              IsmLiveDimens.boxHeight8,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const IsmLiveImage.svg(IsmLiveAssetConstants.coinSvg),
                  IsmLiveDimens.boxWidth4,
                  Text('${gift.virtualCurrency}'),
                ],
              ),
            ],
          ),
        ),
      );
}

class CategoryType extends StatelessWidget {
  const CategoryType({
    super.key,
    required this.giftTitle,
    required this.giftImage,
    required this.isSelected,
  });
  final String giftTitle;
  final String giftImage;
  final bool isSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: IsmLiveDimens.hundred,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            giftImage.isEmpty
                ? SizedBox(
                    height: IsmLiveDimens.fifty,
                    width: IsmLiveDimens.sixty,
                    child: const IsmLiveImage.svg(
                      IsmLiveAssetConstants.defaultGift,
                    ),
                  )
                : IsmLiveImage.network(
                    giftImage,
                    name: giftTitle,
                    width: IsmLiveDimens.fifty,
                    height: IsmLiveDimens.fifty,
                  ),
            IsmLiveDimens.boxHeight5,
            Text(
              giftTitle,
              style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected)
              const Divider(
                color: Colors.black,
                thickness: 2,
              ),
          ],
        ),
      );
}
