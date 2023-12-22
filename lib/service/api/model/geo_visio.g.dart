// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_visio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoVisioLink _$GeoVisioLinkFromJson(Map<String, dynamic> json) => GeoVisioLink()
  ..href = json['href'] as String
  ..rel = json['rel'] as String
  ..type = json['type'] as String?
  ..title = json['title'] as String?
  ..method = json['method'] as String?
  ..headers = json['headers']
  ..body = json['body']
  ..merge = json['merge'] as bool?;

Map<String, dynamic> _$GeoVisioLinkToJson(GeoVisioLink instance) =>
    <String, dynamic>{
      'href': instance.href,
      'rel': instance.rel,
      'type': instance.type,
      'title': instance.title,
      'method': instance.method,
      'headers': instance.headers,
      'body': instance.body,
      'merge': instance.merge,
    };

GeoVisioProvider _$GeoVisioProviderFromJson(Map<String, dynamic> json) =>
    GeoVisioProvider()
      ..name = json['name'] as String
      ..description = json['description'] as String?
      ..roles =
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList()
      ..url = json['url'] as bool?;

Map<String, dynamic> _$GeoVisioProviderToJson(GeoVisioProvider instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'roles': instance.roles,
      'url': instance.url,
    };

StatsItems _$StatsItemsFromJson(Map<String, dynamic> json) =>
    StatsItems()..count = json['count'] as int;

Map<String, dynamic> _$StatsItemsToJson(StatsItems instance) =>
    <String, dynamic>{
      'count': instance.count,
    };

GeoVisioCollection _$GeoVisioCollectionFromJson(Map<String, dynamic> json) =>
    GeoVisioCollection()
      ..stac_version = json['stac_version'] as String
      ..stac_extension = (json['stac_extension'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..id = json['id'] as String
      ..title = json['title'] as String
      ..description = json['description'] as String
      ..keywords =
          (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList()
      ..license = json['license'] as String
      ..extent = json['extent']
      ..providers = (json['providers'] as List<dynamic>?)
          ?.map((e) => GeoVisioProvider.fromJson(e as Map<String, dynamic>))
          .toList()
      ..links = (json['links'] as List<dynamic>)
          .map((e) => GeoVisioLink.fromJson(e as Map<String, dynamic>))
          .toList()
      ..summaries = (json['summaries'] as List<dynamic>?)
          ?.map((e) => e as Object)
          .toList()
      ..created = json['created'] as String
      ..updated = json['updated'] as String
      ..stats_items =
          StatsItems.fromJson(json['stats:items'] as Map<String, dynamic>);

Map<String, dynamic> _$GeoVisioCollectionToJson(GeoVisioCollection instance) =>
    <String, dynamic>{
      'stac_version': instance.stac_version,
      'stac_extension': instance.stac_extension,
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'keywords': instance.keywords,
      'license': instance.license,
      'extent': instance.extent,
      'providers': instance.providers,
      'links': instance.links,
      'summaries': instance.summaries,
      'created': instance.created,
      'updated': instance.updated,
      'stats:items': instance.stats_items,
    };

GeoVisioCollections _$GeoVisioCollectionsFromJson(Map<String, dynamic> json) =>
    GeoVisioCollections()
      ..links = (json['links'] as List<dynamic>)
          .map((e) => GeoVisioLink.fromJson(e as Map<String, dynamic>))
          .toList()
      ..collections = (json['collections'] as List<dynamic>)
          .map((e) => GeoVisioCollection.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$GeoVisioCollectionsToJson(
        GeoVisioCollections instance) =>
    <String, dynamic>{
      'links': instance.links,
      'collections': instance.collections,
    };
