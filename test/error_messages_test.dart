import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/l10n/app_localizations.dart';
import 'package:pawlife/l10n/error_messages.dart';
import 'package:pawlife/services/api_client.dart';
import 'package:pawlife/services/auth_service.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final pt = lookupAppLocalizations(const Locale('pt'));

  test('errores de Firebase se traducen por código', () {
    const e = AuthException(
      'Correo o contraseña incorrectos.',
      code: 'wrong-password',
    );
    expect(authErrorText(en, e), 'Incorrect email or password.');
    expect(authErrorText(pt, e), 'E-mail ou senha incorretos.');
  });

  test('un código desconocido conserva el mensaje original', () {
    const e = AuthException('Mensaje del servidor', code: 'otro');
    expect(authErrorText(en, e), 'Mensaje del servidor');
  });

  test('errores de red del cliente se traducen; los del servidor no', () {
    const offline = ApiException('x', code: 'client-offline');
    expect(apiErrorText(en, offline), contains('Check your internet'));
    const server = ApiException('Texto del backend', code: 'VALIDATION');
    expect(apiErrorText(en, server), 'Texto del backend');
  });

  test('plural de edad por idioma', () {
    expect(en.ageDays(1), '1 day');
    expect(en.ageDays(3), '3 days');
    expect(pt.relDaysAgo(2), 'há 2 dias');
  });
}
