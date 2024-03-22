import 'dart:convert';

class IsmLiveStreamAnalyticsModel {
  IsmLiveStreamAnalyticsModel({
    this.totalViewersCount,
    this.duration,
    this.productCount,
    this.soldCount,
    this.newViewersCount,
    this.earnings,
    this.hearts,
    this.followers,
    this.giftsCount,
    this.coinsCount,
    this.totalEarning,
  });

  factory IsmLiveStreamAnalyticsModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveStreamAnalyticsModel(
        totalViewersCount: map['totalViewersCount'] != null
            ? map['totalViewersCount'] as int
            : null,
        duration: map['duration'] != null ? map['duration'] as double : null,
        productCount:
            map['productCount'] != null ? map['productCount'] as int : null,
        soldCount: map['soldCount'] != null ? map['soldCount'] as int : null,
        newViewersCount: map['newViewersCount'] != null
            ? map['newViewersCount'] as int
            : null,
        earnings: map['earnings'] != null ? map['earnings'] as double : null,
        hearts: map['hearts'] != null ? map['hearts'] as int : null,
        followers: map['followers'] != null ? map['followers'] as int : null,
        giftsCount: map['giftsCount'] != null ? map['giftsCount'] as int : null,
        coinsCount: map['coinsCount'] != null ? map['coinsCount'] as int : null,
        totalEarning:
            map['totalEarning'] != null ? map['totalEarning'] as double : null,
      );

  factory IsmLiveStreamAnalyticsModel.fromJson(String source) =>
      IsmLiveStreamAnalyticsModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final int? totalViewersCount;
  final double? duration;
  final int? productCount;
  final int? soldCount;
  final int? newViewersCount;
  final double? earnings;
  final int? hearts;
  final int? followers;
  final int? giftsCount;
  final int? coinsCount;
  final double? totalEarning;

  IsmLiveStreamAnalyticsModel copyWith({
    int? totalViewersCount,
    double? duration,
    int? productCount,
    int? soldCount,
    int? newViewersCount,
    double? earnings,
    int? hearts,
    int? followers,
    int? giftsCount,
    int? coinsCount,
    double? totalEarning,
  }) =>
      IsmLiveStreamAnalyticsModel(
        totalViewersCount: totalViewersCount ?? this.totalViewersCount,
        duration: duration ?? this.duration,
        productCount: productCount ?? this.productCount,
        soldCount: soldCount ?? this.soldCount,
        newViewersCount: newViewersCount ?? this.newViewersCount,
        earnings: earnings ?? this.earnings,
        hearts: hearts ?? this.hearts,
        followers: followers ?? this.followers,
        giftsCount: giftsCount ?? this.giftsCount,
        coinsCount: coinsCount ?? this.coinsCount,
        totalEarning: totalEarning ?? this.totalEarning,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'totalViewersCount': totalViewersCount,
        'duration': duration,
        'productCount': productCount,
        'soldCount': soldCount,
        'newViewersCount': newViewersCount,
        'earnings': earnings,
        'hearts': hearts,
        'followers': followers,
        'giftsCount': giftsCount,
        'coinsCount': coinsCount,
        'totalEarning': totalEarning,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveStreamAnalyticsModel(totalViewersCount: $totalViewersCount, duration: $duration, productCount: $productCount, soldCount: $soldCount, newViewersCount: $newViewersCount, earnings: $earnings, hearts: $hearts, followers: $followers, giftsCount: $giftsCount, coinsCount: $coinsCount, totalEarning: $totalEarning)';

  @override
  bool operator ==(covariant IsmLiveStreamAnalyticsModel other) {
    if (identical(this, other)) return true;

    return other.totalViewersCount == totalViewersCount &&
        other.duration == duration &&
        other.productCount == productCount &&
        other.soldCount == soldCount &&
        other.newViewersCount == newViewersCount &&
        other.earnings == earnings &&
        other.hearts == hearts &&
        other.followers == followers &&
        other.giftsCount == giftsCount &&
        other.coinsCount == coinsCount &&
        other.totalEarning == totalEarning;
  }

  @override
  int get hashCode =>
      totalViewersCount.hashCode ^
      duration.hashCode ^
      productCount.hashCode ^
      soldCount.hashCode ^
      newViewersCount.hashCode ^
      earnings.hashCode ^
      hearts.hashCode ^
      followers.hashCode ^
      giftsCount.hashCode ^
      coinsCount.hashCode ^
      totalEarning.hashCode;
}
