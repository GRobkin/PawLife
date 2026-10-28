import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/l10n/error_messages.dart';
import 'package:pawlife/services/api_client.dart';
import 'package:pawlife/services/pawlife_repository.dart';
import 'package:pawlife/views/premium_screen.dart';

class PremiumFixture implements PawLifeRepository {
  PremiumFixture(this.state);
  final Map<String, dynamic> state;
  @override
  Future<Map<String, dynamic>> fetchPremium() async => state;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(PawLifeRepository repo, String lang) => MaterialApp(
  locale: Locale(lang),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: PremiumScreen(repository: repo),
);

void main() {
  testWidgets('muestra Premium activo con su fuente, sin compras en la app', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        PremiumFixture({
          'activo': true,
          'estado': 'activo',
          'venceEn': '2030-01-15T12:00:00+00:00',
          'fuentes': {'manual': true, 'pago': false},
        }),
        'es',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Premium activo hasta'), findsOneWidget);
    expect(find.text('Concedido por el equipo de PawLife'), findsOneWidget);
    expect(find.text('Suscripción'), findsNothing);
    expect(find.textContaining('Todavía no hay compras'), findsOneWidget);
  });

  testWidgets('sin Premium y en inglés', (tester) async {
    await tester.pumpWidget(
      _app(
        PremiumFixture({
          'activo': false,
          'estado': 'inactivo',
          'venceEn': null,
          'fuentes': {'manual': false, 'pago': false},
        }),
        'en',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No active Premium'), findsOneWidget);
    expect(find.textContaining('no in-app purchases'), findsOneWidget);
  });

  test('códigos estables del servidor se traducen; los desconocidos no', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final pt = lookupAppLocalizations(const Locale('pt'));
    expect(
      apiErrorText(en, const ApiException('x', code: 'ACCOUNT_DELETING')),
      'Your account is being deleted.',
    );
    expect(
      apiErrorText(pt, const ApiException('x', code: 'RATE_LIMITED')),
      contains('Muitas alterações'),
    );
    expect(
      apiErrorText(en, const ApiException('Texto del servidor', code: 'OTRO')),
      'Texto del servidor',
    );
  });
}
