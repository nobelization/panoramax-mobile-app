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
  late String updated;
  @JsonKey(name: "stats:items")
  late StatsItems stats_items;

  factory GeoVisioCollection.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioCollectionFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioCollectionToJson(this);

  GeoVisioCollection();

  String? getThumbUrl() {
    var selfCollectionLink = this.links.firstWhere((link) => link.rel == "self");
    if(selfCollectionLink == null) {
      return null;
    }
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