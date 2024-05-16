part of panoramax;

class CollectionCreationPage extends StatefulWidget {
  const CollectionCreationPage({required this.imgList, super.key});

  final List<File> imgList;

  @override
  State<StatefulWidget> createState() {
    return _CarouselWithIndicatorState();
  }
}

class _CarouselWithIndicatorState extends State<CollectionCreationPage> {
  int _current = 0;
  final collectionNameTextController = TextEditingController(
    text: 'My collection ${DateFormat(DATE_FORMATTER).format(DateTime.now())}',
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    collectionNameTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
    super.initState();
  }

  void goToCapturePage() async {
    await availableCameras().then(
      (availableCameras) =>
          GetIt.instance<NavigationService>().pushTo(Routes.newSequenceCapture, arguments: availableCameras),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: BLUE,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 40, bottom: 40),
            child: Column(
              children: [
                Text(
                    AppLocalizations.of(context)!.nameSerie(
                        DateFormat(DATE_FORMATTER).format(DateTime.now())),
                    style: const TextStyle(
                      color: Colors.white,
                    )),
                Expanded(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.count(
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(10.0),
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          childAspectRatio: (16 / 9),
                          children: widget.imgList
                              .map(
                                (item) => GridTile(
                                  child: Stack(
                                    children: <Widget>[
                                      Image.file(
                                        item,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 64, 0, 32),
                  child: LoadingBtn(
                    height: 50,
                    borderRadius: 8,
                    animate: true,
                    color: Colors.blue,
                    width: MediaQuery.of(context).size.width * 0.45,
                    loader: Container(
                      padding: const EdgeInsets.all(10),
                      width: 40,
                      height: 40,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.newSequenceSendButton,
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: (startLoading, stopLoading, btnState) async {
                      if (_formKey.currentState!.validate() &&
                          btnState == ButtonState.idle) {
                        startLoading();
                        // call your network api
                        await submitNewCollection(
                          collectionName: collectionNameTextController.text,
                          picturesToUpload: widget.imgList,
                        );
                        stopLoading();
                      }
                    },
                  ),
                ),
                GestureDetector(
                    onTap: goToCapturePage,
                    child: Container(
                        padding: const EdgeInsets.only(bottom: 1.0),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1.0, color: Colors.white))),
                        child: Text(
                          AppLocalizations.of(context)!.newSequenceCancel,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ))),
              ],
            ),
          ),
        ));
  }

  Future<void> submitNewCollection(
      {required String collectionName, required List<File> picturesToUpload}) {
    return CollectionsApi.INSTANCE
        .apiCollectionsCreate(newCollectionName: collectionName)
        .then((createdCollection) {
      debugPrint('Created Collection $createdCollection');
      picturesToUpload.asMap().forEach((index, pictureToUpload) async {
        await CollectionsApi.INSTANCE
            .apiCollectionsUploadPicture(
                collectionId: createdCollection.id,
                position: index + 1,
                pictureToUpload: pictureToUpload)
            .then((value) {
          debugPrint('Picture ${index + 1} uploaded');
        }).catchError((error) => throw Exception(error));
      });
      goToCapturePage();
    }).catchError((error) => throw Exception(error));
  }
}
