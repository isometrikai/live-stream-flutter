import 'dart:convert';

class IsmLivePresignedUrl {
  IsmLivePresignedUrl({
    this.ttl,
    this.presignedUrl,
    this.msg,
    this.mediaUrl,
  });

  factory IsmLivePresignedUrl.fromMap(Map<String, dynamic> map) => IsmLivePresignedUrl(
        ttl: map['ttl'] != null ? map['ttl'] as int : null,
        presignedUrl: map['presignedUrl'] != null ? map['presignedUrl'] as String : null,
        msg: map['msg'] != null ? map['msg'] as String : null,
        mediaUrl: map['mediaUrl'] != null ? map['mediaUrl'] as String : null,
      );

  factory IsmLivePresignedUrl.fromJson(String source) => IsmLivePresignedUrl.fromMap(json.decode(source) as Map<String, dynamic>);

  final int? ttl;
  final String? presignedUrl;
  final String? msg;
  final String? mediaUrl;

  IsmLivePresignedUrl copyWith({
    int? ttl,
    String? presignedUrl,
    String? msg,
    String? mediaUrl,
  }) =>
      IsmLivePresignedUrl(
        ttl: ttl ?? this.ttl,
        presignedUrl: presignedUrl ?? this.presignedUrl,
        msg: msg ?? this.msg,
        mediaUrl: mediaUrl ?? this.mediaUrl,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'ttl': ttl,
        'presignedUrl': presignedUrl,
        'msg': msg,
        'mediaUrl': mediaUrl,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'PresignedUrl(ttl: $ttl, presignedUrl: $presignedUrl, msg: $msg, mediaUrl: $mediaUrl)';

  @override
  bool operator ==(covariant IsmLivePresignedUrl other) {
    if (identical(this, other)) return true;

    return other.ttl == ttl && other.presignedUrl == presignedUrl && other.msg == msg && other.mediaUrl == mediaUrl;
  }

  @override
  int get hashCode => ttl.hashCode ^ presignedUrl.hashCode ^ msg.hashCode ^ mediaUrl.hashCode;
}
