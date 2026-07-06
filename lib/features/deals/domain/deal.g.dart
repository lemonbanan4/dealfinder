// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Deal _$DealFromJson(Map<String, dynamic> json) => _Deal(
  id: json['product_id'] as String? ?? 'unknown',
  title: json['title'] as String? ?? 'No Title',
  url: json['tracking_url'] as String? ?? '',
  source: json['feed_region'] as String? ?? 'Unknown',
  currentPrice: (json['price'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'SEK',
  imageUrl: json['image_url'] as String?,
  originalPrice: (json['retail_price'] as num?)?.toDouble(),
  lastUpdated: json['last_updated'] == null
      ? null
      : DateTime.parse(json['last_updated'] as String),
);

Map<String, dynamic> _$DealToJson(_Deal instance) => <String, dynamic>{
  'product_id': instance.id,
  'title': instance.title,
  'tracking_url': instance.url,
  'feed_region': instance.source,
  'price': instance.currentPrice,
  'currency': instance.currency,
  'image_url': instance.imageUrl,
  'retail_price': instance.originalPrice,
  'last_updated': instance.lastUpdated?.toIso8601String(),
};
