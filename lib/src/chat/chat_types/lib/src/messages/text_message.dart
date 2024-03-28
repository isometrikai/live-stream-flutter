import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'text_message.g.dart';

/// A class that represents text message.
@JsonSerializable(explicitToJson: true)
@immutable
class TextMessage extends MessageData {
  /// Creates a text message.
  const TextMessage({
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
            timestamp);

  /// Creates a full text message from a partial one.
  const TextMessage.fromPartial({
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

  /// Creates a text message from a map (decoded JSON).
  factory TextMessage.fromJson(Map<String, dynamic> json) =>
      _$TextMessageFromJson(json);

  /// Converts a text message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => _$TextMessageToJson(this);

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
      TextMessage(
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
