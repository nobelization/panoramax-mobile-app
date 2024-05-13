part of panoramax;

class CapturePage extends StatefulWidget {
  const CapturePage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  late CameraController _cameraController;
  bool _isProcessing = false;
  bool _isRearCameraSelected = true;
  final List<File> _imgListCaptured = [];

  int _burstDuration = 3; //in seconds
  bool _isBurstMode = false;
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
    super.dispose();
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();

    startLocationUpdates();

    if (widget.cameras?.isNotEmpty ?? false) {
      initCamera(widget.cameras![0]);
    }
  }

  void startLocationUpdates() async {
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
      await PermissionHelper.askMissingPermission();
      startLocationUpdates();
    }
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
    final exif = FlutterExif.fromPath(rawImage.path);
    await exif.setLatLong(currentLocation.latitude, currentLocation.longitude);
    await exif.setAltitude(currentLocation.altitude);
    await exif.saveAttributes();
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
/*
    var height = MediaQuery.of(context).size.height * 0.12;
    var cartIcon = IconButton(
      onPressed: () {},
      iconSize: 30,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.add_shopping_cart_outlined, color: Colors.white),
    );
    return Stack(
      children: [
        cameraPreview(),
        captureButton(height, context),
        createBurstButtons(),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: height,
            decoration: const BoxDecoration(color: Colors.black),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                switchCameraButton(context),
                imageCart(cartIcon),
                createSequenceButton(context),
              ],
*/
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
                  child: Text("Photo".toUpperCase()),
                  style: _isBurstMode ? notSelectedButton() : selectedButton()),
              SizedBox(width: 10),
              TextButton(
                  onPressed: () => switchMode(true),
                  child: Text("Rafale".toUpperCase()),
                  style: _isBurstMode ? selectedButton() : notSelectedButton()),
            ])),
            Expanded(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              timeButton(3),
              SizedBox(width: 10),
              timeButton(10),
            ]))
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

  void setDurationBurst(int duration) {
    if (_burstDuration != duration) {
      stopBurstPictures();
    }
    setState(() {
      _burstDuration = duration;
    });
  }

  TextButton timeButton(int timeInSeconds) {
    bool isSelected = timeInSeconds == _burstDuration;

    return TextButton(
        onPressed: () => setDurationBurst(timeInSeconds),
        child: Row(
          children: [
            Icon(Icons.photo_camera),
            SizedBox(
                width: 5), // Espacement de 8 points entre l'icône et le texte
            Text(
              "$timeInSeconds/s",
              style: TextStyle(color: isSelected ? Colors.blue : Colors.white),
            ),
          ],
        ),
        style: isSelected ? selectedTimeButton() : notSelectedTimeButton());
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
        foregroundColor: Colors.blueGrey,
        //backgroundColor: Colors.white,
        side: BorderSide(width: 3, color: Colors.blueGrey));
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
/*<<<<<<< HEAD
        child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 30,
            icon: const Icon(Icons.send_outlined, color: Colors.white),
            onPressed: goToCollectionCreationPage,
            tooltip: AppLocalizations.of(context)!
                .createSequenceWithPicture_tooltip));
=======*/
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
          onPressed: _isBurstMode ? takeBurstPictures : takePicture,
          iconSize: 100,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_timerBurst == null) ? Colors.white : Colors.red),
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
}
