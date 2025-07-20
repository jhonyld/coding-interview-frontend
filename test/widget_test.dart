// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:coding_interview_frontend/features_modules/calculator/presentation/pages/home_page.dart';
import 'package:coding_interview_frontend/features_modules/calculator/presentation/bloc/currency_provider.dart';
import 'package:coding_interview_frontend/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('HomePage renders and displays UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CurrencyProvider(),
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
          home: const HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Crypto Currency Calculator'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField), findsNWidgets(2));
    expect(find.byType(TextFormField), findsOneWidget);
  });
}
