// l10n/error_messages.dart
//
// Los servicios lanzan excepciones con un mensaje de respaldo y, cuando es un
// error propio del cliente, un código estable. Aquí se traducen según el
// idioma activo. Los mensajes que escribe el servidor se muestran tal cual.

import '../services/api_client.dart';
import '../services/auth_service.dart';
import 'app_localizations.dart';

String authErrorText(AppLocalizations t, AuthException e) =>
    switch (e.code) {
      'invalid-email' => t.errInvalidEmail,
      'user-disabled' => t.authUserDisabled,
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' => t.authBadCredentials,
      'email-already-in-use' => t.authEmailInUse,
      'weak-password' => t.authWeakPassword,
      'account-exists-with-different-credential' => t.authAccountExists,
      'requires-recent-login' => t.authRecentLogin,
      'user-mismatch' => t.authUserMismatch,
      'too-many-requests' => t.authTooMany,
      'network-request-failed' => t.authNoInternet,
      'operation-not-allowed' => t.authNotEnabled,
      'sin-sesion' => t.authNoSession,
      'sesion-cambio' => t.authSessionChanged,
      'cancelado' => t.authCancelled,
      'password-required' => t.errEnterCurrentPassword,
      'google-account' => t.authGoogleAccount,
      'password-fields' => t.authPasswordFields,
      'google-email' => t.googleEmailNote,
      'same-email' => t.authSameEmail,
      'signup-failed' => t.authSignupFailed,
      'signin-failed' => t.authSigninFailed,
      'google-signin-failed' => t.authGoogleSigninFailed,
      'google-unavailable' => t.authGoogleUnavailable,
      'push-disconnect' => t.authPushDisconnect,
      'google-interrupted' => t.googleInterrupted,
      'google-uiUnavailable' => t.googleUiUnavailable,
      'google-clientConfigurationError' ||
      'google-providerConfigurationError' => t.googleConfigError,
      'google-userMismatch' => t.googleUserMismatch,
      'google-no-token' || 'no-token' => t.authGeneric,
      _ => e.message,
    };

String apiErrorText(AppLocalizations t, ApiException e) => switch (e.code) {
  'client-session-changed' => t.apiSessionChanged,
  'client-invalid-response' => t.apiInvalidResponse,
  'client-list-too-large' => t.apiListTooLarge,
  'client-timeout' => t.apiTimeout,
  'client-offline' => t.apiOffline,
  'client-http-status' => t.apiHttpStatus('${e.statusCode ?? ''}'),
  _ => e.message,
};
