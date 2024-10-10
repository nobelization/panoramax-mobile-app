part of panoramax;

class SharedPictureManager extends WidgetsBindingObserver {
  SharedPictureManager._internal();

  static final SharedPictureManager _instance =
      SharedPictureManager._internal();

  factory SharedPictureManager() {
    return _instance;
  }

  late StreamSubscription _intentSub;
  List<SharedMediaFile>? _sharedFiles;

  @override
  void dispose() {
    _intentSub.cancel();
  }

  void listenSendingIntent() {
    print("function sending");
    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      print("listen ok");
      _sharedFiles = value;
      if (_sharedFiles != null && _sharedFiles!.isNotEmpty) {
        final fileList = sharedFilesToImages(_sharedFiles!);
        print("redirect file shared");
        GetIt.instance<NavigationService>()
            .pushTo(Routes.newSequenceSend, arguments: fileList);
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      print("listen ok");
      _sharedFiles = value;
      // Tell the library that we are done processing the intent.
      //ReceiveSharingIntent.instance.reset();
      if (_sharedFiles != null && _sharedFiles!.isNotEmpty) {
        final fileList = sharedFilesToImages(_sharedFiles!);
        GetIt.instance<NavigationService>()
            .pushTo(Routes.newSequenceSend, arguments: fileList);
      }
    });
  }

  List<File> sharedFilesToImages(List<SharedMediaFile> list) {
    return list
        .where((element) => isImage(element))
        .map((item) => File(item.path))
        .toList();
  }

  bool isImage(SharedMediaFile file) {
    final fileExtension = file.path.split('.').last.toLowerCase();
    return (fileExtension == 'jpg' ||
        fileExtension == 'jpeg' ||
        fileExtension == 'png' ||
        fileExtension == 'gif' ||
        fileExtension == 'bmp');
  }
}
