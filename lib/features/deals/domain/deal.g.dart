// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Deal _$DealFromJson(Map<String, dynamic> json) => _Deal(
  id: json['id'] as String,
  title: json['title'] as String,
  priceEur: (json['priceEur'] as num).toDouble(),
  sourceName: json['sourceName'] as String,
  url: json['url'] as String,
  imageUrl: json['imageUrl'] as String?,
  originalCurrency: json['originalCurrency'] as String?,
  originalPrice: (json['originalPrice'] as num?)?.toDouble(),
  scrapedAt: DateTime.parse(json['scrapedAt'] as String),
);

Map<String, dynamic> _$DealToJson(_Deal instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'priceEur': instance.priceEur,
  'sourceName': instance.sourceName,
  'url': instance.url,
  'imageUrl': instance.imageUrl,
  'originalCurrency': instance.originalCurrency,
  'originalPrice': instance.originalPrice,
  'scrapedAt': instance.scrapedAt.toIso8601String(),
};
