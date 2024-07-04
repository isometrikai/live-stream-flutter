import 'dart:convert';

class IsmLiveStreamQueryModel {
  const IsmLiveStreamQueryModel({
    this.ids,
    this.customType,
    this.searchTag,
    this.membersIncluded,
    this.membersExactly,
    this.sort,
    this.includeMembers,
    this.membersSkip,
    this.membersLimit,
    this.hdBroadcast,
    this.lowLatencyMode,
    this.recorded,
    this.public,
    this.productsLinked,
    this.multiLive,
    this.audioOnly,
    this.reStream,
    this.canPublish,
  });

  factory IsmLiveStreamQueryModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveStreamQueryModel(
        ids: map['ids'] != null ? map['ids'] as String : null,
        customType:
            map['customType'] != null ? map['customType'] as String : null,
        searchTag: map['searchTag'] != null ? map['searchTag'] as String : null,
        membersIncluded: map['membersIncluded'] != null
            ? map['membersIncluded'] as String
            : null,
        membersExactly: map['membersExactly'] != null
            ? map['membersExactly'] as String
            : null,
        sort: map['sort'] != null ? map['sort'] as int : null,
        includeMembers: map['includeMembers'] != null
            ? map['includeMembers'] as bool
            : null,
        membersSkip:
            map['membersSkip'] != null ? map['membersSkip'] as int : null,
        membersLimit:
            map['membersLimit'] != null ? map['membersLimit'] as int : null,
        hdBroadcast:
            map['hdBroadcast'] != null ? map['hdBroadcast'] as bool : null,
        lowLatencyMode: map['lowLatencyMode'] != null
            ? map['lowLatencyMode'] as bool
            : null,
        recorded: map['recorded'] != null ? map['recorded'] as bool : null,
        public: map['public'] != null ? map['public'] as bool : null,
        productsLinked: map['productsLinked'] != null
            ? map['productsLinked'] as bool
            : null,
        multiLive: map['multiLive'] != null ? map['multiLive'] as bool : null,
        audioOnly: map['audioOnly'] != null ? map['audioOnly'] as bool : null,
        reStream: map['reStream'] != null ? map['reStream'] as bool : null,
        canPublish:
            map['canPublish'] != null ? map['canPublish'] as bool : null,
      );

  factory IsmLiveStreamQueryModel.fromJson(String source) =>
      IsmLiveStreamQueryModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  final String? ids;
  final String? customType;
  final String? searchTag;
  final String? membersIncluded;
  final String? membersExactly;
  final int? sort;
  final bool? includeMembers;
  final int? membersSkip;
  final int? membersLimit;
  final bool? hdBroadcast;
  final bool? lowLatencyMode;
  final bool? recorded;
  final bool? public;
  final bool? productsLinked;
  final bool? multiLive;
  final bool? audioOnly;
  final bool? reStream;
  final bool? canPublish;

  IsmLiveStreamQueryModel copyWith({
    String? ids,
    String? customType,
    String? searchTag,
    String? membersIncluded,
    String? membersExactly,
    int? sort,
    bool? includeMembers,
    int? membersSkip,
    int? membersLimit,
    bool? hdBroadcast,
    bool? lowLatencyMode,
    bool? recorded,
    bool? public,
    bool? productsLinked,
    bool? multiLive,
    bool? audioOnly,
    bool? reStream,
    bool? canPublish,
  }) =>
      IsmLiveStreamQueryModel(
        ids: ids ?? this.ids,
        customType: customType ?? this.customType,
        searchTag: searchTag ?? this.searchTag,
        membersIncluded: membersIncluded ?? this.membersIncluded,
        membersExactly: membersExactly ?? this.membersExactly,
        sort: sort ?? this.sort,
        includeMembers: includeMembers ?? this.includeMembers,
        membersSkip: membersSkip ?? this.membersSkip,
        membersLimit: membersLimit ?? this.membersLimit,
        hdBroadcast: hdBroadcast ?? this.hdBroadcast,
        lowLatencyMode: lowLatencyMode ?? this.lowLatencyMode,
        recorded: recorded ?? this.recorded,
        public: public ?? this.public,
        productsLinked: productsLinked ?? this.productsLinked,
        multiLive: multiLive ?? this.multiLive,
        audioOnly: audioOnly ?? this.audioOnly,
        reStream: reStream ?? this.reStream,
        canPublish: canPublish ?? this.canPublish,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'ids': ids,
        'customType': customType,
        'searchTag': searchTag,
        'membersIncluded': membersIncluded,
        'membersExactly': membersExactly,
        'sort': sort,
        'includeMembers': includeMembers,
        'membersSkip': membersSkip,
        'membersLimit': membersLimit,
        'hdBroadcast': hdBroadcast,
        'lowLatencyMode': lowLatencyMode,
        'recorded': recorded,
        'public': public,
        'productsLinked': productsLinked,
        'multiLive': multiLive,
        'audioOnly': audioOnly,
        'reStream': reStream,
        'canPublish': canPublish,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveStreamQueryModel(ids: $ids, customType: $customType, searchTag: $searchTag, membersIncluded: $membersIncluded, membersExactly: $membersExactly, sort: $sort, includeMembers: $includeMembers, membersSkip: $membersSkip, membersLimit: $membersLimit, hdBroadcast: $hdBroadcast, lowLatencyMode: $lowLatencyMode, recorded: $recorded, public: $public, productsLinked: $productsLinked, multiLive: $multiLive, audioOnly: $audioOnly, reStream: $reStream, canPublish: $canPublish)';

  @override
  bool operator ==(covariant IsmLiveStreamQueryModel other) {
    if (identical(this, other)) return true;

    return other.ids == ids &&
        other.customType == customType &&
        other.searchTag == searchTag &&
        other.membersIncluded == membersIncluded &&
        other.membersExactly == membersExactly &&
        other.sort == sort &&
        other.includeMembers == includeMembers &&
        other.membersSkip == membersSkip &&
        other.membersLimit == membersLimit &&
        other.hdBroadcast == hdBroadcast &&
        other.lowLatencyMode == lowLatencyMode &&
        other.recorded == recorded &&
        other.public == public &&
        other.productsLinked == productsLinked &&
        other.multiLive == multiLive &&
        other.audioOnly == audioOnly &&
        other.reStream == reStream &&
        other.canPublish == canPublish;
  }

  @override
  int get hashCode =>
      ids.hashCode ^
      customType.hashCode ^
      searchTag.hashCode ^
      membersIncluded.hashCode ^
      membersExactly.hashCode ^
      sort.hashCode ^
      includeMembers.hashCode ^
      membersSkip.hashCode ^
      membersLimit.hashCode ^
      hdBroadcast.hashCode ^
      lowLatencyMode.hashCode ^
      recorded.hashCode ^
      public.hashCode ^
      productsLinked.hashCode ^
      multiLive.hashCode ^
      audioOnly.hashCode ^
      reStream.hashCode ^
      canPublish.hashCode;
}
