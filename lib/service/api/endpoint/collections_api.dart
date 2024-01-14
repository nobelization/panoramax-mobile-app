part of panoramax.api;

class CollectionsApi {

  static final CollectionsApi INSTANCE = new CollectionsApi();

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


  Future<GeoVisioCollection> apiCollectionsCreate({ required String newCollectionName }) async {
    var url = API_IS_HTTPS ?
      Uri.https(API_HOSTNAME, '/api/collections') :
      Uri.http(API_HOSTNAME, '/api/collections');

    var request = http.MultipartRequest('POST', url)
      ..fields['title'] = '${newCollectionName}';
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if(response.statusCode >= 200) {
      return GeoVisioCollection.fromJson(json.decode(response.body));
    } else {
      throw new Exception('${response.statusCode} - ${response.body}');
    }
  }

  Future<void> apiCollectionsUploadPicture({ required String collectionId, required int position, required  File pictureToUpload}) async {
    var url = API_IS_HTTPS ?
    Uri.https(API_HOSTNAME, '/api/collections/${collectionId}/items') :
    Uri.http(API_HOSTNAME, '/api/collections/${collectionId}/items');

    var request = http.MultipartRequest('POST', url)
      ..fields['position'] = '${position}'
      ..files.add(await http.MultipartFile.fromPath(
          'picture', pictureToUpload.path));
    var response = await request.send();
    if(response.statusCode >= 200) {
      return;
    } else {
      throw new Exception('${response.statusCode} - ${response.reasonPhrase}');
    }
  }
}
