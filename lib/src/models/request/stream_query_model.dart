import 'dart:convert';

class IsmLiveStreamQueryModel {
  const IsmLiveStreamQueryModel({
    this.ids,
    this.customType,
    this.searchTag,
    this.membersIncluded,
    this.membersExactly,
    this.sortOrder,
    this.sort,
    this.limit,
    this.status,
    this.skip,
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
    this.fetchLive,
    this.isRecorded,
    this.private,
    this.restream,
    this.hdbroadcast,
    this.pk,
    this.isScheduledStream,
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
        sortOrder: map['sortOrder'] != null ? map['sortOrder'] as String : null,
        sort: map['sort'] != null ? map['sort'] as int : null,
        limit: map['limit'] != null ? map['limit'] as int : null,
        status: map['status'] != null ? map['status'] as int : null,
        skip: map['skip'] != null ? map['skip'] as int : null,
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
        fetchLive: map['fetchLive'] != null ? map['fetchLive'] as bool : null,
        isRecorded:
            map['isRecorded'] != null ? map['isRecorded'] as bool : null,
        private: map['private'] != null ? map['private'] as bool : null,
        restream: map['restream'] != null ? map['restream'] as bool : null,
        hdbroadcast:
            map['hdbroadcast'] != null ? map['hdbroadcast'] as bool : null,
        pk: map['pk'] != null ? map['pk'] as bool : null,
        isScheduledStream: map['isScheduledStream'] != null
            ? map['isScheduledStream'] as bool
            : null,
      );

  factory IsmLiveStreamQueryModel.fromJson(String source) =>
      IsmLiveStreamQueryModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final String? ids;
  final String? customType;
  final String? searchTag;
  final String? membersIncluded;
  final String? membersExactly;
  final String? sortOrder;
  final int? sort;
  final int? limit;
  final int? status;
  final int? skip;
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
  final bool? fetchLive;
  final bool? isRecorded;
  final bool? private;
  final bool? restream;
  final bool? hdbroadcast;
  final bool? pk;
  final bool? isScheduledStream;

  IsmLiveStreamQueryModel copyWith({
    String? ids,
    String? customType,
    String? searchTag,
    String? membersIncluded,
    String? membersExactly,
    String? sortOrder,
    int? sort,
    int? limit,
    int? status,
    int? skip,
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
    bool? fetchLive,
    bool? isRecorded,
    bool? private,
    bool? restream,
    bool? hdbroadcast,
    bool? pk,
    bool? isScheduledStream,
  }) =>
      IsmLiveStreamQueryModel(
        ids: ids ?? this.ids,
        customType: customType ?? this.customType,
        searchTag: searchTag ?? this.searchTag,
        membersIncluded: membersIncluded ?? this.membersIncluded,
        membersExactly: membersExactly ?? this.membersExactly,
        sortOrder: sortOrder ?? this.sortOrder,
        sort: sort ?? this.sort,
        limit: limit ?? this.limit,
        status: status ?? this.status,
        skip: skip ?? this.skip,
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
        fetchLive: fetchLive ?? this.fetchLive,
        isRecorded: isRecorded ?? this.isRecorded,
        private: private ?? this.private,
        restream: restream ?? this.restream,
        hdbroadcast: hdbroadcast ?? this.hdbroadcast,
        pk: pk ?? this.pk,
        isScheduledStream: isScheduledStream ?? this.isScheduledStream,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'ids': ids,
        'customType': customType,
        'searchTag': searchTag,
        'membersIncluded': membersIncluded,
        'membersExactly': membersExactly,
        'sortOrder': sortOrder,
        'sort': sort,
        'limit': limit,
        'status': status,
        'skip': skip,
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
        'fetchLive': fetchLive,
        'isRecorded': isRecorded,
        'private': private,
        'restream': restream,
        'hdbroadcast': hdbroadcast,
        'pk': pk,
        'isScheduledStream': isScheduledStream,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveStreamQueryModel(ids: $ids, customType: $customType, searchTag: $searchTag, membersIncluded: $membersIncluded, membersExactly: $membersExactly, sortOrder: $sortOrder, sort: $sort, limit: $limit, status: $status, skip: $skip, includeMembers: $includeMembers, membersSkip: $membersSkip, membersLimit: $membersLimit, hdBroadcast: $hdBroadcast, lowLatencyMode: $lowLatencyMode, recorded: $recorded, public: $public, productsLinked: $productsLinked, multiLive: $multiLive, audioOnly: $audioOnly, reStream: $reStream, canPublish: $canPublish, fetchLive: $fetchLive, isRecorded: $isRecorded, private: $private, restream: $restream, hdbroadcast: $hdbroadcast, pk: $pk, isScheduledStream:$isScheduledStream)';

  @override
  bool operator ==(covariant IsmLiveStreamQueryModel other) {
    if (identical(this, other)) return true;

    return other.ids == ids &&
        other.customType == customType &&
        other.searchTag == searchTag &&
        other.membersIncluded == membersIncluded &&
        other.membersExactly == membersExactly &&
        other.sortOrder == sortOrder &&
        other.sort == sort &&
        other.limit == limit &&
        other.status == status &&
        other.skip == skip &&
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
        other.canPublish == canPublish &&
        other.fetchLive == fetchLive &&
        other.isRecorded == isRecorded &&
        other.private == private &&
        other.restream == restream &&
        other.hdbroadcast == hdbroadcast &&
        other.isScheduledStream == isScheduledStream &&
        other.pk == pk;
  }

  @override
  int get hashCode =>
      ids.hashCode ^
      customType.hashCode ^
      searchTag.hashCode ^
      membersIncluded.hashCode ^
      membersExactly.hashCode ^
      sortOrder.hashCode ^
      sort.hashCode ^
      limit.hashCode ^
      status.hashCode ^
      skip.hashCode ^
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
      canPublish.hashCode ^
      fetchLive.hashCode ^
      isRecorded.hashCode ^
      private.hashCode ^
      restream.hashCode ^
      hdbroadcast.hashCode ^
      isScheduledStream.hashCode ^
      pk.hashCode;
}
