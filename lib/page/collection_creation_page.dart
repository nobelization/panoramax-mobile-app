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

  final Map<File, bool> _selectedFiles = {};

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    for (var file in widget.imgList) {
      _selectedFiles[file] = true;
    }
    super.initState();
  }

  void goToInstancePage() {
    final list = _selectedFiles.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    GetIt.instance<NavigationService>()
        .pushTo(Routes.instance, arguments: list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: BLUE,
          leading: BackButton(color: Colors.white),
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
                        child: Align(
                            child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var file in _selectedFiles.keys)
                              PictureItem(file),
                          ],
                        )))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 64, 0, 32),
                    child: TextButton(
                      onPressed: goToInstancePage,
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white)),
                      child: Text(
                          AppLocalizations.of(context)!.newSequenceSendButton),
                    )),
              ],
            ),
          ),
        ));
  }

  Widget PictureItem(File file) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
            height: 80,
            child: Image.file(
              file,
              fit: BoxFit.cover,
            )),
        SizedBox(
          height: 24.0,
          width: 24.0,
          child: Checkbox(
            value: _selectedFiles[file],
            onChanged: (value) {
              setState(() {
                _selectedFiles[file] = value!;
              });
            },
          ),
        )
      ],
    );
  }
}
