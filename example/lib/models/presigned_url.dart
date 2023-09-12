import 'dart:convert';

class PresignedUrl {
  PresignedUrl({
    this.ttl,
    this.presignedUrl,
    this.msg,
    this.mediaUrl,
  });

  factory PresignedUrl.fromMap(Map<String, dynamic> map) => PresignedUrl(
        ttl: map['ttl'] != null ? map['ttl'] as int : null,
        presignedUrl:
            map['presignedUrl'] != null ? map['presignedUrl'] as String : null,
        msg: map['msg'] != null ? map['msg'] as String : null,
        mediaUrl: map['mediaUrl'] != null ? map['mediaUrl'] as String : null,
      );

  factory PresignedUrl.fromJson(String source) =>
      PresignedUrl.fromMap(json.decode(source) as Map<String, dynamic>);
  int? ttl;
  String? presignedUrl;
  String? msg;
  String? mediaUrl;

  PresignedUrl copyWith({
    int? ttl,
    String? presignedUrl,
    String? msg,
    String? mediaUrl,
  }) =>
      PresignedUrl(
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
  String toString() =>
      'PresignedUrl(ttl: $ttl, presignedUrl: $presignedUrl, msg: $msg, mediaUrl: $mediaUrl)';

  @override
  bool operator ==(covariant PresignedUrl other) {
    if (identical(this, other)) return true;

    return other.ttl == ttl &&
        other.presignedUrl == presignedUrl &&
        other.msg == msg &&
        other.mediaUrl == mediaUrl;
  }

  @override
  int get hashCode =>
      ttl.hashCode ^ presignedUrl.hashCode ^ msg.hashCode ^ mediaUrl.hashCode;
}
