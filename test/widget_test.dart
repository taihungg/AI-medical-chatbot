import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_care_bridge/main.dart';
import 'package:ai_care_bridge/services/database_service.dart';
import 'package:ai_care_bridge/state/app_state.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await dotenv.load(fileName: ".env");
    await DatabaseService.instance.init();
    await AppState.instance.restoreSession();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AICareBridgeApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
