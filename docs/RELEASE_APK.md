# APK de PawLife

El APK se arma en GitHub Actions y se publica en la sección Releases. Se instala
directamente en el teléfono, sin pasar por Play Store.

## Descargar e instalar

Enlace siempre actualizado a la última versión:
https://github.com/GRobkin/PawLife/releases/latest/download/PawLife.apk

1. Abrir el enlace en el teléfono y descargar el archivo.
2. Abrirlo. Si Android lo pide, permitir "instalar apps desconocidas" para el navegador.
3. Tocar *Instalar* (si aparece un aviso de Play Protect, elegir *Instalar de todos modos*).

Es una versión de prueba, firmada con la clave de depuración.

## Publicar una versión nueva

El workflow `.github/workflows/release-apk.yml` se dispara al subir una etiqueta
`v*`: corre el análisis y las pruebas, compila `flutter build apk --release` y
publica `PawLife.apk` y su suma SHA-256 en un release.

```bash
git tag v1.0.0-beta.3
git push origin v1.0.0-beta.3
```

Subir el número de `version:` en `pubspec.yaml` en cada APK nuevo (`1.0.0+1`:
nombre y código de versión).

## Compilar en local

Requiere Java 17 y el Android SDK.

```bash
flutter build apk --release --split-per-abi
```

La salida queda en `build/app/outputs/flutter-apk/`, un APK por arquitectura (el
de `arm64-v8a` sirve para casi todos los teléfonos actuales).

## Antes de publicar en tiendas

1. **Identificador de la app.** Hoy es `com.example.flutter_application_1`
   (`android/app/build.gradle.kts` y `lib/config/app_identity.dart`). Cambiarlo
   después de publicar crea una app distinta. Elegir el definitivo antes y
   actualizar a la vez `applicationId`, `namespace`, el paquete Kotlin,
   `kAppPackageId`, la app registrada en Firebase y su `google-services.json`.
2. **Clave de firma propia.** Crearla una vez y guardarla fuera de git:
   ```bash
   keytool -genkey -v -keystore upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Crear `android/key.properties` (ya está en `.gitignore`) con `storeFile`,
   `storePassword`, `keyAlias` y `keyPassword`. Para que Actions firme con ella,
   cargar `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
   `ANDROID_KEY_ALIAS` y `ANDROID_KEY_PASSWORD` como secretos del repositorio.
   Perder la clave impide actualizar la app instalada: guardar una copia.
3. **Firebase.** Registrar el SHA-1 y el SHA-256 de la clave de firma en la app
   Android de Firebase (necesario para el inicio de sesión con Google).

## Si "Continuar con Google" no deja entrar

En Android, si Google no reconoce la firma del APK, `google_sign_in` 7 responde
"cancelado" (`[16] Account reauth failed.`) en lugar de un error de
configuración. Hasta la versión `beta.3` la app trataba eso como si la persona
hubiera cerrado el selector, así que el botón no hacía nada y no decía nada. Desde
la versión siguiente muestra "Google rechazó el acceso desde esta app" con el
texto original entre paréntesis.

La causa habitual es la firma. Si el workflow no tiene los secretos de firma
(paso 2 de arriba), el APK sale firmado con una clave de depuración que el
ejecutor de GitHub crea de nuevo en cada compilación. Esa huella no está
registrada en Firebase y cambia en cada versión. Con la clave propia en los
secretos, la huella es siempre la misma y se registra una sola vez.

Para ver la huella de un APK ya compilado, con el Android SDK instalado:

```bash
apksigner verify --print-certs PawLife.apk
```

(`keytool -printcert -jarfile` no sirve con estos APK: solo traen firma v2.)

Para ver el motivo exacto en el teléfono, con el cable y la depuración USB:

```bash
adb logcat -s Auth:W Auth.Api.Credentials:W
```

`not registered to use OAuth2.0` indica que falta la huella; `Network error`,
que el teléfono no llegó a Google.

El inicio de sesión con correo y contraseña no depende de la huella.

## Qué falta probar en un teléfono

GPS durante el paseo, cámara y galería, notificaciones (primer plano, segundo
plano y app cerrada), no molestar, compartir la imagen del paseo, inicio de
sesión con Google, modo oscuro y los textos en español, inglés y portugués.
