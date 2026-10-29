import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/l10n/error_messages.dart';
import 'package:pawlife/services/api_client.dart';
import 'package:pawlife/services/pawlife_repository.dart';
import 'package:pawlife/views/premium_screen.dart';

class PremiumFixture implements PawLifeRepository {
  PremiumFixture(this.state);
  Map<String, dynamic> state;
  @override
  Future<Map<String, dynamic>> fetchPremium() async => state;
  @override
  Future<Map<String, dynamic>> comprarPremiumDePrueba(String plan) async =>
      state = {
        'activo': true,
        'estado': 'activo',
        'venceEn': '2030-01-15T12:00:00+00:00',
        'fuentes': {'manual': false, 'pago': false, 'prueba': true},
      };
  @override
  Future<void> cancelarPremiumDePrueba() async => state = {
    'activo': false,
    'estado': 'inactivo',
    'venceEn': null,
    'fuentes': {'manual': false, 'pago': false, 'prueba': false},
  };
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
    // Con Premium real no se ofrece comprar.
    expect(find.text('Suscribirme'), findsNothing);
    expect(find.text('Sin límite'), findsNWidgets(2));
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
    expect(find.text('More to care better'), findsOneWidget);
    expect(find.text('Up to 2'), findsOneWidget);
    expect(find.text('Unlimited'), findsNWidgets(2));
    expect(find.text('1 style'), findsOneWidget);
    expect(find.text('3 styles'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('nothing is charged'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('nothing is charged'), findsOneWidget);

    // Compra simulada: elegir mensual, confirmar y queda Premium de prueba.
    await tester.tap(find.text('Monthly'));
    await tester.pump();
    await tester.ensureVisible(find.text('Subscribe'));
    await tester.tap(find.text('Subscribe'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm subscription'), findsOneWidget);
    await tester.tap(find.text('Confirm purchase'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('Test Premium active until'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Test Premium active until'), findsOneWidget);
    expect(find.text('Subscribe'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Cancel test subscription'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Cancel test subscription'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Subscribe'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Subscribe'), findsOneWidget);
  });

  test('códigos estables se traducen; los desconocidos quedan genéricos', () {
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
      apiErrorText(
        en,
        const ApiException(
          'No se pudo realizar la operación solicitada.',
          code: 'FIRESTORE_INVALID_OPERATION',
          statusCode: 400,
        ),
      ),
      "The service isn't available right now. Try again in a few minutes.",
    );
    expect(
      apiErrorText(
        en,
        const ApiException('Texto del servidor', code: 'OTRO', statusCode: 503),
      ),
      "The service isn't available right now. Try again in a few minutes.",
    );
  });
}
