/// Identificador con el que la app se presenta ante los servicios de mapas
/// (OpenStreetMap pide que cada app se identifique). Debe coincidir con el
/// applicationId de Android y el bundle de iOS cuando se fije el definitivo.
const kAppPackageId = 'com.example.flutter_application_1';

/// Versión del APK. La pone el workflow con `--dart-define=APP_VERSION=<tag>`;
/// en una compilación local queda "dev". Se muestra en la pantalla de acceso y
/// en la franja de errores para saber qué APK está instalado.
const kAppVersion = String.fromEnvironment('APP_VERSION', defaultValue: 'dev');
