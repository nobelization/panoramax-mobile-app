import 'package:flutter_test/flutter_test.dart';
import 'package:panoramax_mobile/main.dart';

Future<void> theAppIsRunning(WidgetTester tester) async {
  await tester.pumpWidget(const PanoramaxApp());
}
