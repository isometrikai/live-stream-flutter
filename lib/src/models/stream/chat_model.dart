import 'dart:convert';

class IsmLiveChatModel {
  const IsmLiveChatModel({
    required this.streamId,
    required this.messageId,
    this.parentId,
    required this.userId,
    required this.userIdentifier,
    required this.userName,
    required this.imageUrl,
    required this.timeStamp,
    this.isDeleted = false,
    required this.body,
    this.isReply = false,
    this.sentByMe = false,
    this.sentByHost = false,
  });

  factory IsmLiveChatModel.fromMap(Map<String, dynamic> map) => IsmLiveChatModel(
        streamId: map['streamId'] as String,
        messageId: map['messageId'] as String,
        parentId: map['parentId'] != null ? map['parentId'] as String : null,
        userId: map['userId'] as String,
        userIdentifier: map['userIdentifier'] as String,
        userName: map['userName'] as String,
        imageUrl: map['imageUrl'] as String,
        timeStamp: DateTime.fromMillisecondsSinceEpoch(map['timeStamp'] as int),
        isDeleted: map['isDeleted'] as bool,
        body: map['body'] as String,
        isReply: map['isReply'] as bool,
        sentByMe: map['sentByMe'] as bool,
        sentByHost: map['sentByHost'] as bool,
      );

  factory IsmLiveChatModel.fromJson(String source) => IsmLiveChatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final String streamId;
  final String messageId;
  final String? parentId;
  final String userId;
  final String userIdentifier;
  final String userName;
  final String imageUrl;
  final DateTime timeStamp;
  final bool isDeleted;
  final String body;
  final bool isReply;
  final bool sentByMe;
  final bool sentByHost;

  IsmLiveChatModel copyWith({
    String? streamId,
    String? messageId,
    String? parentId,
    String? userId,
    String? userIdentifier,
    String? userName,
    String? imageUrl,
    DateTime? timeStamp,
    bool? isDeleted,
    String? body,
    bool? isReply,
    bool? sentByMe,
    bool? sentByHost,
  }) =>
      IsmLiveChatModel(
        streamId: streamId ?? this.streamId,
        messageId: messageId ?? this.messageId,
        parentId: parentId ?? this.parentId,
        userId: userId ?? this.userId,
        userIdentifier: userIdentifier ?? this.userIdentifier,
        userName: userName ?? this.userName,
        imageUrl: imageUrl ?? this.imageUrl,
        timeStamp: timeStamp ?? this.timeStamp,
        isDeleted: isDeleted ?? this.isDeleted,
        body: body ?? this.body,
        isReply: isReply ?? this.isReply,
        sentByMe: sentByMe ?? this.sentByMe,
        sentByHost: sentByHost ?? this.sentByHost,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'streamId': streamId,
        'messageId': messageId,
        'parentId': parentId,
        'userId': userId,
        'userIdentifier': userIdentifier,
        'userName': userName,
        'imageUrl': imageUrl,
        'timeStamp': timeStamp.millisecondsSinceEpoch,
        'isDeleted': isDeleted,
        'body': body,
        'isReply': isReply,
        'sentByMe': sentByMe,
        'sentByHost': sentByHost,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveChatModel(streamId: $streamId, messageId: $messageId, parentId: $parentId, userId: $userId, userIdentifier: $userIdentifier, userName: $userName, imageUrl: $imageUrl, timeStamp: $timeStamp, isDeleted: $isDeleted, body: $body, isReply: $isReply, sentByMe: $sentByMe, sentByHost: $sentByHost)';

  @override
  bool operator ==(covariant IsmLiveChatModel other) {
    if (identical(this, other)) return true;

    return other.streamId == streamId && other.messageId == messageId && other.parentId == parentId && other.userId == userId;
  }

  @override
  int get hashCode => streamId.hashCode ^ messageId.hashCode ^ parentId.hashCode ^ userId.hashCode;
}
