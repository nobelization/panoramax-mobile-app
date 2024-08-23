import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'geo_visio.g.dart';

@JsonSerializable()
class GeoVisioLink {
  late String href;
  late String? rel;
  String? type;
  String? title;
  String? method;
  Object? headers;
  Object? body;
  bool? merge;
  String? created;
  @JsonKey(name: "geovisio:status")
  String? geovisio_status;
  String? id;
  @JsonKey(name: "stats:items")
  StatsItems? stats_items;
  GeoVisioExtent? extent;

  factory GeoVisioLink.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioLinkFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioLinkToJson(this);

  String? getThumbUrl() {
    return '$href/thumb.jpg';
  }

  GeoVisioLink();
}

@JsonSerializable()
class GeoVisioExtent {
  Object? spatial;
  Temporal? temporal;

  factory GeoVisioExtent.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioExtentFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioExtentToJson(this);

  GeoVisioExtent();
}

@JsonSerializable()
class Temporal {
  List<List<String?>?>? interval;
  factory Temporal.fromJson(Map<String, dynamic> json) =>
      _$TemporalFromJson(json);
  Map<String, dynamic> toJson() => _$TemporalToJson(this);

  Temporal();
}

@JsonSerializable()
class GeoVisioProvider {
  late String name;
  String? description;
  List<String>? roles;
  bool? url;

  factory GeoVisioProvider.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioProviderFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioProviderToJson(this);

  GeoVisioProvider();
}

@JsonSerializable()
class StatsItems {
  late int count;

  factory StatsItems.fromJson(Map<String, dynamic> json) =>
      _$StatsItemsFromJson(json);
  Map<String, dynamic> toJson() => _$StatsItemsToJson(this);

  StatsItems();
}

@JsonSerializable()
class GeoVisioCollection {
  late String stac_version;
  List<String>? stac_extension;
  final String type = "Collection";
  late String id;
  late String title;
  late String description;
  List<String>? keywords;
  late String license;
  Object? extent;
  List<GeoVisioProvider>? providers;
  late List<GeoVisioLink> links;
  late List<Object>? summaries;
  late String created;
  String? updated;
  @JsonKey(name: "stats:items")
  late StatsItems stats_items;

  factory GeoVisioCollection.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioCollectionFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioCollectionToJson(this);

  GeoVisioCollection();

  String? getThumbUrl() {
    var selfCollectionLink = links.firstWhere((link) => link.rel == "self");
    return '${selfCollectionLink.href}/thumb.jpg';
  }
}

@JsonSerializable()
class GeoVisioCollections {
  late List<GeoVisioLink> links;
  late List<GeoVisioCollection> collections;

  factory GeoVisioCollections.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioCollectionsFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioCollectionsToJson(this);

  GeoVisioCollections();
}

@JsonSerializable()
class GeoVisioCatalog {
  late String stac_version;
  List<String>? stac_extension;
  final String type = "Collection";
  late String id;
  String? title;
  late String description;
  late List<GeoVisioLink> links;

  factory GeoVisioCatalog.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioCatalogFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioCatalogToJson(this);

  GeoVisioCatalog();
}

@JsonSerializable()
class GeoVisioCollectionImportStatus {
  late String status;
  late List<StatusItem> items;

  factory GeoVisioCollectionImportStatus.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioCollectionImportStatusFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioCollectionImportStatusToJson(this);

  GeoVisioCollectionImportStatus();
}

@JsonSerializable()
class StatusItem {
  String? id;
  String? status;
  bool? processing_in_progress;
  int? rank;
  int? nb_errors;
  String? process_error;
  String? processed_at;

  factory StatusItem.fromJson(Map<String, dynamic> json) =>
      _$StatusItemFromJson(json);
  Map<String, dynamic> toJson() => _$StatusItemToJson(this);

  StatusItem();
}
