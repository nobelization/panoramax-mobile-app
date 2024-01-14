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

  Future goToCollectionCreationPage(){
    return Navigator.push(context,
        MaterialPageRoute(builder: (_) => CollectionCreationPage(imgList: _imgListCaptured))
    );
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      final XFile rawImage = await _cameraController.takePicture();
      debugPrint(rawImage.path);
      File imageFile = File(rawImage.path);

      int currentUnix = DateTime.now().millisecondsSinceEpoch;
      String fileFormat = imageFile.path.split('.').last;

      bool storagePermission = await Permission.storage.isGranted;
      bool mediaPermission = await Permission.accessMediaLocation.isGranted;
      bool manageExternalStoragePermission = await Permission.manageExternalStorage.isGranted;
      bool locationPermission = await Permission.location.isGranted;

      if (!storagePermission) {
        storagePermission = await Permission.storage.request().isGranted;
      }

      if (!mediaPermission) {
        mediaPermission =
        await Permission.accessMediaLocation.request().isGranted;
      }

      if (!manageExternalStoragePermission) {
        manageExternalStoragePermission = (await Permission.manageExternalStorage.request()).isGranted;
      }

      if (!locationPermission) {
        locationPermission = (await Permission.location.request()).isGranted;
      }

      bool isPermissionGranted = storagePermission && mediaPermission && manageExternalStoragePermission;

      if (isPermissionGranted) {
        final exif = FlutterExif.fromPath(rawImage.path);
        final currentLocation = await Geolocator.getCurrentPosition();
        await exif.setLatLong(currentLocation.latitude, currentLocation.longitude);
        await exif.setAltitude(currentLocation.altitude);
        await exif.saveAttributes();
        setState(() {
          _imgListCaptured.add(new File(rawImage.path));
        });
      } else {
        throw Exception("No permission to move file");
      }
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
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
                        )),
                  ]),
                )
            )
          ]
        );
  }
}