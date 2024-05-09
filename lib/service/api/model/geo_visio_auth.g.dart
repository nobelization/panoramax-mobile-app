// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_visio_auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoVisioUserAuth _$GeoVisioUserAuthFromJson(Map<String, dynamic> json) =>
    GeoVisioUserAuth()
      ..id = json['id'] as String
      ..name = json['name'] as String
      ..oauth_id = json['oauth_id'] as String
      ..oauth_provider = json['oauth_provider'] as String;

Map<String, dynamic> _$GeoVisioUserAuthToJson(GeoVisioUserAuth instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'oauth_id': instance.oauth_id,
      'oauth_provider': instance.oauth_provider,
    };

GeoVisioTokensLink _$GeoVisioTokensLinkFromJson(Map<String, dynamic> json) =>
    GeoVisioTokensLink()
      ..href = json['href'] as String
      ..rel = json['rel'] as String
      ..type = json['type'] as String;

Map<String, dynamic> _$GeoVisioTokensLinkToJson(GeoVisioTokensLink instance) =>
    <String, dynamic>{
      'href': instance.href,
      'rel': instance.rel,
      'type': instance.type,
    };

GeoVisioToken _$GeoVisioTokenFromJson(Map<String, dynamic> json) =>
    GeoVisioToken()
      ..description = json['description'] as String
      ..generated_at = json['generated_at'] as String
      ..id = json['id'] as String
      ..links = (json['links'] as List<dynamic>)
          .map((e) => GeoVisioTokensLink.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$GeoVisioTokenToJson(GeoVisioToken instance) =>
    <String, dynamic>{
      'description': instance.description,
      'generated_at': instance.generated_at,
      'id': instance.id,
      'links': instance.links,
    };

GeoVisioTokens _$GeoVisioTokensFromJson(Map<String, dynamic> json) =>
    GeoVisioTokens()
      ..tokens = (json['tokens'] as List<dynamic>)
          .map((e) => GeoVisioToken.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$GeoVisioTokensToJson(GeoVisioTokens instance) =>
    <String, dynamic>{
      'tokens': instance.tokens,
    };

GeoVisioJWTToken _$GeoVisioJWTTokenFromJson(Map<String, dynamic> json) =>
    GeoVisioJWTToken()
      ..description = json['description'] as String
      ..generated_at = json['generated_at'] as String
      ..id = json['id'] as String
      ..jwt_token = json['jwt_token'] as String;

Map<String, dynamic> _$GeoVisioJWTTokenToJson(GeoVisioJWTToken instance) =>
    <String, dynamic>{
      'description': instance.description,
      'generated_at': instance.generated_at,
      'id': instance.id,
      'jwt_token': instance.jwt_token,
    };
