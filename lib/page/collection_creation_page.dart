part of panoramax;

class CollectionCreationPage extends StatefulWidget {
  const CollectionCreationPage({required this.imgList, super.key});

  final List<File> imgList;

  @override
  State<StatefulWidget> createState() {
    return CollectionCreationPageState();
  }
}

class CollectionCreationPageState extends State<CollectionCreationPage> {

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ]);
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

  void goToInstancePage() {
    GetIt.instance<NavigationService>().pushTo(Routes.instance, arguments: widget.imgList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BLUE,
        leading: BackButton(
     color: Colors.white
   ),
      ),
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
                      child: TextButton(
                        onPressed: goToInstancePage,
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                        child: Text(AppLocalizations.of(context)!
                            .newSequenceSendButton),
                      )),
              ],
            ),
          ),
        ));
  }
}