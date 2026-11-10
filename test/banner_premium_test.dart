import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/views/widgets/banner_premium.dart';

void main() {
  testWidgets('el banner invita a Premium y responde al toque', (tester) async {
    var toques = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: BannerPremium(onTap: () => toques++),
          ),
        ),
      ),
    );
    expect(find.text('Pasate a Premium'), findsOneWidget);
    expect(find.textContaining('sin límite'), findsOneWidget);
    await tester.tap(find.byType(BannerPremium));
    await tester.pump();
    expect(toques, 1);
  });
}
