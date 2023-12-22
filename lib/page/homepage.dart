part of panoramax;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionsApi collectionsApi = CollectionsApi();
  late Future<GeoVisioCollections?> futureCollections;

  @override
  void initState() {
    super.initState();
    futureCollections = collectionsApi.apiCollectionsGet();
  }

  Future<void> _createCollection() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: RefreshIndicator (
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Text(
                  AppLocalizations.of(context)!.yourCollection,
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
                    return Text('An error occured');
                  }
                  return const CircularProgressIndicator();
                }
              )
            ]
          ),
        ),
        onRefresh: () async {
          setState(() {});
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createCollection,
        tooltip: AppLocalizations.of(context)!.createCollection_tooltip,
        child: const Icon(Icons.add),
      )
    );
  }
}