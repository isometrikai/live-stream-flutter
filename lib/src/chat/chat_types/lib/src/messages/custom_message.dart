import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'custom_message.g.dart';

/// A class that represents custom message. Use metadata to store anything
/// you want.
@JsonSerializable(explicitToJson: true)
@immutable
class CustomMessage extends MessageData {
  /// Creates a custom message.
  const CustomMessage({
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

  /// Creates a full custom message from a partial one.
  const CustomMessage.fromPartial({
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

  /// Creates a custom message from a map (decoded JSON).
  factory CustomMessage.fromJson(Map<String, dynamic> json) =>
      _$CustomMessageFromJson(json);

  /// Converts a custom message to the map representation,
  /// encodable to JSON.
  @override
  Map<String, dynamic> toJson() => _$CustomMessageToJson(this);

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
      CustomMessage(
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
