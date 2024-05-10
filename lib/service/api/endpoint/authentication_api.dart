part of panoramax.api;

class AuthenticationApi {
  static final AuthenticationApi INSTANCE = new AuthenticationApi();

  Future<GeoVisioToken> apiTokensGet(List<Cookie> cookies) async {
  final url = Uri.https("panoramax.$API_HOSTNAME.fr", '/api/users/me/tokens');

  final response = await http.get(url, headers: {'Cookie': 'session=.eJw9jEEOgjAQRa9iZm0TWlpw2OlFzNAOsYnMGChsCHe3ceHu5b2ffwDFqJsUGA7ICQYgF_vRYjLjxMF4S5VaRtOEPvjOT8zNDa4gNHNd399Z-PJQES7VKm3l9fz9OOs6xIB_-1l0z4mX2nSd4Ty_A8Ilzg.ZjePXw.kuxoHaI3me2znBGIQKml6G6QxPQ;'});

  if (response.statusCode == 200) {
    final decodedJson = json.decode(response.body) as List;
    final geoVisioToken = GeoVisioToken.fromJson(decodedJson[0]);
    return geoVisioToken;
  } else {
    throw Exception('${response.statusCode} - ${response.reasonPhrase}');
  }
}

  Future<GeoVisioJWTToken> apiTokenGet({required String tokenId}) async {
    // create path and map variables
    var url =  Uri.https("panoramax.$API_HOSTNAME.fr", '/api/users/me/tokens/${tokenId}');

    var response = await http.get(url, headers: {'Cookie': 'session=.eJw9jEEOgjAQRa9iZm0TWlpw2OlFzNAOsYnMGChsCHe3ceHu5b2ffwDFqJsUGA7ICQYgF_vRYjLjxMF4S5VaRtOEPvjOT8zNDa4gNHNd399Z-PJQES7VKm3l9fz9OOs6xIB_-1l0z4mX2nSd4Ty_A8Ilzg.ZjePXw.kuxoHaI3me2znBGIQKml6G6QxPQ;'});

    if (response.statusCode >= 200) {
      var geoVisioJWTToken =
          GeoVisioJWTToken.fromJson(json.decode(response.body));
      return geoVisioJWTToken;
    } else {
      throw Exception('${response.statusCode} - ${response.body}');
    }
  }
}
