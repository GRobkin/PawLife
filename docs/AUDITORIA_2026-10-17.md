# Verificación Flutter — 17/10/2026

Estado: correcciones locales revisables; no afirmar entrega E2E completa.
El informe integral está en el repositorio compañero apipaw,
`docs/AUDITORIA_2026-10-17.md`.

## Corregido

- Arranque Web: ReceivePort del foreground service móvil causaba pantalla blanca
  antes de runApp. Inicialización restringida a Android/iOS. Reproducido antes y
  revisado después en navegador release: bienvenida, login y validación vacía.
- ApiClient: timeout incluye cuerpo además de cabeceras. Nueva prueba reproduce
  un cuerpo que nunca termina; devuelve ApiException en vez de quedar esperando.
- AuthService: Google Web usa signInWithPopup de Firebase, sin intentar el método
  nativo no soportado. Compila y pasa análisis; OAuth real sigue sin probar.
- Calorías: se quitó el valor fijo distancia × 60; se muestra no disponible hasta
  disponer de un modelo apropiado validado. No es US27 implementado.
- .gitignore: protege archivos de entorno, cuentas de servicio y firma Android.
- pub get actualizó registradores desktop de plugins ya declarados; no se
  añadieron dependencias ni se modificó el lockfile.

## Verificaciones

`flutter pub get`, `flutter analyze --no-pub`, `flutter test --no-pub --coverage`
(7 pruebas), `flutter build web --release --no-pub` y `git diff --check` pasan.
El build conserva un aviso CupertinoIcons; no es un error de compilación.
LCOV: 321/859 líneas, 37,37 %, solo archivos cargados por la suite (12), no toda
la app. No se midió cobertura integral E2E.
Consulta OSV: 131 paquetes hosted del lockfile, sin avisos devueltos para esas
versiones. No comprende SDK/Gradle/CocoaPods ni garantiza seguridad total.

## Pendiente / no verificable

- No hay Android SDK ni teléfono conectado. No se verificaron APK/AAB, cámara,
  GPS apagando pantalla, compartir a otra app, permisos o push reales.
- iOS necesita macOS/Xcode/dispositivo. Windows necesita Visual Studio C++.
- Release Android usa firma debug e identidad de ejemplo: bloquea distribución.
- La autenticación real, cambio de sesión, CRUD y persistencia contra Firestore
  requieren cuentas/entorno de prueba. El usuario pidió dejar esas pruebas de
  dispositivo pendientes; no se crearon cuentas ni datos de producción.
- Falta probar entrada por push con app terminada y soporte real de paseo web.
- Términos/privacidad no abren documentos. Metadatos web aún son de plantilla.
- US15/18/21/27/28/29 siguen abiertos; US20 está excluido. US19 Web requiere
  aceptación autenticada. No hay pagos, selector es/en/pt ni dark mode nuevos.
- El backend exige ahora login reciente para borrar cuenta (300 segundos).
  Actualizar solo el ID token no renueva auth_time: volver a ingresar si lo pide.

Se conserva el diseño existente. Sin push, merge ni despliegue. Código apto para
revisión con pendientes declarados, no para etiquetar como entrega completa.
