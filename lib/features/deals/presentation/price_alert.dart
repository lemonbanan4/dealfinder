import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_alert.freezed.dart';
part 'price_alert.g.dart';

@freezed
abstract class PriceAlert with _$PriceAlert {
  const factory PriceAlert({
    required int id,
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'target_price') required double targetPrice,
    @JsonKey(name: 'product_title') required String productTitle,
    @JsonKey(name: 'product_url') required String productUrl,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // This field will be populated by joining with the 'deals' table
    @JsonKey(name: 'latest_price') double? latestPrice,
    @JsonKey(name: 'currency') String? currency,
  }) = _PriceAlert;

  factory PriceAlert.fromJson(Map<String, dynamic> json) => _$PriceAlertFromJson(json);
}
