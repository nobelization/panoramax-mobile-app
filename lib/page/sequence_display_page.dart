part of panoramax;

class DisplaySequence extends StatefulWidget {
  const DisplaySequence({super.key});

  @override
  State<DisplaySequence> createState() => _DisplaySequenceState();
}

class _DisplaySequenceState extends State<DisplaySequence> {
  late bool isLoading;
  GeoVisioCollections? geoVisionCollections;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getCollections();
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
    await availableCameras().then(
      (availableCameras) => context.push(Routes.newSequenceCapture),
    );
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
