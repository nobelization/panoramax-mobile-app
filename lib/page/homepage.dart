part of panoramax;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<GeoVisioCollections?> futureCollections;

  @override
  void initState() {
    super.initState();
    futureCollections = CollectionsApi.INSTANCE.apiCollectionsGet();
  }

  Future<void> _createCollection() async {
    await availableCameras().then((value) => Navigator.push(context,
        MaterialPageRoute(builder: (_) => CapturePage(cameras: value)))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PanoramaxAppBar(context: context),
      body: RefreshIndicator (
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Text(
                  AppLocalizations.of(context)!.yourSequence,
                  style: GoogleFonts.nunito(
                    fontSize: 25,
                    fontWeight: FontWeight.w400
                  )
                )
              ),
              FutureBuilder<GeoVisioCollections?>(
                future: futureCollections,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!.collections.map((collection) => CollectionPreview(collection)).toList(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('An error occured'));
                  }
                  return const Center(child: CircularProgressIndicator());
                }
              )
            ]
          ),
        ),
        onRefresh: () async {
          setState(() {
            futureCollections = CollectionsApi.INSTANCE.apiCollectionsGet();
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createCollection,
        tooltip: AppLocalizations.of(context)!.createSequence_tooltip,
        child: const Icon(Icons.add),
      )
    );
  }
}