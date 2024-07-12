import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/controllers/coins_plans_wallet_controller/coins_plans_wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IsmLiveCoinTransactions extends StatelessWidget {
  const IsmLiveCoinTransactions({super.key});
  static const String updateId = 'coin-transaction';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Coin Transactions',
            style: context.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: GetBuilder<CoinsPlansWalletController>(
          builder: (controller) => Column(
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerHeight: 0,
                indicatorColor: Colors.black,
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                controller: controller.coninTranscationTabController,
                onTap: (index) {
                  controller.coinTransactionType =
                      IsmLiveCoinTransactionType.values[index];

                  if (controller.transactions.isEmpty) {
                    controller.fetchTransactions();
                  }
                },
                tabs: [
                  ...IsmLiveCoinTransactionType.values.map(
                    IsmLiveCoinTransacyionsTabButton.new,
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: controller.coninTranscationTabController,
                  children: [
                    ...IsmLiveCoinTransactionType.values
                        .map((e) => const _CoinTransactionsListing()),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _CoinTransactionsListing extends StatelessWidget {
  const _CoinTransactionsListing({
    super.key,
  });

  @override
  Widget build(BuildContext context) => GetBuilder<CoinsPlansWalletController>(
        id: IsmLiveCoinTransactions.updateId,
        builder: (controller) => SmartRefresher(
          controller: controller.refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onLoading: () {
            controller.refreshController.loadComplete();
            controller.fetchTransactions(
              type: controller.coinTransactionType,
              skip: controller.transactions.length,
              moreFetch: true,
            );
          },
          onRefresh: () {
            controller.refreshController.refreshCompleted();
            controller.fetchTransactions(type: controller.coinTransactionType);
          },
          child: controller.transactions.isEmpty
              ? const IsmLiveEmptyScreen(
                  label: 'No Data',
                  placeHolder: IsmLiveAssetConstants.noStreamsPlaceholder,
                )
              : ListView.builder(
                  padding: IsmLiveDimens.edgeInsets16,
                  itemBuilder: (context, index) {
                    var tracsactionValue = controller.transactions[index];
                    return ListTile(
                      contentPadding: IsmLiveDimens.edgeInsets0,
                      leading: Container(
                        height: IsmLiveDimens.twenty,
                        width: IsmLiveDimens.twenty,
                        color: controller.coinTransactionType.value == 2
                            ? Colors.green
                            : Colors.red,
                        child: Icon(
                          controller.coinTransactionType.value == 2
                              ? Icons.arrow_downward_sharp
                              : Icons.arrow_upward_sharp,
                          color: Colors.white,
                          size: IsmLiveDimens.ten,
                        ),
                      ),
                      title: Text(
                        tracsactionValue.description?.isEmpty ?? true
                            ? 'No Discription'
                            : tracsactionValue.description ?? '',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        tracsactionValue.transactionId ?? '',
                        style: TextStyle(fontSize: IsmLiveDimens.ten),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            IsmLiveAssetConstants.coinSvg,
                          ),
                          IsmLiveDimens.boxWidth2,
                          Text(
                            tracsactionValue.amount?.formatWithKAndL() ?? '0',
                            style: context.textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    );
                  },
                  itemCount: controller.transactions.length,
                  shrinkWrap: true,
                ),
        ),
      );
}
