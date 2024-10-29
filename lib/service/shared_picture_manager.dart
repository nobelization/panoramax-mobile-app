part of panoramax;

class SharedPictureManager extends WidgetsBindingObserver {
  static const MethodChannel _channel =
      MethodChannel("app.panoramax.beta/data"); //the same as in MainActivity.kt
  SharedPictureManager._internal();
  List<File> listFiles = [];

  static final SharedPictureManager _instance =
      SharedPictureManager._internal();

  factory SharedPictureManager() {
    return _instance;
  }

  late StreamSubscription _intentSub;

  @override
  void dispose() {
    _intentSub.cancel();
  }

  void listenSendingIntent() {
    _channel.setMethodCallHandler((MethodCall methodCall) async {
      //'sendUri' must be the same as in MainActivity.kt
      if (methodCall.method == 'sendUri') {
        final List<Object?> uris = methodCall.arguments;

        listFiles = uris
            .where((element) => isImage(element))
            .map((item) => File(item!.toString()))
            .toList();

        GetIt.instance<NavigationService>()
            .pushTo(Routes.newSequenceSend, arguments: listFiles);
      }
    });
  }

  bool isImage(Object? filePath) {
    if (filePath == null || !(filePath is String)) {
      return false;
    }
    final fileExtension = filePath.split('.').last.toLowerCase();
    return (fileExtension == 'jpg' ||
        fileExtension == 'jpeg' ||
        fileExtension == 'png' ||
        fileExtension == 'gif' ||
        fileExtension == 'bmp');
  }
}
