/// Device integration test (requires an emulator/device: `flutter test integration_test`).
/// Boots the real app on the real encrypted database and walks the first-run flow.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serenacash/app/app.dart';
import 'package:serenacash/features/home/home_screen.dart';
import 'package:serenacash/features/onboarding/onboarding_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'first run on device: encrypted database opens, onboarding completes, home shows "pode gastar"',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: SerenaCashApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      if (find.byType(OnboardingScreen).evaluate().isNotEmpty) {
        await tester.tap(find.text('Começar'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, '100000');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pular'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pular'));
        await tester.pumpAndSettle();
      }
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.textContaining('Pode gastar'), findsWidgets);
    },
  );
}
