part of panoramax;

class UploadPicturesPage extends StatefulWidget {
  const UploadPicturesPage({required this.imgList, super.key});

  final List<File> imgList;

  @override
  State<StatefulWidget> createState() => _UploadPicturesState();
}

class _UploadPicturesState extends State<UploadPicturesPage> {
  int _uploadedImagesCount = 0;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    uploadImages();
  }

  Future<void> uploadImages() async {
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final collectionId = await createCollection();
      await sendPictures(collectionId);
      setState(() {
        _uploadedImagesCount = widget.imgList.length;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isUploading = false;
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<String> createCollection() async {
    try {
      final collectionName = DateFormat('y_M_d_H_m_s').format(DateTime.now());
      final collection = await CollectionsApi.INSTANCE
          .apiCollectionsCreate(newCollectionName: collectionName);
      if (collection == null) {
        throw Exception(AppLocalizations.of(context)!.newCollectionFail);
      }
      return collection.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPictures(String collectionId) async {
    for (var i = 0; i < widget.imgList.length; i++) {
      await CollectionsApi.INSTANCE.apiCollectionsUploadPicture(
        collectionId: collectionId,
        position: i + 1,
        pictureToUpload: widget.imgList[i],
      );
    }
  }

  void goToCapture() {
    GetIt.instance<NavigationService>().pushTo(Routes.newSequenceCapture);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BLUE,
      body: Center(
        child: _isUploading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text(
                      style: TextStyle(color: Colors.white),
                      AppLocalizations.of(context)!.newCollectionLoading(
                          _uploadedImagesCount / widget.imgList.length)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_errorMessage != null)
                    Text(AppLocalizations.of(context)!
                        .newCollectionError(_errorMessage.toString())),
                  Text(
                      style: TextStyle(color: Colors.white),
                      AppLocalizations.of(context)!.newCollectionUploadSuccess),
                  ElevatedButton(
                    onPressed: () {
                      goToCapture();
                    },
                    child:
                        Text(AppLocalizations.of(context)!.newCollectionBack),
                  ),
                ],
              ),
      ),
    );
  }
}
