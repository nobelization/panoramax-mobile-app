import 'package:flutter_test/flutter_test.dart';
import 'package:panoramax_mobile/main.dart';

/// Usage: the app is running with locale {'en'}
Future<void> theAppIsRunningWithLocale(WidgetTester tester, String selectedLanguage) async {
  switch (selectedLanguage) {
    case "en":
      await tester.pumpWidget(const PanoramaxApp(selectedLocale: "en"));
      break;
    case "fr":
      await tester.pumpWidget(const PanoramaxApp(selectedLocale: "fr"));
      break;
    default:
      await tester.pumpWidget(const PanoramaxApp());
  }
}
