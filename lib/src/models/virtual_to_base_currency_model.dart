class IsmLiveVirtualToBaseCurrencyModel {
  const IsmLiveVirtualToBaseCurrencyModel({
    this.virtualCurrencyAmount,
    this.baseCurrencyAmount,
    this.baseCurrency,
    this.baseCurrencySymbol,
    this.virtualCurrencyName,
    this.virtualCurrencyCode,
    this.valueInBaseCurrency,
  });

  factory IsmLiveVirtualToBaseCurrencyModel.fromMap(
    Map<String, dynamic> map,
  ) =>
      IsmLiveVirtualToBaseCurrencyModel(
        virtualCurrencyAmount: map['virtualCurrencyAmount'] as num?,
        baseCurrencyAmount: map['baseCurrencyAmount'] as num?,
        baseCurrency: map['baseCurrency'] as String?,
        baseCurrencySymbol: map['baseCurrencySymbol'] as String?,
        virtualCurrencyName: map['virtualCurrencyName'] as String?,
        virtualCurrencyCode: map['virtualCurrencyCode'] as String?,
        valueInBaseCurrency: map['valueInBaseCurrency'] as num?,
      );

  final num? virtualCurrencyAmount;
  final num? baseCurrencyAmount;
  final String? baseCurrency;
  final String? baseCurrencySymbol;
  final String? virtualCurrencyName;
  final String? virtualCurrencyCode;
  final num? valueInBaseCurrency;
}
