import 'package:json_annotation/json_annotation.dart';

part 'geo_visio_auth.g.dart';

@JsonSerializable()
class GeoVisioUserAuth {
  late String id;
  late String name;
  late String oauth_id;
  late String oauth_provider;

  factory GeoVisioUserAuth.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioUserAuthFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioUserAuthToJson(this);

  GeoVisioUserAuth();
}

@JsonSerializable()
class GeoVisioTokensLink {
  late String href;
  late String rel;
  late String type;

  factory GeoVisioTokensLink.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioTokensLinkFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioTokensLinkToJson(this);

  GeoVisioTokensLink();
}

@JsonSerializable()
class GeoVisioToken {
  late String description;
  late String generated_at;
  late String id;
  late List<GeoVisioTokensLink> links;

  factory GeoVisioToken.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioTokenFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioTokenToJson(this);

  GeoVisioToken();
}

@JsonSerializable()
class GeoVisioTokens {
  late List<GeoVisioToken> tokens;

  factory GeoVisioTokens.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioTokensFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioTokensToJson(this);

  GeoVisioTokens();
}

@JsonSerializable()
class GeoVisioJWTToken {
  late String description;
  late String generated_at;
  late String id;
  late String jwt_token;

  factory GeoVisioJWTToken.fromJson(Map<String, dynamic> json) =>
      _$GeoVisioJWTTokenFromJson(json);
  Map<String, dynamic> toJson() => _$GeoVisioJWTTokenToJson(this);

  GeoVisioJWTToken();
}