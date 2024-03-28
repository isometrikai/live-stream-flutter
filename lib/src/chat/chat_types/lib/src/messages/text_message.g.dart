// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextMessage _$TextMessageFromJson(Map<String, dynamic> json) => TextMessage(
      initiated: json['initiated'] as bool?,
      messageId: json['messageId'] as String?,
      senderId: json['senderId'] as String?,
      receiverId: json['receiverId'] as String?,
      payload: json['payload'] as String?,
      status: json['status'] as int?,
      messageType: json['messageType'] as int?,
      createdAt: json['createdAt'] as int?,
      delivered: json['delivered'] as int?,
      read: json['read'] as int?,
      deliveredAt: json['deliveredAt'] as int?,
      offerReplyStatus: json['offerReplyStatus'],
      thumbnail: json['thumbnail'] as String?,
      fileName: json['fileName'] as String?,
      dataSize: json['dataSize'],
      finalRes: json['finalRes'] as bool?,
    );

Map<String, dynamic> _$TextMessageToJson(TextMessage instance) =>
    <String, dynamic>{
      'initiated': instance.initiated,
      'messageId': instance.messageId,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'payload': instance.payload,
      'status': instance.status,
      'messageType': instance.messageType,
      'createdAt': instance.createdAt,
      'delivered': instance.delivered,
      'read': instance.read,
      'deliveredAt': instance.deliveredAt,
      'offerReplyStatus': instance.offerReplyStatus,
      'thumbnail': instance.thumbnail,
      'fileName': instance.fileName,
      'dataSize': instance.dataSize,
      'finalRes': instance.finalRes,
    };
