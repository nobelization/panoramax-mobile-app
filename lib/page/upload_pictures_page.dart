part of panoramax;

class UploadPicturesPage extends StatefulWidget {
  const UploadPicturesPage({required this.imgList, super.key});

  final List<File> imgList;

  @override
  State<StatefulWidget> createState() => _UploadPicturesState();
}

class _UploadPicturesState extends State<UploadPicturesPage> {
  late bool isLoading;
  GeoVisioCatalog? sequences;
  Map<GeoVisioLink, GeoVisioCollectionImportStatus> mapStatus = Map();

  @override
  void initState() {
    super.initState();
    isLoading = true;
    uploadImages();
    getMyCollections();
  }

  Future<void> getMyCollections() async {
    GeoVisioCatalog? refreshedSequences;
    setState(() {
      isLoading = true;
    });
    try {
      refreshedSequences = await CollectionsApi.INSTANCE.getMeCatalog();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        sequences = refreshedSequences;
        getStatusOfSequences();
      });
    }
  }

  Future<void> getStatusOfSequences() async {
    Map<GeoVisioLink, GeoVisioCollectionImportStatus> mapRefresh = Map();
    setState(() {
      isLoading = true;
    });
    try {
      List<Future<Null>>? futures = sequences?.links
          .where((sequence) => sequence.rel == "child")
          .map((sequence) async {
        var geovisioStatus = await CollectionsApi.INSTANCE
            .getGeovisioStatus(collectionId: sequence.id!);

        mapRefresh[sequence] = geovisioStatus;
      }).toList();
      await Future.wait(futures!.cast<Future<dynamic>>());
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        mapStatus = mapRefresh;
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
      return SequencesListView(mapStatus: mapStatus);
    } else {
      return const NoElementView();
    }
  }

  Future<void> uploadImages() async {
    final collectionId = await createCollection();
    await sendPictures(collectionId);
  }

  Future<String> createCollection() async {
    try {
      final collectionName = DateFormat('y_M_d_H_m_s').format(DateTime.now());
      final collection = await CollectionsApi.INSTANCE
          .apiCollectionsCreate(newCollectionName: collectionName);
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

  Future<void> goToCapture() async {
    await availableCameras().then((availableCameras) =>
        GetIt.instance<NavigationService>()
            .pushTo(Routes.newSequenceCapture, arguments: availableCameras));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        displacement: 250,
        strokeWidth: 3,
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: () async {
          setState(() {
            isLoading = true;
            getMyCollections();
          });
        },
        child: Scaffold(
          appBar: PanoramaxAppBar(context: context),
          body: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Semantics(
                  header: true,
                  child: Text(AppLocalizations.of(context)!.mySequences,
                      style: GoogleFonts.nunito(
                          fontSize: 25, fontWeight: FontWeight.w400)),
                ),
              ),
              Expanded(
                child: displayBodySequences(isLoading),
              ),
            ],
          ),
        ));
  }
}

class SequencesListView extends StatelessWidget {
  const SequencesListView({
    super.key,
    required this.mapStatus,
  });

  final Map<GeoVisioLink, GeoVisioCollectionImportStatus> mapStatus;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mapStatus.length,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemBuilder: (BuildContext context, int index) {
        GeoVisioLink key = mapStatus.keys.elementAt(index);
        GeoVisioCollectionImportStatus value =
            mapStatus.values.elementAt(index);
        if (key.geovisio_status != "hidden") {
          return SequenceCard(key, value);
        } else {
          return Container();
        }
      },
    );
  }
}
