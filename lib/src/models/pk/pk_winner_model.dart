import 'dart:convert';

class IsmLivePkWinnerModel {
  IsmLivePkWinnerModel({
    this.winnerId,
    this.winnerStreamUserId,
    this.percentageOfCoinsFirstUser,
    this.percentageOfCoinsSecondUser,
    this.totalCoinsFirstUser,
    this.totalCoinsSecondUser,
    this.status,
    this.firstUserCoins,
    this.secondUserCoins,
    this.senderUserId,
    this.reciverUserId,
    this.senderStreamUserId,
    this.reciverStreamUserId,
  });

  factory IsmLivePkWinnerModel.fromMap(Map<String, dynamic> map) =>
      IsmLivePkWinnerModel(
        winnerId: map['winnerId'] != null ? map['winnerId'] as String : null,
        winnerStreamUserId: map['winnerStreamUserId'] != null
            ? map['winnerStreamUserId'] as String
            : null,
        percentageOfCoinsFirstUser: map['percentageOfCoinsFirstUser'] != null
            ? map['percentageOfCoinsFirstUser'] as num
            : null,
        percentageOfCoinsSecondUser: map['percentageOfCoinsSecondUser'] != null
            ? map['percentageOfCoinsSecondUser'] as num
            : null,
        totalCoinsFirstUser: map['totalCoinsFirstUser'] != null
            ? map['totalCoinsFirstUser'] as int
            : null,
        totalCoinsSecondUser: map['totalCoinsSecondUser'] != null
            ? map['totalCoinsSecondUser'] as int
            : null,
        status: map['status'] != null ? map['status'] as String : null,
        firstUserCoins:
            map['firstUserCoins'] != null ? map['firstUserCoins'] as int : null,
        secondUserCoins: map['secondUserCoins'] != null
            ? map['secondUserCoins'] as int
            : null,
        senderUserId:
            map['senderUserId'] != null ? map['senderUserId'] as String : null,
        reciverUserId: map['reciverUserId'] != null
            ? map['reciverUserId'] as String
            : null,
        senderStreamUserId: map['senderStreamUserId'] != null
            ? map['senderStreamUserId'] as String
            : null,
        reciverStreamUserId: map['reciverStreamUserId'] != null
            ? map['reciverStreamUserId'] as String
            : null,
      );

  factory IsmLivePkWinnerModel.fromJson(String source) =>
      IsmLivePkWinnerModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final String? winnerId;
  final String? winnerStreamUserId;
  final num? percentageOfCoinsFirstUser;
  final num? percentageOfCoinsSecondUser;
  final int? totalCoinsFirstUser;
  final int? totalCoinsSecondUser;
  final String? status;
  final int? firstUserCoins;
  final int? secondUserCoins;
  final String? senderUserId;
  final String? reciverUserId;
  final String? senderStreamUserId;
  final String? reciverStreamUserId;

  IsmLivePkWinnerModel copyWith({
    String? winnerId,
    String? winnerStreamUserId,
    num? percentageOfCoinsFirstUser,
    num? percentageOfCoinsSecondUser,
    int? totalCoinsFirstUser,
    int? totalCoinsSecondUser,
    String? status,
    int? firstUserCoins,
    int? secondUserCoins,
    String? senderUserId,
    String? reciverUserId,
    String? senderStreamUserId,
    String? reciverStreamUserId,
  }) =>
      IsmLivePkWinnerModel(
        winnerId: winnerId ?? this.winnerId,
        winnerStreamUserId: winnerStreamUserId ?? this.winnerStreamUserId,
        percentageOfCoinsFirstUser:
            percentageOfCoinsFirstUser ?? this.percentageOfCoinsFirstUser,
        percentageOfCoinsSecondUser:
            percentageOfCoinsSecondUser ?? this.percentageOfCoinsSecondUser,
        totalCoinsFirstUser: totalCoinsFirstUser ?? this.totalCoinsFirstUser,
        totalCoinsSecondUser: totalCoinsSecondUser ?? this.totalCoinsSecondUser,
        status: status ?? this.status,
        firstUserCoins: firstUserCoins ?? this.firstUserCoins,
        secondUserCoins: secondUserCoins ?? this.secondUserCoins,
        senderUserId: senderUserId ?? this.senderUserId,
        reciverUserId: reciverUserId ?? this.reciverUserId,
        senderStreamUserId: senderStreamUserId ?? this.senderStreamUserId,
        reciverStreamUserId: reciverStreamUserId ?? this.reciverStreamUserId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'winnerId': winnerId,
        'winnerStreamUserId': winnerStreamUserId,
        'percentageOfCoinsFirstUser': percentageOfCoinsFirstUser,
        'percentageOfCoinsSecondUser': percentageOfCoinsSecondUser,
        'totalCoinsFirstUser': totalCoinsFirstUser,
        'totalCoinsSecondUser': totalCoinsSecondUser,
        'status': status,
        'firstUserCoins': firstUserCoins,
        'secondUserCoins': secondUserCoins,
        'senderUserId': senderUserId,
        'reciverUserId': reciverUserId,
        'senderStreamUserId': senderStreamUserId,
        'reciverStreamUserId': reciverStreamUserId,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLivePkWinnerModel(winnerId: $winnerId, winnerStreamUserId: $winnerStreamUserId, percentageOfCoinsFirstUser: $percentageOfCoinsFirstUser, percentageOfCoinsSecondUser: $percentageOfCoinsSecondUser, totalCoinsFirstUser: $totalCoinsFirstUser, totalCoinsSecondUser: $totalCoinsSecondUser, status: $status, firstUserCoins: $firstUserCoins, secondUserCoins: $secondUserCoins, senderUserId: $senderUserId, reciverUserId: $reciverUserId, senderStreamUserId: $senderStreamUserId, reciverStreamUserId: $reciverStreamUserId)';

  @override
  bool operator ==(covariant IsmLivePkWinnerModel other) {
    if (identical(this, other)) return true;

    return other.winnerId == winnerId &&
        other.winnerStreamUserId == winnerStreamUserId &&
        other.percentageOfCoinsFirstUser == percentageOfCoinsFirstUser &&
        other.percentageOfCoinsSecondUser == percentageOfCoinsSecondUser &&
        other.totalCoinsFirstUser == totalCoinsFirstUser &&
        other.totalCoinsSecondUser == totalCoinsSecondUser &&
        other.status == status &&
        other.firstUserCoins == firstUserCoins &&
        other.secondUserCoins == secondUserCoins &&
        other.senderUserId == senderUserId &&
        other.reciverUserId == reciverUserId &&
        other.senderStreamUserId == senderStreamUserId &&
        other.reciverStreamUserId == reciverStreamUserId;
  }

  @override
  int get hashCode =>
      winnerId.hashCode ^
      winnerStreamUserId.hashCode ^
      percentageOfCoinsFirstUser.hashCode ^
      percentageOfCoinsSecondUser.hashCode ^
      totalCoinsFirstUser.hashCode ^
      totalCoinsSecondUser.hashCode ^
      status.hashCode ^
      firstUserCoins.hashCode ^
      secondUserCoins.hashCode ^
      senderUserId.hashCode ^
      reciverUserId.hashCode ^
      senderStreamUserId.hashCode ^
      reciverStreamUserId.hashCode;
}
