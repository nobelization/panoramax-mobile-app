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
  final CarouselController _carouselController = CarouselController();
  final collectionNameTextController = TextEditingController(
    text: 'My collection ${DateFormat(DATE_FORMATTER).format(DateTime.now())}',
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    collectionNameTextController.dispose();
    super.dispose();
  }

  void goToHomePage() {
    GetIt.instance<NavigationService>().pushTo(Routes.homepage, arguments: availableCameras);
  }

  void goToInstancePage() {
    GetIt.instance<NavigationService>().pushTo(Routes.instance, arguments: widget.imgList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PanoramaxAppBar(context: context),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(mainAxisSize: MainAxisSize.max, children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: AppLocalizations.of(context)!
                              .newSequenceNameField_placeholder,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        controller: collectionNameTextController,
                      )),
                  Flexible(
                    fit: FlexFit.tight,
                    child: CarouselSlider(
                      items: buildImageSlider(),
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 2.0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.imgList.asMap().entries.map(
                      (entry) {
                        return GestureDetector(
                          onTap: () =>
                              _carouselController.animateToPage(entry.key),
                          child: Container(
                            width: 12.0,
                            height: 12.0,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 4.0,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(
                                _current == entry.key ? 0.9 : 0.4,
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 64, 0, 32),
                      child: TextButton(
                        onPressed: goToInstancePage,
                        child: Text(AppLocalizations.of(context)!
                            .newSequenceSendButton),
                      )),
                ]),
              )
            ],
          ),
        ),
      ),
    );
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
      goToHomePage();
    }).catchError((error) => throw Exception(error));
  }

  List<Widget> buildImageSlider() {
    return widget.imgList
        .map(
          (item) => Container(
            margin: const EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              child: Stack(
                children: <Widget>[
                  Image.file(item, fit: BoxFit.cover, width: 1000.0),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(200, 0, 0, 0),
                            Color.fromARGB(0, 0, 0, 0)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                      child: Text(
                        'No. ${widget.imgList.indexOf(item) + 1} image',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }
}
