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
        var invalidCount = 0;

        listFiles = uris
            .where((element) => isImage(element))
            .map((item) => File(item!.toString()))
            .toList();

        for (var file in listFiles) {
          final exif = await Exif.fromPath(file.path);
          final gpsLatLong = await exif.getLatLong();
          final date = await exif.getOriginalDate();
          if (gpsLatLong == null || date == null) {
            invalidCount++;
          }
        }
        ;

        if (invalidCount == 0) {
          GetIt.instance<NavigationService>()
              .pushTo(Routes.newSequenceSend, arguments: listFiles);
        } else {
          showAlertDialog();
        }
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

void showAlertDialog() async {
  showDialog(
      context: scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.common_error),
          content: Text(AppLocalizations.of(context)!.errorShare),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.common_ok))
          ],
        );
      });
}
