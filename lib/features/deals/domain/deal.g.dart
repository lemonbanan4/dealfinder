// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Deal _$DealFromJson(Map<String, dynamic> json) => _Deal(
  id: json['id'] as String,
  title: json['title'] as String,
  url: json['url'] as String,
  source: json['source'] as String,
  currentPrice: (json['currentPrice'] as num).toDouble(),
  currency: json['currency'] as String,
  imageUrl: json['imageUrl'] as String?,
  originalPrice: (json['originalPrice'] as num?)?.toDouble(),
);

Map<String, dynamic> _$DealToJson(_Deal instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'url': instance.url,
  'source': instance.source,
  'currentPrice': instance.currentPrice,
  'currency': instance.currency,
  'imageUrl': instance.imageUrl,
  'originalPrice': instance.originalPrice,
};
