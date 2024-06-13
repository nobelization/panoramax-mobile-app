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
      //startLocationUpdates();
      if (_isPermissionDialogOpen) {
        Navigator.of(context).pop();
        _isPermissionDialogOpen = false;
        print("test didChangeAppLifecycleState");
      }
      startLocationUpdates();
    }
  }

  void startLocationUpdates() async {
    //check if GPS is enabled
    if (!await Geolocator.isLocationServiceEnabled()) {
      showGPSDialog();
      return;
    }

    if (Platform.isIOS) {
      Geolocator.checkPermission().then((permission) async {
        print(permission.toString());
        switch (permission) {
          case LocationPermission.denied:
          case LocationPermission.unableToDetermine:
            await Geolocator.requestPermission();
            break;
          case LocationPermission.always:
          case LocationPermission.whileInUse:
            _positionStream = Geolocator.getPositionStream(
                locationSettings: locationSettings);
            if (_positionStream != null) {
              _positionStream!.listen((Position position) {
                setState(() {
                  _currentPosition = position;
                });
              });
            }
            break;
          case LocationPermission.deniedForever:
            showPermissionDialog();
            setState(() {
              _isPermissionDialogOpen = true;
            });
            break;
          default:
            break;
        }
      });
    } else {
      if (await PermissionHelper.isPermissionGranted()) {
        _positionStream =
            Geolocator.getPositionStream(locationSettings: locationSettings);

        if (_positionStream != null) {
          _positionStream!.listen((Position position) {
            setState(() {
              _currentPosition = position;
            });
          });
        }
      } else {
        if (await PermissionHelper.isLocationPermanentlyDenied()) {
          showPermissionDialog();
          setState(() {
            _isPermissionDialogOpen = true;
          });
        } else {
          await PermissionHelper.askMissingPermission();
          startLocationUpdates();
        }
      }
    }
  }

  void goToSettings() async {
    await Geolocator.openAppSettings();
  }

  void goToCollectionCreationPage() {
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
    print(currentLocation.latitude.toString() +
        " " +
        currentLocation.longitude.toString());

    var exif = await Exif.fromPath(rawImage.path);
    await exif.writeAttributes({
      'GPSLatitude': currentLocation.latitude,
      'GPSLongitude': currentLocation.longitude,
      'GPSAltitude': currentLocation.altitude
    });
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
      await _cameraController.setFocusMode(FocusMode.locked);
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
    return OrientationBuilder(
      builder: (context, orientation) {
        return Stack(children: [
          Positioned.fill(
            child: Container(
              color: BLUE, // Couleur d'arrière-plan
            ),
          ),
          cameraPreview(),
          orientation == Orientation.landscape
              ? landscapeLayout(context)
              : portraitLayout(context),
          if (_isProcessing) processingLoader(context)
        ]);
      },
    );
  }

  Widget createBurstButtons() {
    return Container(
        padding: EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextButton(
                  onPressed: () => switchMode(false),
                  child:
                      Text(AppLocalizations.of(context)!.photo.toUpperCase()),
                  style: _isBurstMode ? notSelectedButton() : selectedButton()),
              SizedBox(width: 10),
              TextButton(
                  onPressed: () => switchMode(true),
                  child: Text(
                      AppLocalizations.of(context)!.sequence.toUpperCase()),
                  style: _isBurstMode ? selectedButton() : notSelectedButton()),
            ])),
          ],
        ));
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
        //minimumSize: Size(80, 0),
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
        //backgroundColor: Colors.white,
        side: BorderSide(width: 3, color: Colors.white));
  }

  Widget portraitLayout(BuildContext context) {
    return Container(
        // set the height property to take the screen width
        width: MediaQuery.of(context).size.width,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
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
            ]));
  }

  Widget landscapeLayout(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(30),
        width: MediaQuery.of(context).size.width,
        child: Stack(children: [
          createBurstButtons(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: _imgListCaptured.isNotEmpty
                          ? badges.Badge(
                              position: badges.BadgePosition.bottomEnd(),
                              badgeContent: Text('${_imgListCaptured.length}'),
                              child: galleryButton(context))
                          : galleryButton(context))),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: captureButton())),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: _imgListCaptured.isNotEmpty
                          ? createSequenceButton(context)
                          : Container()))
            ],
          )
        ]));
  }

  Expanded createSequenceButton(BuildContext context) {
    return Expanded(
        child: Container(
            height: 60,
            width: 60,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
            child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 30,
                icon: const Icon(Icons.send_outlined, color: Colors.white),
                onPressed: goToCollectionCreationPage,
                tooltip: AppLocalizations.of(context)!
                    .createSequenceWithPicture_tooltip)));
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
                color: (_currentPosition == null)
                    ? Colors.grey
                    : _isBurstPlay
                        ? Colors.red
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
              child: Text("Close"),
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
              child: Text("Close"),
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
