enum IsmLiveStreamType {
  nearby('Nearby'),
  pk('PK'),
  popular('Popular'),
  following('Following'),
  paid('Paid'),
  starts('Stars');

  const IsmLiveStreamType(this.label);
  final String label;
}

enum IsmLiveNavItemType {
  streams,
  reels,
  explore,
  chats,
  profile;
}

enum IsmLiveButtonType {
  primary,
  secondary,
  outlined,
  text;
}

enum IsmLiveImageType {
  asset,
  file,
  network;
}

enum IsmLiveCustomType {
  videCall('VideoCall');

  factory IsmLiveCustomType.fromValue(String data) =>
      {
        IsmLiveCustomType.videCall.value: IsmLiveCustomType.videCall,
      }[data] ??
      IsmLiveCustomType.videCall;

  const IsmLiveCustomType(this.value);
  final String value;
}

enum IsmLiveMeetingType {
  videCall(0);

  factory IsmLiveMeetingType.fromValue(int data) =>
      {
        IsmLiveMeetingType.videCall.value: IsmLiveMeetingType.videCall,
      }[data] ??
      IsmLiveMeetingType.videCall;

  const IsmLiveMeetingType(this.value);
  final int value;
}
