import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:panoramax_mobile/main.dart';


/// Usage: the app is running with locale {'en'}
Future<void> theAppIsRunningWithLocale(WidgetTester tester, String selectedLanguage) async {
  try {
    GetIt.instance.registerLazySingleton<NavigationService>(() => NavigationService());
  } catch (e) {
    print(e);
  } finally {
    switch (selectedLanguage) {
      case "en":
        await tester.pumpWidget(const PanoramaxApp(selectedLocale: "en"));
      case "fr":
        await tester.pumpWidget(const PanoramaxApp(selectedLocale: "fr"));
      default:
        await tester.pumpWidget(const PanoramaxApp());
    }
    GetIt.instance<NavigationService>().pushTo(Routes.homepage);
  }
}
