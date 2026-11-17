# Primer APK de PawLife

Estado: **preparado, no compilado**. En este equipo no hay Android SDK, así que
el APK no se generó ni se probó en un teléfono.

## Antes de publicar (bloqueantes)

1. **Identificador de la app.** Hoy es `com.example.flutter_application_1`
   (`android/app/build.gradle.kts`, `lib/config/app_identity.dart`). Cambiarlo
   después de publicar crea una app distinta. Elegir el definitivo ahora
   (por ejemplo `uy.pawlife.app`) y actualizar a la vez:
   - `applicationId` y `namespace` en `build.gradle.kts` y el paquete Kotlin,
   - `kAppPackageId`,
   - la app Android registrada en Firebase y su `google-services.json`.
2. **Clave de firma propia.** Crearla una vez y guardarla fuera de git:
   ```bash
   keytool -genkey -v -keystore upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Crear `android/key.properties` (ya está en `.gitignore`):
   ```
   storeFile=../upload.jks
   storePassword=...
   keyAlias=upload
   keyPassword=...
   ```
   Sin ese archivo el APK se firma con la clave de depuración. **Perder la
   clave impide actualizar la app instalada**: hacer copia.
3. **Firebase.** Registrar el SHA-1 y SHA-256 de la clave de firma en la app
   Android de Firebase (necesario para el inicio de sesión con Google).
4. **Versión.** `version:` en `pubspec.yaml` (`1.0.0+1`: nombre+código). Subir
   el código en cada APK nuevo.

## Compilar en local

```bash
flutter build apk --release --split-per-abi
```
Salida en `build/app/outputs/flutter-apk/` (un APK por arquitectura; el de
`arm64-v8a` sirve para casi todos los teléfonos actuales).

## Publicar en GitHub Releases

El workflow `.github/workflows/release-apk.yml` compila al subir una etiqueta
y deja un **borrador** de release con los APK y `SHA256SUMS.txt`. No publica
solo.

1. Cargar los 4 secretos (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
   `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`) en Settings > Secrets > Actions.
2. `git tag v1.0.0-beta.1 && git push origin v1.0.0-beta.1` (las etiquetas con
   guion salen marcadas como *pre-release*).
3. Revisar el borrador en la pestaña Releases, descargar el APK, instalarlo en
   un teléfono real y recién entonces pulsar *Publish*.

Antes del primer uso real: revisar la acción de terceros `subosito/flutter-action`
y fijarla a un commit.

## Qué probar en el teléfono (nunca se probó)

GPS durante el paseo, cámara y galería, permiso y recepción de notificaciones
(primer plano, segundo plano y app cerrada; icono y título del aviso), "No
molestar", compartir PNG, inicio de sesión con Google, modo claro/oscuro y
textos en es/en/pt.

## Pendiente fuera del APK

La API (Vercel) y el Worker de Cloudflare siguen sin desplegar con los cambios
recientes (no molestar en el servidor, icono del push).
