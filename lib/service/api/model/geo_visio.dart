import 'package:json_annotation/json_annotation.dart';

part 'geo_visio.g.dart';

@JsonSerializable()
class GeoVisioLink {
  late String href;
  late String rel;
  String? type;
  String? title;
  String? method;
  Object? headers;
  Object? body;
  bool? merge;
  factory GeoVisioLink.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioLinkFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioLinkToJson(this);

  GeoVisioLink();
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
class GeoVisioCollection {
  late String stac_version;
  List<String>? stac_extension;
  final String type = "Collection";
  late String id;
  String? title;
  late String description;
  List<String>? keywords;
  late String license;
  Object? extent;
  List<GeoVisioProvider>? providers;
  late List<GeoVisioLink> links;
  late List<GeoVisioLink> summaries;
  factory GeoVisioCollection.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioCollectionFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioCollectionToJson(this);

  GeoVisioCollection();
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