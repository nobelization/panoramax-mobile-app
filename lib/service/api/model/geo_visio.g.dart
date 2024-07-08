// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_visio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoVisioLink _$GeoVisioLinkFromJson(Map<String, dynamic> json) => GeoVisioLink()
  ..href = json['href'] as String
  ..rel = json['rel'] as String?
  ..type = json['type'] as String?
  ..title = json['title'] as String?
  ..method = json['method'] as String?
  ..headers = json['headers']
  ..body = json['body']
  ..merge = json['merge'] as bool?
  ..created = json['created'] as String?
  ..geovisio_status = json['geovisio:status'] as String?
  ..id = json['id'] as String?
  ..stats_items = json['stats:items'] == null
      ? null
      : StatsItems.fromJson(json['stats:items'] as Map<String, dynamic>);

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
      'created': instance.created,
      'geovisio:status': instance.geovisio_status,
      'id': instance.id,
      'stats:items': instance.stats_items,
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
    StatsItems()..count = (json['count'] as num).toInt();

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
      ..updated = json['updated'] as String?
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

GeoVisioCatalog _$GeoVisioCatalogFromJson(Map<String, dynamic> json) =>
    GeoVisioCatalog()
      ..stac_version = json['stac_version'] as String
      ..stac_extension = (json['stac_extension'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..id = json['id'] as String
      ..title = json['title'] as String?
      ..description = json['description'] as String
      ..links = (json['links'] as List<dynamic>)
          .map((e) => GeoVisioLink.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$GeoVisioCatalogToJson(GeoVisioCatalog instance) =>
    <String, dynamic>{
      'stac_version': instance.stac_version,
      'stac_extension': instance.stac_extension,
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'links': instance.links,
    };

GeoVisioCollectionImportStatus _$GeoVisioCollectionImportStatusFromJson(
        Map<String, dynamic> json) =>
    GeoVisioCollectionImportStatus()
      ..status = json['status'] as String
      ..items = (json['items'] as List<dynamic>)
          .map((e) => StatusItem.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$GeoVisioCollectionImportStatusToJson(
        GeoVisioCollectionImportStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'items': instance.items,
    };

StatusItem _$StatusItemFromJson(Map<String, dynamic> json) => StatusItem()
  ..id = json['id'] as String?
  ..status = json['status'] as String?
  ..processing_in_progress = json['processing_in_progress'] as bool?
  ..rank = (json['rank'] as num?)?.toInt()
  ..nb_errors = (json['nb_errors'] as num?)?.toInt()
  ..process_error = json['process_error'] as String?
  ..processed_at = json['processed_at'] as String?;

Map<String, dynamic> _$StatusItemToJson(StatusItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'processing_in_progress': instance.processing_in_progress,
      'rank': instance.rank,
      'nb_errors': instance.nb_errors,
      'process_error': instance.process_error,
      'processed_at': instance.processed_at,
    };
