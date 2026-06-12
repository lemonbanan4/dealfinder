import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_alert.freezed.dart';
part 'price_alert.g.dart';

@freezed
abstract class PriceAlert with _$PriceAlert {
  const factory PriceAlert({
    required String id,
    required String title,
    required String message,
    required DateTime time,
    @Default(false) bool isRead,
  }) = _PriceAlert;

  factory PriceAlert.fromJson(Map<String, dynamic> json) =>
      _$PriceAlertFromJson(json);
}
