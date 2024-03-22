import 'dart:convert';

class IsmLiveStreamAnalytisModel {
  IsmLiveStreamAnalytisModel({
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

  factory IsmLiveStreamAnalytisModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveStreamAnalytisModel(
        totalViewersCount: map['totalViewersCount'] != null
            ? map['totalViewersCount'] as num
            : null,
        duration: map['duration'] != null ? map['duration'] as num : null,
        productCount:
            map['productCount'] != null ? map['productCount'] as num : null,
        soldCount: map['soldCount'] != null ? map['soldCount'] as num : null,
        newViewersCount: map['newViewersCount'] != null
            ? map['newViewersCount'] as num
            : null,
        earnings: map['earnings'] != null ? map['earnings'] as num : null,
        hearts: map['hearts'] != null ? map['hearts'] as num : null,
        followers: map['followers'] != null ? map['followers'] as num : null,
        giftsCount: map['giftsCount'] != null ? map['giftsCount'] as num : null,
        coinsCount: map['coinsCount'] != null ? map['coinsCount'] as num : null,
        totalEarning:
            map['totalEarning'] != null ? map['totalEarning'] as num : null,
      );

  factory IsmLiveStreamAnalytisModel.fromJson(String source) =>
      IsmLiveStreamAnalytisModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final num? totalViewersCount;
  final num? duration;
  final num? productCount;
  final num? soldCount;
  final num? newViewersCount;
  final num? earnings;
  final num? hearts;
  final num? followers;
  final num? giftsCount;
  final num? coinsCount;
  final num? totalEarning;

  IsmLiveStreamAnalytisModel copyWith({
    num? totalViewersCount,
    num? duration,
    num? productCount,
    num? soldCount,
    num? newViewersCount,
    num? earnings,
    num? hearts,
    num? followers,
    num? giftsCount,
    num? coinsCount,
    num? totalEarning,
  }) =>
      IsmLiveStreamAnalytisModel(
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
      'IsmLiveStreamAnalytisModel(totalViewersCount: $totalViewersCount, duration: $duration, productCount: $productCount, soldCount: $soldCount, newViewersCount: $newViewersCount, earnings: $earnings, hearts: $hearts, followers: $followers, giftsCount: $giftsCount, coinsCount: $coinsCount, totalEarning: $totalEarning)';

  @override
  bool operator ==(covariant IsmLiveStreamAnalytisModel other) {
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
