// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scraper_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScraperConfig _$ScraperConfigFromJson(Map<String, dynamic> json) =>
    _ScraperConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      baseUrl: json['baseUrl'] as String,
      listSelector: json['listSelector'] as String,
      titleSelector: json['titleSelector'] as String,
      priceSelector: json['priceSelector'] as String,
      linkSelector: json['linkSelector'] as String,
      imageSelector: json['imageSelector'] as String?,
      nextPageSelector: json['nextPageSelector'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$ScraperConfigToJson(_ScraperConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'baseUrl': instance.baseUrl,
      'listSelector': instance.listSelector,
      'titleSelector': instance.titleSelector,
      'priceSelector': instance.priceSelector,
      'linkSelector': instance.linkSelector,
      'imageSelector': instance.imageSelector,
      'nextPageSelector': instance.nextPageSelector,
      'isEnabled': instance.isEnabled,
    };
