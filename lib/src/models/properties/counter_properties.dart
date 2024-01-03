class IsmLiveCounterProperties {
  const IsmLiveCounterProperties({
    this.showYoureLiveSheet = true,
    this.showYoureLiveText = true,
    this.streamCounter,
  });

  final bool showYoureLiveSheet;
  final bool showYoureLiveText;
  final int? streamCounter;
}
