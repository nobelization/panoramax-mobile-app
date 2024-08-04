part of panoramax;

class CapturePage extends StatefulWidget {
  const CapturePage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> with WidgetsBindingObserver {
  final List<AppLifecycleState> _stateHistoryList = <AppLifecycleState>[];
  late CameraController _cameraController;
  bool _isProcessing = false;
  bool _isRearCameraSelected = true;
  bool _isPermissionDialogOpen = false;
  final List<File> _imgListCaptured = [];

  int _burstDuration = 3; //in seconds
  bool _isBurstMode = false;
  bool _isBurstPlay = false;
  Timer? _timerBurst;

  Stream<Position>? _positionStream;
  Position? _currentPosition;
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 2, //The minimum distance (in meters) to trigger an update
  );
  double? _accuracy;

  late final GravityOrientationDetector _orientationDetector;
  var isPortraitOrientation = true;

  @override
  void dispose() {
    _cameraController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.initState();

    _orientationDetector = GravityOrientationDetector();
    _orientationDetector.init();

    startLocationUpdates();
    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState != null) {
      _stateHistoryList.add(WidgetsBinding.instance.lifecycleState!);
    }

    if (widget.cameras?.isNotEmpty ?? false) {
      initCamera(widget.cameras![0]);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startLocationUpdates();
    }
  }

  void startLocationUpdates() async {
    //check if GPS is enabled
    if (!await Geolocator.isLocationServiceEnabled()) {
      showGPSDialog();
      return;
    }

    Geolocator.checkPermission().then((permission) async {
      print(permission.toString());
      switch (permission) {
        case LocationPermission.denied:
        case LocationPermission.unableToDetermine:
        case LocationPermission.deniedForever:
          var result = await Geolocator.requestPermission();
          if (result == LocationPermission.deniedForever &&
              !_isPermissionDialogOpen) {
            await showPermissionDialog();
          }
          break;
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          if (_isPermissionDialogOpen) {
            Navigator.of(context).pop();
            _isPermissionDialogOpen = false;
          }
          _positionStream =
              Geolocator.getPositionStream(locationSettings: locationSettings);
          if (_positionStream != null) {
            _positionStream!.listen((Position position) {
              setState(() {
                _currentPosition = position;
                _accuracy = position.accuracy;
              });
            });
          }
          break;
        default:
          break;
      }
    });
  }

  void goToSettings() async {
    await Geolocator.openAppSettings();
  }

  void goToCollectionCreationPage() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    GetIt.instance<NavigationService>()
        .pushTo(Routes.newSequenceSend, arguments: _imgListCaptured);
  }

  Future takePicture() async {
    setState(() {
      _isProcessing = true;
    });
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await Future.wait(
        [
          getPictureFromCamera(),
        ],
      ).then((value) async {
        final XFile rawImage = value[0] as XFile;
        final Position currentLocation = _currentPosition!;
        await addExifTags(rawImage, currentLocation);
        addImageToList(rawImage);
      });
    } on CameraException catch (e) {
      debugPrint('Error occurred while taking picture: $e');
      return null;
    }
  }

  void takeBurstPictures() {
    if (_timerBurst != null) {
      stopBurstPictures();
    } else {
      startBurstPictures();
    }
    setState(() {
      _isBurstPlay = !_isBurstPlay;
    });
  }

  void stopBurstPictures() {
    if (_timerBurst != null) {
      _timerBurst!.cancel();
      _timerBurst = null;
    }
  }

  Future startBurstPictures() async {
    takePicture();
    _timerBurst = Timer.periodic(Duration(seconds: _burstDuration), (timer) {
      takePicture();
    });
  }

  void addImageToList(XFile rawImage) {
    setState(() {
      _imgListCaptured.add(File(rawImage.path));
      _isProcessing = false;
    });
  }

  Future<XFile> getPictureFromCamera() async {
    await _cameraController.setFlashMode(FlashMode.off);
    final XFile rawImage = await _cameraController.takePicture();
    debugPrint(rawImage.path);
    return rawImage;
  }

  Future<void> addExifTags(XFile rawImage, Position currentLocation) async {
    print("add exif tag : " +
        currentLocation.latitude.toString() +
        " " +
        currentLocation.longitude.toString());

    if (Platform.isIOS) {
      var exif = await Exif.fromPath(rawImage.path);
      await exif.writeAttributes({
        'GPSLatitude': currentLocation.latitude,
        'GPSLongitude': currentLocation.longitude,
        'GPSAltitude': currentLocation.altitude
      });
    } else {
      final exif = FlutterExif.fromPath(rawImage.path);
      await exif.setLatLong(
          currentLocation.latitude, currentLocation.longitude);
      await exif.setAltitude(currentLocation.altitude);
      await exif.saveAttributes();
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
      await _cameraController.setFocusMode(FocusMode.auto);
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras?.isEmpty ?? true) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(AppLocalizations.of(context)!.noCameraFoundError),
        ),
      );
    }
    return StreamBuilder(
      stream: _orientationDetector.orientationStream,
      builder: (context, orientation) {
        var beta = null;
        var alpha = null;
        if (orientation.hasData) {
          beta = orientation.data!.beta;
          alpha = orientation.data!.alpha.abs();
          if (beta > 0.8) {
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.landscapeRight]);
            isPortraitOrientation = false;
          } else if (beta < -0.8) {
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.landscapeLeft]);
            isPortraitOrientation = false;
          } else if (alpha > 0.3) {
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.portraitUp]);
            isPortraitOrientation = true;
          }
        }
        return Stack(children: [
          Positioned.fill(
            child: Container(
              color: BLUE, // Couleur d'arrière-plan
            ),
          ),
          cameraPreview(),
          accurancyComponent(),
          (!isPortraitOrientation)
              ? landscapeLayout(context)
              : portraitLayout(context),
          if (_isProcessing) processingLoader(context)
        ]);
      },
    );
  }

  Widget accurancyComponent() {
    return _accuracy == null
        ? Container()
        : Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            padding: EdgeInsets.all(8.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                Icons.location_on,
                size: 24,
                color: Colors.blue,
              ),
              SizedBox(width: 8),
              DefaultTextStyle(
                style: TextStyle(color: Colors.blue),
                child: Text(
                    "${_accuracy?.toStringAsFixed(2)} ${AppLocalizations.of(context)!.meters}"),
              )
            ]));
  }

  Widget createBurstButtons() {
    return Container(
        padding: EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: listBurstButtons(),
        ));
  }

  List<Widget> listBurstButtons() {
    return [
      Expanded(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextButton(
            onPressed: () => switchMode(false),
            child: Text(AppLocalizations.of(context)!.photo.toUpperCase()),
            style: _isBurstMode ? notSelectedButton() : selectedButton()),
        SizedBox(width: 10),
        TextButton(
            onPressed: () => switchMode(true),
            child: Text(AppLocalizations.of(context)!.sequence.toUpperCase()),
            style: _isBurstMode ? selectedButton() : notSelectedButton()),
      ])),
    ];
  }

  void switchMode(bool isBurstMode) {
    if (!isBurstMode) {
      stopBurstPictures();
    }
    setState(() {
      _isBurstMode = isBurstMode;
    });
  }

  ButtonStyle selectedTimeButton() {
    return TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white);
  }

  ButtonStyle notSelectedTimeButton() {
    return TextButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.transparent);
  }

  ButtonStyle selectedButton() {
    return TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue);
  }

  ButtonStyle notSelectedButton() {
    return TextButton.styleFrom(
        minimumSize: Size(80, 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        foregroundColor: Colors.white,
        side: BorderSide(width: 3, color: Colors.white));
  }

  Widget portraitLayout(BuildContext context) {
    return Stack(
      children: [
        _isBurstMode
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              )
            : Container(),
        Center(
          child: _isBurstMode ? askTurnDevice() : Container(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: listActionBar())),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: listBurstButtons()),
            )
          ]),
        ),
      ],
    );
  }

  List<Widget> listActionBar() {
    return [
      _imgListCaptured.isNotEmpty
          ? badges.Badge(
              position: badges.BadgePosition.bottomEnd(),
              badgeContent: Text('${_imgListCaptured.length}'),
              child: galleryButton(context))
          : galleryButton(context),
      (!_isBurstMode || !isPortraitOrientation) ? captureButton() : Spacer(),
      _imgListCaptured.isNotEmpty ? createSequenceButton(context) : Container(),
    ];
  }

  Widget actionBarPortrait() {
    return Container(
        padding: EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: listActionBar())),
          ],
        ));
  }

  Widget askTurnDevice() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.screen_rotation, size: 120.0, color: Colors.white),
          Padding(
              padding: EdgeInsets.all(50),
              child: Card(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(children: [
                        Icon(
                          Icons.info_outline,
                          color: BLUE,
                        ),
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .switchCameraRequired,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: BLUE,
                                      fontSize: 16,
                                    )))),
                      ]))))
        ]);
  }

  Widget landscapeLayout(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(30),
        width: MediaQuery.of(context).size.width,
        child: Stack(children: [
          createBurstButtons(),
          Container(
              padding: EdgeInsets.all(24),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: listActionBar(),
              ))
        ]));
  }

  Widget createSequenceButton(BuildContext context) {
    //return Expanded(
    /* child: Container(
            height: 60,
            width: 60,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.blue),*/
    return IconButton(
        padding: EdgeInsets.zero,
        iconSize: 30,
        icon: const Icon(Icons.send_outlined, color: Colors.white),
        onPressed: goToCollectionCreationPage,
        tooltip:
            AppLocalizations.of(context)!.createSequenceWithPicture_tooltip);
  }

  Widget captureButton() {
    return GestureDetector(
      child: IconButton(
          //if the GPS is not active, the capture button does nothing, otherwise we see what mode we are in
          onPressed: (_currentPosition == null)
              ? startLocationUpdates
              : _isBurstMode
                  ? takeBurstPictures
                  : takePicture,
          iconSize: 100,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_currentPosition == null ||
                        _accuracy == null ||
                        _accuracy! > 10)
                    ? Colors.grey
                    : _isBurstPlay
                        ? const Color.fromARGB(255, 89, 42, 39)
                        : Colors.white),
          ),
          tooltip: AppLocalizations.of(context)!.capture),
    );
  }

  Widget galleryButton(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        image: _imgListCaptured.isNotEmpty
            ? DecorationImage(
                image: FileImage(_imgListCaptured.last), fit: BoxFit.cover)
            : null,
      ),
    );
  }

  StatelessWidget cameraPreview() {
    return _cameraController.value.isInitialized
        ? Container(
            alignment: Alignment.center,
            child: CameraPreview(_cameraController))
        : Container(
            color: Colors.transparent,
            child: const Center(child: CircularProgressIndicator()),
          );
  }

  Positioned processingLoader(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Loader(
        message: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyLarge!,
          child: Container(),
        ),
        shadowBackground: true,
      ),
    );
  }

  Future<void> showGPSDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.gpsIsDisableTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)!.gpsIsDisableContent),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.common_close),
              onPressed: () {
                startLocationUpdates;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showPermissionDialog() async {
    _isPermissionDialogOpen = true;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.permissionDenied),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)!.permissionLocationRequired),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.common_close),
              onPressed: () {
                Navigator.of(context).pop();
                _isPermissionDialogOpen = false;
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.goToSettings),
              onPressed: () {
                goToSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
