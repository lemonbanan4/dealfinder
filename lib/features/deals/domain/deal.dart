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
      id: json['product_id'] ?? 'unknown_id'.toString(),
      title: json['title'] ?? 'No Title'.toString(),
      currentPrice: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['retail_price'] as num?)?.toDouble(),
      url: (json['tracking_url'] ?? '').toString(),
      imageUrl: json['image_url']?.toString(),
      source: (json['feed_region'] ?? 'Unknown').toString(),
      currency: (json['currency'] ?? 'SEK')
          .toString(), // You might need to add a currency column to your DB
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
