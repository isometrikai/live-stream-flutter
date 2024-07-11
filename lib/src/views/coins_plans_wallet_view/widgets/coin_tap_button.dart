import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/controllers/coins_plans_wallet_controller/coins_plans_wallet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveCoinTransacyionsTabButton extends StatelessWidget {
  const IsmLiveCoinTransacyionsTabButton(
    this.type, {
    super.key,
  });

  final IsmLiveCoinTransactionType type;

  @override
  Widget build(BuildContext context) => GetX<CoinsPlansWalletController>(
        builder: (controller) {
          var isSelected = type == controller.coinTransactionType;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(IsmLiveDimens.eighty),
            ),
            child: Padding(
              padding: IsmLiveDimens.edgeInsets16_10,
              child: Text(
                type.label,
                style: context.textTheme.titleSmall?.copyWith(
                  color: isSelected
                      ? context.liveTheme?.selectedTextColor
                      : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      );
}
