part of panoramax;

class PermissionHelper {

  static Future<bool> isPermissionGranted() async {
    if (Platform.isIOS) {
    bool locationPermission = await Permission.locationWhenInUse.isGranted;
    return locationPermission;
    } else {
      bool cameraPermission = await Permission.camera.isGranted;
    bool locationPermission = await Permission.location.isGranted;
    return locationPermission && cameraPermission;
    }
    
  }

  static Future<bool> isLocationPermanentlyDenied() async {
    return await Permission.location.status.isPermanentlyDenied;
  }

  static Future<void> askMissingPermission() async {
    bool locationPermission = await Permission.location.isGranted;
    bool cameraPermission = await Permission.camera.isGranted;

    if (!locationPermission) {
      locationPermission = (await Permission.location.request()).isGranted;
    }

    if (!cameraPermission) {
      cameraPermission = (await Permission.camera.request()).isGranted;
    }
  }
}
