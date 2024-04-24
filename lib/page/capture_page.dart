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
    context.push(Routes.newSequenceSend, extra: _imgListCaptured);
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
    print(currentLocation.latitude.toString() + " " + currentLocation.longitude.toString());
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
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
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
                    alignment: Alignment.centerRight, child: captureButton())),
            Expanded(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: createSequenceButton(context)))
          ],
        ));
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
      onTap: takePicture,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      ),
    );
  }

  Widget galleryButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_imgListCaptured.isEmpty) return; //Return if no image
        goToCollectionCreationPage();
      },
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          image: _imgListCaptured.isNotEmpty
              ? DecorationImage(
                  image: FileImage(_imgListCaptured.last), fit: BoxFit.cover)
              : null,
        ),
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
          child: Text(
            AppLocalizations.of(context)!.waitDuringProcessing,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        shadowBackground: true,
      ),
    );
  }
}
