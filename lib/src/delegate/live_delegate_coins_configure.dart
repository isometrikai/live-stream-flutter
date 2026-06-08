part of '../live_delegate.dart';

/// Callback when the user taps Withdraw on the coins wallet screen.
///
/// [balance] is the coin balance converted to base currency
/// ([baseCurrencyAmount] from `/v1/currency/virtualToBase`).
typedef CoinsPlansWalletWithdrawClickCallback = void Function(
  BuildContext context,
  num balance,
);

/// Builder for the Withdraw action on the coins wallet total-money card.
///
/// [onWithdrawTap] should invoke [CoinsPlansWalletWithdrawClickCallback] logic
/// (or host-specific navigation) when the custom control is activated.
typedef CoinsPlansWalletWithdrawButtonBuilder = Widget Function(
  BuildContext context,
  String balanceFormatted,
  VoidCallback onWithdrawTap,
);

/// Configuration for the coins plans wallet screen.
///
/// Set via `IsmLiveApp.configureInterface(coinsPlansWalletScreenConfigure: ...)`.
class IsmLiveCoinsPlansWalletScreenConfigure {
  const IsmLiveCoinsPlansWalletScreenConfigure({
    this.onWithdrawTap,
    this.withdrawButtonBuilder,
    this.showWithdrawButton = true,
  });

  /// Host handler for the default Withdraw button tap.
  final CoinsPlansWalletWithdrawClickCallback? onWithdrawTap;

  /// Replaces the default Withdraw [IsmLiveButton] on the total-money card.
  final CoinsPlansWalletWithdrawButtonBuilder? withdrawButtonBuilder;

  /// When `false`, hides the Withdraw control. Default `true`.
  final bool showWithdrawButton;

  /// Resolves the Withdraw widget for the total-money card.
  Widget buildWithdrawButton(
    BuildContext context, {
    required String balanceFormatted,
    required VoidCallback onWithdrawTap,
  }) {
    final customBuilder = withdrawButtonBuilder;
    if (customBuilder != null) {
      return customBuilder(context, balanceFormatted, onWithdrawTap);
    }
    return IsmLiveButton(
      label: IsmLiveStrings.withdraw,
      small: true,
      onTap: onWithdrawTap,
    );
  }
}