class IsmLiveCounterProperties {
  const IsmLiveCounterProperties({
    this.showYoureLiveSheet = true,
    this.showYoureLiveText = true,
    this.counterTime,
    this.animationTime,
    this.giftTime,
  });

  final bool showYoureLiveSheet;
  final bool showYoureLiveText;
  final int? counterTime;
  final int? animationTime;
  final int? giftTime;

  IsmLiveCounterProperties copyWith({
    bool? showYoureLiveSheet,
    bool? showYoureLiveText,
    int? counterTime,
    int? animationTime,
    int? giftTime,
  }) =>
      IsmLiveCounterProperties(
        showYoureLiveSheet: showYoureLiveSheet ?? this.showYoureLiveSheet,
        showYoureLiveText: showYoureLiveText ?? this.showYoureLiveText,
        counterTime: counterTime ?? this.counterTime,
        animationTime: animationTime ?? this.animationTime,
        giftTime: giftTime ?? this.giftTime,
      );
}
