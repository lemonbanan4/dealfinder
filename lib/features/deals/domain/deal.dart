import 'package:freezed_annotation/freezed_annotation.dart';

part 'deal.freezed.dart';
part 'deal.g.dart';

@freezed
abstract class Deal with _$Deal {
  const factory Deal({
    @JsonKey(name: 'product_id') required String id,
    required String title,
    @JsonKey(name: 'tracking_url') required String url,
    required String source,
    @JsonKey(name: 'price') required double currentPrice,
    required String currency,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'retail_price') double? originalPrice,
  }) = _Deal;

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      // Ensure these are all cast to the right types and handle nulls
      id: (json['product_id'] ?? 'unknown').toString(),
      title: (json['title'] ?? 'No Title').toString(),
      url: (json['tracking_url'] ?? '').toString(),
      source: (json['feed_region'] ?? 'Unknown').toString(),
      currentPrice: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] ?? 'SEK').toString(),
      imageUrl: json['image_url']?.toString(),
      // Handle the case where retail_price is null (no discount)
      originalPrice: (json['retail_price'] as num?)?.toDouble(),
    );
  }
}

extension DealDiscount on Deal {
  /// Percentage drop from [originalPrice] to [currentPrice], 0–100 scale.
  /// Returns null when [originalPrice] is absent or zero.
  double? get discountPercent {
    if (originalPrice == null || originalPrice! <= 0) return null;
    return (originalPrice! - currentPrice) / originalPrice! * 100;
  }
}
