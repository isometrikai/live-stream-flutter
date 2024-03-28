import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'file_message.g.dart';

/// A class that represents file message.
@JsonSerializable(explicitToJson: true)
@immutable
class FileMessage extends MessageData {
  /// Creates a file message.
  const FileMessage({
    bool? initiated,
    String? messageId,
    String? senderId,
    String? receiverId,
    String? payload,
    int? status,
    int? messageType,
    int? createdAt,
    int? delivered,
    int? read,
    int? deliveredAt,
    dynamic offerReplyStatus,
    String? thumbnail,
    String? fileName,
    dynamic dataSize,
    bool? finalRes,
    int? timestamp,
  }) : super(
          initiated,
          messageId,
          senderId,
          receiverId,
          payload,
          status,
          messageType,
          createdAt,
          delivered,
          read,
          deliveredAt,
          offerReplyStatus,
          thumbnail,
          fileName,
          dataSize,
          finalRes,
          timestamp,
        );

  /// Creates a full file message from a partial one.
  const FileMessage.fromPartial({
    bool? initiated,
    String? messageId,
    String? senderId,
    String? receiverId,
    String? payload,
    int? status,
    int? messageType,
    int? createdAt,
    int? delivered,
    int? read,
    int? deliveredAt,
    dynamic offerReplyStatus,
    String? thumbnail,
    String? fileName,
    dynamic dataSize,
    bool? finalRes,
    int? timestamp,
  }) : super(
          initiated,
          messageId,
          senderId,
          receiverId,
          payload,
          status,
          messageType,
          createdAt,
          delivered,
          read,
          deliveredAt,
          offerReplyStatus,
          thumbnail,
          fileName,
          dataSize,
          finalRes,
          timestamp,
        );

  /// Creates a file message from a map (decoded JSON).
  factory FileMessage.fromJson(Map<String, dynamic> json) =>
      _$FileMessageFromJson(json);

  /// Converts a file message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => _$FileMessageToJson(this);

  MessageData copyWith({
    bool? initiated,
    String? messageId,
    String? senderId,
    String? receiverId,
    String? payload,
    int? status,
    int? messageType,
    int? createdAt,
    int? delivered,
    int? read,
    int? deliveredAt,
    dynamic offerReplyStatus,
    String? thumbnail,
    String? fileName,
    dynamic dataSize,
    bool? finalRes,
    int? timestamp,
  }) =>
      FileMessage(
        initiated: initiated,
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        payload: payload,
        status: status,
        messageType: messageType,
        createdAt: createdAt,
        delivered: delivered,
        read: read,
        offerReplyStatus: offerReplyStatus,
        thumbnail: thumbnail,
        fileName: fileName,
        dataSize: dataSize,
        finalRes: finalRes,
        timestamp: timestamp,
      );

  /// Equatable props
  @override
  List<Object?> get props => [
        initiated,
        messageId,
        senderId,
        receiverId,
        payload,
        status,
        messageType,
        createdAt,
        delivered,
        read,
        deliveredAt,
        offerReplyStatus,
        thumbnail,
        fileName,
        dataSize,
        finalRes,
        timestamp,
      ];
}
