import 'dart:io';
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  integrationDriver();
  await addPermission('android.permission.ACCESS_FINE_LOCATION');
  await addPermission('android.permission.CAMERA');
}

Future<void> addPermission(String permission) async {
  await Process.run(
    'adb',
    [
      'shell',
      'pm',
      'grant',
      'com.example.panoramax_mobile',
      permission
    ],
  );
}