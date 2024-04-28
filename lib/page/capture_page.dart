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

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.cameras?.isNotEmpty ?? false) {
      initCamera(widget.cameras![0]);
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
      if (await PermissionHelper.isPermissionGranted()) {
        await Future.wait(
          [
            getPictureFromCamera(),
            Geolocator.getCurrentPosition(),
          ],
        ).then((value) async {
          final XFile rawImage = value[0] as XFile;
          final Position currentLocation = value[1] as Position;
          await addExifTags(rawImage, currentLocation);
          addImageToList(rawImage);
        });
      } else {
        await PermissionHelper.askMissingPermission();
        takePicture();
      }
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
            ),
          ),
        ),
        if (_isProcessing) processingLoader(context)
      ],
    );
  }

  Widget createBurstButtons() {
    return Container(
        padding: EdgeInsets.all(100),
        height: MediaQuery.of(context).size.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () => switchMode(false),
                child: Text("Photo".toUpperCase()),
                style: _isBurstMode ? notSelectedButton() : selectedButton()),
            TextButton(
                onPressed: () => switchMode(true),
                child: Text("Rafale".toUpperCase()),
                style: _isBurstMode ? selectedButton() : notSelectedButton()),
            timeButton()
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

  TextButton timeButton() {
    return TextButton(
        onPressed: () => (),
        child: RichText(
          text: TextSpan(children: [
            WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(Icons.photo_camera)),
            TextSpan(text: "3/s", style: TextStyle(color: Colors.blue)),
          ]),
        ),
        style: selectedTimeButton(),);
  }

ButtonStyle selectedTimeButton() {
    return TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white);
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

  Expanded switchCameraButton(BuildContext context) {
    return Expanded(
      child: IconButton(
          padding: EdgeInsets.zero,
          iconSize: 30,
          icon: Icon(
              _isRearCameraSelected
                  ? CupertinoIcons.switch_camera
                  : CupertinoIcons.switch_camera_solid,
              color: Colors.white),
          onPressed: () {
            setState(() => _isRearCameraSelected = !_isRearCameraSelected);
            initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
          },
          tooltip: AppLocalizations.of(context)!.switchCamera),
    );
  }

  Expanded createSequenceButton(BuildContext context) {
    return Expanded(
        child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 30,
            icon: const Icon(Icons.send_outlined, color: Colors.white),
            onPressed: goToCollectionCreationPage,
            tooltip: AppLocalizations.of(context)!
                .createSequenceWithPicture_tooltip));
  }

  Widget imageCart(IconButton cartIcon) {
    return _imgListCaptured.isNotEmpty
        ? badges.Badge(
            badgeContent: Text('${_imgListCaptured.length}'),
            child: cartIcon,
          )
        : cartIcon;
  }

  Positioned captureButton(double height, BuildContext context) {
    return Positioned(
        bottom: height,
        left: 0,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: height,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: IconButton(
                  onPressed: _isBurstMode ? takeBurstPictures : takePicture,
                  iconSize: 100,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.circle_outlined, color: Colors.white),
                  tooltip: AppLocalizations.of(context)!.capture),
            ),
          ]),
        ));
  }

  StatelessWidget cameraPreview() {
    return _cameraController.value.isInitialized
        ? CameraPreview(_cameraController)
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
