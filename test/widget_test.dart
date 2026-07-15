import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nourishlink/main.dart';
import 'package:nourishlink/providers/auth_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Provide mock values for SharedPreferences to prevent runtime errors
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    // Pump the driver application inside a ProviderScope with correct overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const NourishLinkDriverApp(),
      ),
    );

    // Verify the NourishLinkDriverApp renders successfully
    expect(find.byType(NourishLinkDriverApp), findsOneWidget);
  });
}
