part of panoramax;

class UploadPicturesPage extends StatefulWidget {
  const UploadPicturesPage({required this.imgList, super.key});

  final List<File> imgList;

  @override
  State<StatefulWidget> createState() {
    return _UploadPicturesState();
  }
}

class _UploadPicturesState extends State<UploadPicturesPage> {
   @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  Future<String> createCollection() async {
    var collection = await CollectionsApi.INSTANCE.apiCollectionsCreate(newCollectionName: "2024_05_10");
    return collection.id;
  }

  void sendPictures(String collectionId) async {
    for (var i = 0; i < widget.imgList.length; i++) {
      var img = widget.imgList[i];
      await CollectionsApi.INSTANCE.apiCollectionsUploadPicture(collectionId: collectionId, position: i, pictureToUpload: img);
    }
  }
}