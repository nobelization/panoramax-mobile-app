part of panoramax;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    await availableCameras().then((availableCameras) =>
        context.push(Routes.newSequenceCapture, extra: availableCameras)
    );
  }
  
  Widget displayBody(isLoading) {
    if(isLoading)
      return LoaderIndicatorView();
    else if(geoVisionCollections == null)
      return UnkownErrorView();
    else if(geoVisionCollections!.collections.length != 0)
      return CollectionListView(collections: geoVisionCollections!.collections);
    else
      return NoElementView();
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
            body: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Semantics(
                          header: true,
                          child: Text(
                              AppLocalizations.of(context)!.yourSequence,
                              style: GoogleFonts.nunito(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w400
                              )
                          ),
                        )
                    ),
                    SizedBox(
                        height: 690,
                        child: displayBody(isLoading)
                    )
                  ]
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _createCollection,
              tooltip: AppLocalizations.of(context)!.createSequence_tooltip,
              child: const Icon(Icons.add),
            )
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
      shrinkWrap: true,
      physics: BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()
      ),
      itemBuilder: (BuildContext context, int index) {
        return CollectionPreview(collections[index]);
      }
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
              child: Text(AppLocalizations.of(context)!.loading)
          )
        ]
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
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w400
            )
          )
        )
      ]
    );
  }
}

class UnkownErrorView extends StatelessWidget {
  const UnkownErrorView({
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
              fontSize: 20,
              color: Colors.red,
              fontWeight: FontWeight.w400
            )
          )
        )
      ]
    );
  }
}