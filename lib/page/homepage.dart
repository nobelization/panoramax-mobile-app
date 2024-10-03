part of panoramax;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final sharedPictureManager = SharedPictureManager();

  @override
  void initState() {
    print("init homepage");
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    redirectUser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> redirectUser() async {
    print("redirectUser");
    final instance = await getInstance();
    //user is connected
    if (instance.isNotEmpty) {
      _goToSequence();
    } else {
      //user is disconnected
      await _createCollection();
    }
    sharedPictureManager.listenSendingIntent();
  }

  Future<void> _goToSequence() async {
    GetIt.instance<NavigationService>().pushReplacementTo(
        Routes.newSequenceUpload,
        arguments: List<File>.empty());
  }

  Future<void> _createCollection() async {
    print("createcollection");
    if (!await PermissionHelper.isPermissionGranted()) {
      await PermissionHelper.askMissingPermission();
    }
    availableCameras().then((availableCameras) =>
        GetIt.instance<NavigationService>().pushReplacementTo(
            Routes.newSequenceCapture,
            arguments: availableCameras));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PanoramaxAppBar(context: context), body: LoaderIndicatorView());
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
