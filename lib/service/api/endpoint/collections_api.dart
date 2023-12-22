part of panoramax.api;

class CollectionsApi {
  ///
  /// List available collections
  ///
  Future<GeoVisioCollections?> apiCollectionsGet({ int? limit, String? format, List<int>? bbox, String? filter, String? datetime }) async {
    // query params
    Map<String, String> queryParams = {};
    if(limit != null) {
      queryParams.putIfAbsent("limit", limit as String Function());
    }
    if(format != null) {
      queryParams.putIfAbsent("format", format as String Function());
    }
    if(bbox != null) {
      queryParams.putIfAbsent("bbox", bbox as String Function());
    }
    if(filter != null) {
      queryParams.putIfAbsent("filter", filter as String Function());
    }
    if(datetime != null) {
      queryParams.putIfAbsent("datetime", datetime as String Function());
    }

    // create path and map variables
    var url = API_IS_HTTPS ?
              Uri.https(API_HOSTNAME, '/api/collections', queryParams) :
              Uri.http(API_HOSTNAME, '/api/collections', queryParams);

    var response = await http.get(url);
    if(response.statusCode >= 200) {
      return GeoVisioCollections.fromJson(json.decode(response.body));
    } else {
      throw new Exception('${response.statusCode} - ${response.body}');
    }
  }
}
