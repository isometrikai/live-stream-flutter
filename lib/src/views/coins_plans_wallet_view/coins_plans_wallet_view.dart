import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/controllers/coins_plans_wallet_controller/coins_plans_wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CoinsPlansWalletView extends StatelessWidget {
  const CoinsPlansWalletView({super.key});

  static const updateId = 'coin-plans-wallet-view';

  @override
  Widget build(BuildContext context) => GetBuilder<CoinsPlansWalletController>(
        id: updateId,
        builder: (controller) => Scaffold(
          backgroundColor: IsmLiveColors.white,
          appBar: AppBar(
            backgroundColor: IsmLiveColors.transparent,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text('Coins Wallet', style: IsmLiveStyles.black16),
            leading: InkWell(
              onTap: Get.back,
              child: const Icon(Icons.arrow_back),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: IsmLiveDimens.fifteen,
                vertical: IsmLiveDimens.twelve),
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverAppBar(
                  toolbarHeight: Get.height * .11,
                  automaticallyImplyLeading: false,
                  pinned: true,
                  backgroundColor: IsmLiveColors.transparent,
                  surfaceTintColor: IsmLiveColors.transparent,
                  flexibleSpace: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xffE4E4F7),
                      borderRadius: BorderRadius.circular(IsmLiveDimens.eight),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: IsmLiveDimens.fifteen,
                        vertical: IsmLiveDimens.twelve,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: IsmLiveDimens.thirty,
                            height: IsmLiveDimens.thirty,
                            child: SvgPicture.asset(
                              IsmLiveAssetConstants.coinSvg,
                            ),
                          ),
                          IsmLiveDimens.boxWidth20,
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${controller.coinBalance.formatWithKAndL()} Coins',
                                style: IsmLiveStyles.blackBold16,
                              ),
                              IsmLiveDimens.boxHeight2,
                              Text(
                                'My Balance',
                                style: IsmLiveStyles.blackBold16.copyWith(
                                  color: const Color(0xffB1B6D1),
                                  fontSize: IsmLiveDimens.twelve,
                                ),
                              )
                            ],
                          ),
                          IsmLiveDimens.boxWidth50,
                          const Flexible(
                            child: IsmLiveButton(
                              label: 'Transactions',
                              small: true,
                              onTap: IsmLiveRouteManagement.goToCoinTransaction,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverGrid.builder(
                  itemCount: controller.storePlans.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: IsmLiveDimens.ten,
                    mainAxisSpacing: IsmLiveDimens.ten,
                    childAspectRatio: 200 / 220,
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (context, index) {
                    final _storePlan = controller.storePlans[index];
                    final _apiPlan = controller.apiPlans[index];
                    return InkWell(
                      onTap: () => controller.onTapBuyPlan(
                        apiPlan: _apiPlan,
                        storePlan: _storePlan,
                      ),
                      borderRadius: BorderRadius.circular(IsmLiveDimens.eight),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: IsmLiveColors.border),
                          color: IsmLiveColors.transparent,
                          borderRadius:
                              BorderRadius.circular(IsmLiveDimens.eight),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: IsmLiveDimens.five,
                            vertical: IsmLiveDimens.five + IsmLiveDimens.two,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_apiPlan.numberOfUnits} Coins',
                                style: IsmLiveStyles.black16.copyWith(
                                  fontSize: IsmLiveDimens.twelve,
                                ),
                              ),
                              IsmLiveDimens.boxHeight10,
                              SvgPicture.asset(IsmLiveAssetConstants.coinSvg),
                              Text(
                                _storePlan.price,
                                style: IsmLiveStyles.black16.copyWith(
                                  fontSize: IsmLiveDimens.twelve,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IsmLiveDimens.boxHeight10,
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: IsmLiveColors.white,
                                  borderRadius: BorderRadius.circular(
                                      IsmLiveDimens.eight),
                                  border: Border.all(
                                    color: const Color(0xffE4E4F7),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Plan ${index + 1}',
                                    style: IsmLiveStyles.black16.copyWith(
                                        fontSize: IsmLiveDimens.twelve),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      );
}
