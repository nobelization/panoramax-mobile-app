part of panoramax.api;

class AuthenticationApi {
  static final AuthenticationApi INSTANCE = new AuthenticationApi();

  Future<GeoVisioToken> apiTokensGet(List<Cookie> cookies) async {
    final instance = await getInstance();
    final url = Uri.https("panoramax.$instance.fr", '/api/users/me/tokens');

    var session = null;
    for (var cookie in cookies) {
      if (cookie.name == "session") {
        session = 'session=${cookie.value}';
      }
    }

    final response = await http.get(url, headers: {'cookie': session});

    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body) as List;
      final geoVisioToken = GeoVisioToken.fromJson(decodedJson[0]);
      return geoVisioToken;
    } else {
      throw Exception('${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  Future<GeoVisioJWTToken> apiTokenGet(
      String tokenId, List<Cookie> cookies) async {
    // create path and map variables
    final instance = await getInstance();
    var url =
        Uri.https("panoramax.$instance.fr", '/api/users/me/tokens/${tokenId}');

    var session = null;
    for (var cookie in cookies) {
      if (cookie.name == "session") {
        session = 'session=${cookie.value}';
      }
    }

    final response = await http.get(url, headers: {'cookie': session});

    if (response.statusCode >= 200 && response.statusCode < 400) {
      var geoVisioJWTToken =
          GeoVisioJWTToken.fromJson(json.decode(response.body));
      return geoVisioJWTToken;
    } else {
      throw Exception('${response.statusCode} - ${response.body}');
    }
  }
}
