import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_alert.freezed.dart';
part 'price_alert.g.dart';

@freezed
class PriceAlert with _$PriceAlert {
  const factory PriceAlert({
    required String id,
    required String title,
    String? dealId,
    String? searchQuery,
    required double targetPrice,
    required String displayCurrency,
    @Default(false) bool isTriggered,
    required DateTime createdAt,
  }) = _PriceAlert;

  factory PriceAlert.fromJson(Map<String, dynamic> json) =>
      _$PriceAlertFromJson(json);
}
