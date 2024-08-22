part of panoramax;

class UploadPicturesPage extends StatefulWidget {
  const UploadPicturesPage({required this.imgList, super.key});

  final List<File> imgList;

  @override
  State<StatefulWidget> createState() => _UploadPicturesState();
}

class _UploadPicturesState extends State<UploadPicturesPage> {
  late bool isLoading;
  GeoVisioCollection? sequences;
  late int sequenceCount;
  String? collectionId;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    sequenceCount = widget.imgList.length;
    if (sequenceCount > 0) {
      uploadImages();
    }
    getMyCollections();
  }

  Future<void> getMyCollections() async {
    GeoVisioCollection? refreshedSequences;
    setState(() {
      isLoading = true;
    });
    try {
      refreshedSequences = await CollectionsApi.INSTANCE.getMeCollection();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        sequences = refreshedSequences;
        isLoading = false;
      });
    }
  }

  Widget displayBodySequences(isLoading) {
    if (isLoading) {
      return const LoaderIndicatorView();
    } else if (sequences == null || sequences?.links == null) {
      return const UnknownErrorView();
    } else if (sequences!.links.isNotEmpty) {
      return SequencesListView(
          links: sequences!.links,
          collectionId: collectionId,
          lastSequenceCount: sequenceCount);
    } else {
      return const NoElementView();
    }
  }

  Future<void> uploadImages() async {
    await createCollection();
    await sendPictures();
  }

  Future<void> createCollection() async {
    try {
      final collectionName = DateFormat('y_M_d_H_m_s').format(DateTime.now());
      final collection = await CollectionsApi.INSTANCE
          .apiCollectionsCreate(newCollectionName: collectionName);
      setState(() {
        collectionId = collection.id;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPictures() async {
    if (collectionId == null) {
      return;
    }
    for (var i = 0; i < widget.imgList.length; i++) {
      await CollectionsApi.INSTANCE.apiCollectionsUploadPicture(
        collectionId: collectionId!,
        position: i + 1,
        pictureToUpload: widget.imgList[i],
      );
    }
  }

  Future<void> goToCapture() async {
    if (!await PermissionHelper.isPermissionGranted()) {
      await PermissionHelper.askMissingPermission();
    }
    await availableCameras().then((availableCameras) =>
        GetIt.instance<NavigationService>()
            .pushTo(Routes.newSequenceCapture, arguments: availableCameras));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: RefreshIndicator(
            displacement: 250,
            strokeWidth: 3,
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            onRefresh: () async {
              setState(() {
                getMyCollections();
              });
            },
            child: Scaffold(
              appBar: PanoramaxAppBar(context: context, backEnabled: false),
              body: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                  AppLocalizations.of(context)!.mySequences,
                                  style: GoogleFonts.nunito(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w400)),
                            ),
                            FloatingActionButton(
                                onPressed: goToCapture,
                                child: Icon(Icons.add_a_photo),
                                shape: CircleBorder(),
                                mini: true,
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                tooltip: AppLocalizations.of(context)!
                                    .createSequence_tooltip)
                          ])),
                  Expanded(
                    child: displayBodySequences(isLoading),
                  ),
                ],
              ),
            )));
  }
}

class SequencesListView extends StatelessWidget {
  const SequencesListView(
      {super.key,
      required this.links,
      required this.collectionId,
      required this.lastSequenceCount});

  final List<GeoVisioLink> links;
  final String? collectionId;
  final int lastSequenceCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: links.length,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemBuilder: (BuildContext context, int index) {
        if (links[index].rel == "child") {
          return SequenceCard(links[index],
              sequenceCount:
                  links[index].id == collectionId ? lastSequenceCount : null);
        } else {
          return Container();
        }
      },
    );
  }
}
