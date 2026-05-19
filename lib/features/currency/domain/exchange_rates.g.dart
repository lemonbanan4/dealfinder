// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExchangeRates _$ExchangeRatesFromJson(Map<String, dynamic> json) =>
    _ExchangeRates(
      base: json['base'] as String? ?? 'EUR',
      rates: (json['rates'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );

Map<String, dynamic> _$ExchangeRatesToJson(_ExchangeRates instance) =>
    <String, dynamic>{
      'base': instance.base,
      'rates': instance.rates,
      'fetchedAt': instance.fetchedAt.toIso8601String(),
    };
