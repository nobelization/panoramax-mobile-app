part of panoramax;

class PermissionHelper {

  static Future<bool> isPermissionGranted() async {
    bool storagePermission = await Permission.storage.isGranted;
    bool mediaPermission = await Permission.accessMediaLocation.isGranted;
    bool manageExternalStoragePermission = await Permission.manageExternalStorage.isGranted;
    bool locationPermission = await Permission.location.isGranted;

    if (!storagePermission) {
      storagePermission = await Permission.storage.request().isGranted;
    }

    return locationPermission && mediaPermission && manageExternalStoragePermission;
  }

  static Future<void> askMissingPermission() async {
    bool storagePermission = await Permission.storage.isGranted;
    bool mediaPermission = await Permission.accessMediaLocation.isGranted;
    bool manageExternalStoragePermission = await Permission.manageExternalStorage.isGranted;
    bool locationPermission = await Permission.location.isGranted;
    bool cameraPermission = await Permission.camera.isGranted;

    if (!storagePermission) {
      storagePermission = await Permission.storage.request().isGranted;
    }

    if (!mediaPermission) {
      mediaPermission = await Permission.accessMediaLocation.request().isGranted;
    }

    if (!manageExternalStoragePermission) {
      manageExternalStoragePermission = (await Permission.manageExternalStorage.request()).isGranted;
    }

    if (!locationPermission) {
      locationPermission = (await Permission.location.request()).isGranted;
    }

    if (!cameraPermission) {
      cameraPermission = (await Permission.camera.request()).isGranted;
    }
  }
}
