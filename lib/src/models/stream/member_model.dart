import 'dart:convert';

class IsmLiveMemberModel {
  IsmLiveMemberModel({
    required this.isAdmin,
    required this.isPublishing,
    required this.memberId,
    required this.memberIdentifier,
    required this.memberName,
  });

  factory IsmLiveMemberModel.fromMap(Map<String, dynamic> map) => IsmLiveMemberModel(
        isAdmin: map['isAdmin'] as bool,
        isPublishing: map['isPublishing'] as bool,
        memberId: map['memberId'] as String,
        memberIdentifier: map['memberIdentifier'] as String,
        memberName: map['memberName'] as String,
      );

  factory IsmLiveMemberModel.fromJson(String source) => IsmLiveMemberModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final bool isAdmin;
  final bool isPublishing;
  final String memberId;
  final String memberIdentifier;
  final String memberName;

  IsmLiveMemberModel copyWith({
    bool? isAdmin,
    bool? isPublishing,
    String? memberId,
    String? memberIdentifier,
    String? memberName,
  }) =>
      IsmLiveMemberModel(
        isAdmin: isAdmin ?? this.isAdmin,
        isPublishing: isPublishing ?? this.isPublishing,
        memberId: memberId ?? this.memberId,
        memberIdentifier: memberIdentifier ?? this.memberIdentifier,
        memberName: memberName ?? this.memberName,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'isAdmin': isAdmin,
        'isPublishing': isPublishing,
        'memberId': memberId,
        'memberIdentifier': memberIdentifier,
        'memberName': memberName,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveMemberModel(isAdmin: $isAdmin, isPublishing: $isPublishing, memberId: $memberId, memberIdentifier: $memberIdentifier, memberName: $memberName)';

  @override
  bool operator ==(covariant IsmLiveMemberModel other) {
    if (identical(this, other)) return true;

    return other.isAdmin == isAdmin &&
        other.isPublishing == isPublishing &&
        other.memberId == memberId &&
        other.memberIdentifier == memberIdentifier &&
        other.memberName == memberName;
  }

  @override
  int get hashCode => isAdmin.hashCode ^ isPublishing.hashCode ^ memberId.hashCode ^ memberIdentifier.hashCode ^ memberName.hashCode;
}
