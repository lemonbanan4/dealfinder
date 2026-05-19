import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_rates.freezed.dart';
part 'exchange_rates.g.dart';

@freezed
abstract class ExchangeRates with _$ExchangeRates {
  const factory ExchangeRates({
    @Default('EUR') String base,
    required Map<String, double> rates,
    required DateTime fetchedAt,
  }) = _ExchangeRates;

  factory ExchangeRates.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRatesFromJson(json);
}
