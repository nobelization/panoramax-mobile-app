part of panoramax;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    redirectUser();
  }

  Future<void> redirectUser() async {
    final instance = await getInstance();
    //user is connected
    if (instance != null) {
      _goToSequence();
    } else {
      //user is disconnected
      _createCollection();
    }
  }

  void _goToSequence() {
    GetIt.instance<NavigationService>()
        .pushTo(Routes.newSequenceUpload, arguments: List<File>.empty());
  }

  Future<void> _createCollection() async {
    if (!await PermissionHelper.isPermissionGranted()) {
      await PermissionHelper.askMissingPermission();
    }
    await availableCameras().then((availableCameras) =>
        GetIt.instance<NavigationService>()
            .pushTo(Routes.newSequenceCapture, arguments: availableCameras));
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
