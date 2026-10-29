// l10n/error_messages.dart
//
// Los servicios lanzan excepciones con un mensaje de respaldo y, cuando es un
// error propio del cliente, un código estable. Aquí se traducen según el
// idioma activo. Los mensajes que escribe el servidor se muestran tal cual.

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/map_capture_service.dart';
import '../services/photo_service.dart';
import '../services/privacy_export_service.dart';
import 'app_localizations.dart';

String authErrorText(AppLocalizations t, AuthException e) => switch (e.code) {
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
  // Códigos estables del servidor: se traducen; lo demás conserva su mensaje.
  'PLAN_PET_LIMIT' => t.apiPlanPetLimit,
  'ACCOUNT_DELETING' => t.apiAccountDeleting,
  'ACCOUNT_UNAVAILABLE' => t.apiAccountUnavailable,
  'RATE_LIMITED' => t.apiRateLimited,
  'PHOTO_PROCESSOR_UNAVAILABLE' => t.apiPhotoProcessor,
  'INVALID_PHOTO' => t.apiInvalidPhoto,
  'DOCUMENT_TOO_LARGE' ||
  'EXPORT_TOO_LARGE' ||
  'EXPORT_RECORD_TOO_LARGE' ||
  'DELETION_TREE_TOO_LARGE' => t.apiTooLarge,
  'EXPORT_EXPIRED' || 'EXPORT_CANCELLED' => t.apiExportExpired,
  'ACCOUNT_BILLING_REVIEW_REQUIRED' => t.apiBillingReview,
  'PRIVACY_CONTACT_UNAVAILABLE' ||
  'PRIVACY_REVIEW_UNAVAILABLE' => t.apiPrivacyUnavailable,
  'FIRESTORE_UNAVAILABLE' ||
  'FIRESTORE_INVALID_OPERATION' ||
  'FIRESTORE_PERMISSION_ERROR' ||
  'DEPENDENCY_RESPONSE_INVALID' ||
  'COMMIT_RESULT_UNKNOWN' => t.apiServiceBusy,
  'DEVICE_OWNERSHIP_CONFLICT' || 'DEVICE_TOKEN_CHANGED' => t.apiDeviceConflict,
  // El servidor escribe sus mensajes en español. En otro idioma, un error sin
  // código conocido se muestra genérico en vez de mezclar idiomas.
  _ when !t.localeName.startsWith('es') =>
    (e.statusCode ?? 500) >= 500
        ? t.apiServiceBusy
        : t.apiHttpStatus('${e.statusCode ?? ''}'),
  _ => e.message,
};

String photoErrorText(AppLocalizations t, PhotoException e) => switch (e.code) {
  'open-failed' => t.photoOpenFailed,
  'too-large' => t.photoTooLarge,
  'too-large-after' => t.photoTooLargeAfter,
  'invalid-type' => t.photoInvalidType,
  'invalid-or-large' => t.photoInvalidOrLarge,
  'unreadable' => t.photoUnreadable,
  _ => e.message,
};

String exportErrorText(AppLocalizations t, PrivacyExportException e) =>
    switch (e.code) {
      'cancelled' => t.exportCancelled,
      'session-changed' => t.exportSessionChanged,
      'too-big' => t.exportTooBig,
      'start-failed' => t.exportStartFailed,
      'invalid-response' => t.exportInvalidResponse,
      'incomplete' => t.exportIncompleteService,
      _ => e.message,
    };

String captureErrorText(AppLocalizations t, MapCaptureException e) =>
    switch (e.code) {
      'not-ready' => t.captureNotReady,
      'unreadable' => t.captureUnreadable,
      'too-large' => t.captureTooLarge,
      _ => e.message,
    };

/// Error de ubicación del paseo: `code` viene del RouteViewModel.
String locationErrorText(
  AppLocalizations t, {
  required String? code,
  required String? fallback,
}) => switch (code) {
  'gps-off' => t.locGpsOff,
  'denied' => t.locDenied,
  'denied-forever' => t.locDeniedForever,
  'location-failed' => t.locFailed(
    fallback?.split(': ').skip(1).join(': ') ?? '',
  ),
  _ => fallback ?? t.locationErrorDefault,
};
