// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceAlert _$PriceAlertFromJson(Map<String, dynamic> json) => _PriceAlert(
  id: json['id'] as String,
  title: json['title'] as String,
  dealId: json['dealId'] as String?,
  searchQuery: json['searchQuery'] as String?,
  targetPrice: (json['targetPrice'] as num).toDouble(),
  displayCurrency: json['displayCurrency'] as String,
  isTriggered: json['isTriggered'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PriceAlertToJson(_PriceAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'dealId': instance.dealId,
      'searchQuery': instance.searchQuery,
      'targetPrice': instance.targetPrice,
      'displayCurrency': instance.displayCurrency,
      'isTriggered': instance.isTriggered,
      'createdAt': instance.createdAt.toIso8601String(),
    };
