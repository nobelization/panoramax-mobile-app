part of panoramax;

class CapturePage extends StatefulWidget {
  const CapturePage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;
  List<File> _imgListCaptured = [];

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  void goToCollectionCreationPage(){
    context.push(Routes.newSequenceSend, extra: _imgListCaptured);
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      if (await PermissionHelper.isPermissionGranted()) {
        XFile rawImage = await getPictureFromCamera();
        await addExifTags(rawImage);
        addImageToList(rawImage);
      } else {
        await PermissionHelper.askMissingPermission();
      }
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  void addImageToList(XFile rawImage) {
    setState(() {
      var capturedPicture = new File(rawImage.path);
      _imgListCaptured.add(capturedPicture);
    });
  }

  Future<XFile> getPictureFromCamera() async {
    await _cameraController.setFlashMode(FlashMode.off);
    final XFile rawImage = await _cameraController.takePicture();
    debugPrint(rawImage.path);
    return rawImage;
  }

  Future<void> addExifTags(XFile rawImage) async {
    final exif = FlutterExif.fromPath(rawImage.path);
    final currentLocation = await Geolocator.getCurrentPosition();
    await exif.setLatLong(currentLocation.latitude, currentLocation.longitude);
    await exif.setAltitude(currentLocation.altitude);
    await exif.saveAttributes();
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high, enableAudio: false);
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
    var height = MediaQuery.of(context).size.height * 0.12;
    var cartIcon = IconButton(
      onPressed: () {
      },
      iconSize: 30,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.add_shopping_cart_outlined, color: Colors.white),
    );
    return Stack(
          children: [
            (_cameraController.value.isInitialized)
                ? CameraPreview(_cameraController)
                : Container(
                color: Colors.transparent,
                child: const Center(child: CircularProgressIndicator())),
            new Positioned(
                bottom: height,
                left: 0,
                child: new Container(
                  width: MediaQuery.of(context).size.width,
                  height: height,
                  decoration: new BoxDecoration(color: Colors.transparent),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(
                        child: IconButton(
                          onPressed: takePicture,
                          iconSize: 100,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.circle_outlined, color: Colors.white),
                          tooltip: AppLocalizations.of(context)!.capture
                        )),
                  ]),
                )
            ),
            new Positioned(
                bottom: 0,
                left: 0,
                child: new Container(
                  width: MediaQuery.of(context).size.width,
                  height: height,
                  decoration: new BoxDecoration(color: Colors.black),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 30,
                          icon: Icon(
                              _isRearCameraSelected
                                  ? CupertinoIcons.switch_camera
                                  : CupertinoIcons.switch_camera_solid,
                              color: Colors.white),
                          onPressed: () {
                            setState(
                                    () => _isRearCameraSelected = !_isRearCameraSelected);
                            initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
                          },
                          tooltip: AppLocalizations.of(context)!.switchCamera
                    )),
                    _imgListCaptured.length > 0 ? badges.Badge(
                      badgeContent: Text('${_imgListCaptured.length}'),
                      child: cartIcon,
                    ): cartIcon,
                    Expanded(
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 30,
                          icon: Icon(Icons.send_outlined,
                              color: Colors.white),
                          onPressed: goToCollectionCreationPage,
                          tooltip: AppLocalizations.of(context)!.createSequenceWithPicture_tooltip
                        )),
                  ]),
                )
            )
          ]
        );
  }
}