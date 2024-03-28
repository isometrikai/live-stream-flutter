import 'package:equatable/equatable.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:meta/meta.dart';

/// All possible message types.
enum MessageType { custom, file, image, text, unsupported }

/// All possible statuses message can have.
enum Status { delivered, error, seen, sending, sent }

/// An abstract class that contains all variables and methods
/// every message will have.
@immutable
abstract class MessageData extends Equatable {
  const MessageData(
    this.initiated,
    this.messageId,
    this.senderId,
    this.receiverId,
    this.payload,
    this.status,
    this.messageType,
    this.createdAt,
    this.delivered,
    this.read,
    this.deliveredAt,
    this.offerReplyStatus,
    this.thumbnail,
    this.fileName,
    this.dataSize,
    this.finalRes,
    this.timestamp,
  );

  /// Creates a particular message from a map (decoded JSON).
  /// Type is determined by the `type` field.
  factory MessageData.fromJson(Map<String, dynamic> json) {
    final type = json['messageType'] as int? ?? 1;
    switch (type) {
      case 1000:
        return CustomMessage.fromJson(json);
      case 10:
        return FileMessage.fromJson(json);
      case 1:
        return TextMessage.fromJson(json);
      case 2:
        return ImageMessage.fromJson(json);
      case 3:
        return VideoMessage.fromJson(json);
      default:
        return CustomMessage.fromJson(json);
    }
  }

  final bool? initiated;
  final String? messageId;
  final String? senderId;
  final String? receiverId;
  final String? payload;
  final int? status;
  final int? messageType;
  final int? createdAt;
  final int? delivered;
  final int? read;
  final int? deliveredAt;
  final dynamic offerReplyStatus;
  final String? thumbnail;
  final String? fileName;
  final dynamic dataSize;
  final bool? finalRes;
  final int? timestamp;

  /// Converts a particular message to the map representation, encodable to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'initiated': initiated,
        'messageId': messageId,
        'senderId': senderId,
        'receiverId': receiverId,
        'payload': payload,
        'messageType': messageType,
        'createdAt': createdAt,
        'status': status,
        'delivered': delivered,
        'read': read,
        'deliveredAt': deliveredAt,
        'offerReplyStatus': offerReplyStatus,
        'thumbnail': thumbnail,
        'fileName': fileName,
        'dataSize': dataSize,
        'timestamp': timestamp,
      };
}
