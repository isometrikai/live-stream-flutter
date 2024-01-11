class IsmLiveCounterProperties {
  const IsmLiveCounterProperties({
    this.showYoureLiveSheet = true,
    this.showYoureLiveText = true,
    this.counterTime,
    this.animationTime,
  });

  final bool showYoureLiveSheet;
  final bool showYoureLiveText;
  final int? counterTime;
  final int? animationTime;
}
