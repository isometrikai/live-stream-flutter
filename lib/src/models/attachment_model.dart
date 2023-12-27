import 'dart:convert';

import 'package:flutter/material.dart';

class AttachmentModel {
  const AttachmentModel({
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  factory AttachmentModel.fromMap(Map<String, dynamic> map) => AttachmentModel(
        label: map['label'] as String,
        iconPath: map['iconPath'] as String,
        onTap: map['onTap'],
      );

  factory AttachmentModel.fromJson(String source) =>
      AttachmentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final String label;
  final String iconPath;
  final Function onTap;

  AttachmentModel copyWith({
    String? label,
    String? iconPath,
    VoidCallback? onTap,
  }) =>
      AttachmentModel(
        label: label ?? this.label,
        iconPath: iconPath ?? this.iconPath,
        onTap: onTap ?? this.onTap,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'label': label,
        'iconPath': iconPath,
        'onTap': onTap.toString(),
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'AttachmentModel(label: $label, iconPath: $iconPath, onTap: $onTap)';

  @override
  bool operator ==(covariant AttachmentModel other) {
    if (identical(this, other)) return true;

    return other.label == label &&
        other.iconPath == iconPath &&
        other.onTap == onTap;
  }

  @override
  int get hashCode => label.hashCode ^ iconPath.hashCode ^ onTap.hashCode;
}
