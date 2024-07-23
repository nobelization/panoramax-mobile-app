part of panoramax;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool isLoading;
  GeoVisioCollections? geoVisionCollections;

  late StreamSubscription _intentSub;
  List<SharedMediaFile>? _sharedFiles;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getCollections();
    listenSendingIntent();
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  void listenSendingIntent() {
    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      _sharedFiles = value;
      if (_sharedFiles != null && _sharedFiles!.isNotEmpty) {
        final fileList = sharedFilesToImages(_sharedFiles!);
        GetIt.instance<NavigationService>()
            .pushTo(Routes.newSequenceSend, arguments: fileList);
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      _sharedFiles = value;
      // Tell the library that we are done processing the intent.
      ReceiveSharingIntent.instance.reset();
      if (_sharedFiles != null && _sharedFiles!.isNotEmpty) {
        final fileList = sharedFilesToImages(_sharedFiles!);
        GetIt.instance<NavigationService>()
            .pushTo(Routes.newSequenceSend, arguments: fileList);
      }
    });
  }

  List<File> sharedFilesToImages(List<SharedMediaFile> list) {
    return list
        .where((element) => isImage(element))
        .map((item) => File(item.path))
        .toList();
  }

  bool isImage(SharedMediaFile file) {
    final fileExtension = file.path.split('.').last.toLowerCase();
    return (fileExtension == 'jpg' ||
        fileExtension == 'jpeg' ||
        fileExtension == 'png' ||
        fileExtension == 'gif' ||
        fileExtension == 'bmp');
  }

  Future<void> getCollections() async {
    GeoVisioCollections? refreshedCollections;
    setState(() {
      isLoading = true;
    });
    try {
      refreshedCollections = await CollectionsApi.INSTANCE.apiCollectionsGet();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
        geoVisionCollections = refreshedCollections;
      });
    }
  }

  Future<void> _createCollection() async {
    if (!await PermissionHelper.isPermissionGranted()) {
      await PermissionHelper.askMissingPermission();
    }
    await availableCameras().then((availableCameras) =>
        GetIt.instance<NavigationService>()
            .pushTo(Routes.newSequenceCapture, arguments: availableCameras));
  }

  Widget displayBody(isLoading) {
    if (isLoading) {
      return const LoaderIndicatorView();
    } else if (geoVisionCollections == null) {
      return const UnknownErrorView();
    } else if (geoVisionCollections!.collections.isNotEmpty) {
      return CollectionListView(collections: geoVisionCollections!.collections);
    } else {
      return const NoElementView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: 250,
      strokeWidth: 3,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: () async {
        setState(() {
          getCollections();
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
                child: Text(AppLocalizations.of(context)!.yourSequence,
                    style: GoogleFonts.nunito(
                        fontSize: 25, fontWeight: FontWeight.w400)),
              ),
            ),
            Expanded(
              child: displayBody(isLoading),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createCollection,
          tooltip: AppLocalizations.of(context)!.createSequence_tooltip,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class CollectionListView extends StatelessWidget {
  const CollectionListView({
    super.key,
    required this.collections,
  });

  final List<GeoVisioCollection> collections;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: collections.length,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemBuilder: (BuildContext context, int index) {
        return CollectionPreview(collections[index]);
      },
    );
  }
}

class LoaderIndicatorView extends StatelessWidget {
  const LoaderIndicatorView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Loader(
            message: Text(AppLocalizations.of(context)!.loading),
          ),
        ),
      ],
    );
  }
}

class NoElementView extends StatelessWidget {
  const NoElementView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            AppLocalizations.of(context)!.emptyError,
            style: GoogleFonts.nunito(
                fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }
}

class UnknownErrorView extends StatelessWidget {
  const UnknownErrorView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            AppLocalizations.of(context)!.unknownError,
            style: GoogleFonts.nunito(
                fontSize: 20, color: Colors.red, fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }
}
