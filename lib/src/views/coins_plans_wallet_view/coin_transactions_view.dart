import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/controllers/coins_plans_wallet_controller/coins_plans_wallet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IsmLiveCoinTransactions extends StatelessWidget {
  const IsmLiveCoinTransactions({super.key});
  static const String updateId = 'coin-transaction';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final textColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final indicatorColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        automaticallyImplyLeading: false,
        leading: ismLiveBuildBackButton(
          context,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        centerTitle: true,
        title: Text(
          IsmLiveStrings.coinTransactions,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        iconTheme: IconThemeData(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black),
      ),
      body: GetBuilder<CoinsPlansWalletController>(
        builder: (controller) => Column(
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerHeight: 0,
              indicatorColor: indicatorColor,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              labelColor: textColor,
              unselectedLabelColor: context.liveTheme?.unselectedTextColor ??
                  (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey),
              controller: controller.coninTranscationTabController,
              onTap: (index) {
                controller.coinTransactionType =
                    IsmLiveCoinTransactionType.values[index];
                // Always refresh the selected tab so the latest transactions
                // (e.g. newly purchased credits) appear even if the list already
                // had older items.
                controller.fetchTransactions(
                  type: controller.coinTransactionType,
                );
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
                  ...IsmLiveCoinTransactionType.values.map(
                    (e) => _CoinTransactionsListing(type: e),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinTransactionsListing extends StatelessWidget {
  const _CoinTransactionsListing({required this.type});

  final IsmLiveCoinTransactionType type;

  @override
  Widget build(BuildContext context) => GetBuilder<CoinsPlansWalletController>(
        id: IsmLiveCoinTransactions.updateId,
        builder: (controller) => SmartRefresher(
          controller: controller.refreshControllerFor(type),
          enablePullDown: true,
          enablePullUp: true,
          onLoading: () {
            controller.refreshControllerFor(type).loadComplete();
            controller.fetchTransactions(
              type: type,
              skip: controller.transactionsFor(type).length,
              moreFetch: true,
            );
          },
          onRefresh: () {
            controller.refreshControllerFor(type).refreshCompleted();
            controller.fetchTransactions(type: type);
          },
          child: controller.transactionsFor(type).isEmpty
              ? const IsmLiveEmptyScreen(
                  label: IsmLiveStrings.noData,
                  placeHolder: IsmLiveAssetConstants.noStreamsPlaceholder,
                )
              : Builder(
                  builder: (context) {
                    final isDarkMode =
                        Theme.of(context).brightness == Brightness.dark;
                    final textColor = context.liveTheme?.primaryColor ??
                        (isDarkMode ? Colors.white : Colors.black);
                    final subtitleColor = context
                            .liveTheme?.unselectedTextColor ??
                        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);

                    return ListView.builder(
                      padding: IsmLiveDimens.edgeInsets16,
                      itemBuilder: (context, index) {
                        var tracsactionValue =
                            controller.transactionsFor(type)[index];
                        final isCredit =
                            tracsactionValue.txnType?.toUpperCase() == 'CREDIT';
                        return ListTile(
                          contentPadding: IsmLiveDimens.edgeInsets0,
                          leading: Container(
                            height: IsmLiveDimens.twenty,
                            width: IsmLiveDimens.twenty,
                            color: isCredit ? Colors.green : Colors.red,
                            child: Icon(
                              isCredit
                                  ? Icons.arrow_downward_sharp
                                  : Icons.arrow_upward_sharp,
                              color: Colors.white,
                              size: IsmLiveDimens.ten,
                            ),
                          ),
                          title: Text(
                            '${IsmLiveStrings.transactionId} ${tracsactionValue.transactionId}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            tracsactionValue.formattedDuration,
                            style: TextStyle(
                              fontSize: IsmLiveDimens.twelve,
                              color: subtitleColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const IsmLiveImage.svg(
                                IsmLiveAssetConstants.coinSvg,
                              ),
                              IsmLiveDimens.boxWidth2,
                              Text(
                                tracsactionValue.amount?.formatWithKAndL() ??
                                    '0',
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      itemCount: controller.transactionsFor(type).length,
                      shrinkWrap: true,
                    );
                  },
                ),
        ),
      );
}
