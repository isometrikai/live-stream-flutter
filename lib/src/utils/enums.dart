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
