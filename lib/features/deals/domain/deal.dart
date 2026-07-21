import 'package:freezed_annotation/freezed_annotation.dart';

part 'deal.freezed.dart';
part 'deal.g.dart';

@freezed
abstract class Deal with _$Deal {
  const factory Deal({
    @JsonKey(name: 'product_id', defaultValue: 'unknown') required String id,
    @JsonKey(defaultValue: 'No Title') required String title,
    @JsonKey(name: 'tracking_url', defaultValue: '') required String url,
    @JsonKey(name: 'feed_region', defaultValue: 'Unknown')
    required String source,
    @JsonKey(name: 'price', defaultValue: 0.0) required double currentPrice,
    @JsonKey(defaultValue: 'SEK') required String currency,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'retail_price') double? originalPrice,
    @JsonKey(name: 'last_updated') DateTime? lastUpdated,
  }) = _Deal;

  // THIS is the magic line that tells the generator to build deal.g.dart and toJson()
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

extension DealShareUrl on Deal {
  /// The canonical PrisPuls product-page URL for this deal — this is what we
  /// share (never the raw retailer [url]), so a shared link drives the
  /// recipient back into the app and through its affiliate flow rather than
  /// leaking a tracking URL. Mirrors the canonical/hreflang URL that
  /// `DealDetailsPage` writes into the page's SEO meta.
  String get canonicalUrl => 'https://prispuls.com/products/$id';
}
