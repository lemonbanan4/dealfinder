import 'package:freezed_annotation/freezed_annotation.dart';

part 'deal.freezed.dart';
part 'deal.g.dart';

@freezed
abstract class Deal with _$Deal {
  const factory Deal({
    required String id,
    required String title,
    required String url,
    required String source,
    required double currentPrice,
    required String currency,
    String? imageUrl,
    double? originalPrice,
  }) = _Deal;

  factory Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);
}

extension DealDiscount on Deal {
  /// Percentage drop from [originalPrice] to [currentPrice], 0–100 scale.
  /// Returns null when [originalPrice] is absent or zero.
  double? get discountPercent {
    if (originalPrice == null || originalPrice! <= 0) return null;
    return (originalPrice! - currentPrice) / originalPrice! * 100;
  }
}
