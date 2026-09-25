# PawLife

App Flutter de PawLife. El backend es una API PHP aparte, en `../apipaw`.

## Arquitectura

```
Flutter  ──HTTP + ID token──▶  API PHP (Vercel)  ──REST──▶  Firestore
   │
   └── Firebase Auth (solo para identificar al usuario)
```

La app **no** habla con Firestore. Firebase se queda únicamente para
autenticar: `firebase_auth` emite un ID token, ese token viaja en cada petición
y el backend lo verifica para saber de quién son los datos.

Lo que eso implica al tocar código:

- No añadas `cloud_firestore` de vuelta. Los datos se piden a la API.
- Los modelos (`lib/models/pawlife_models.dart`) son Dart puro con
  `fromJson`/`toJson` y fechas en ISO 8601, no `Timestamp` ni `GeoPoint`.
- Ya no hay streams en tiempo real. Donde antes había un `watchPaseos` que
  reaccionaba solo, ahora hay un `fetchPaseos` que hay que llamar.

## Configurar la URL del backend

Se fija al compilar, para no tocar código al cambiar de entorno:

```bash
flutter run --dart-define=PAWLIFE_API_URL=https://tu-proyecto.vercel.app
```

Sin `--dart-define` se usa el valor por defecto de
`ApiClient.defaultBaseUrl` (`lib/services/api_client.dart`).

Contra un backend local (`php -S localhost:8000 api/index.php` dentro de
`../apipaw`), ojo con que "localhost" dentro del emulador es el propio
emulador:

```bash
# Android (emulador)
flutter run --dart-define=PAWLIFE_API_URL=http://10.0.2.2:8000
# iOS (simulador)
flutter run --dart-define=PAWLIFE_API_URL=http://localhost:8000
```

En Android, hablar con un backend local por HTTP sin TLS requiere permitir
tráfico en claro en el `AndroidManifest.xml` de debug. En producción la URL es
https y no hace falta.

## Arrancar

```bash
flutter clean
flutter pub get
flutter run --dart-define=PAWLIFE_API_URL=https://tu-proyecto.vercel.app
```

## Mapa del código

```
lib/main.dart                      Arranque: inicializa Firebase y el AuthGate que elige pantalla.
lib/models/                        Modelos de dominio y el punto de ruta GPS.
lib/services/auth_service.dart     Firebase Auth: login, registro, Google e ID token.
lib/services/api_client.dart       HTTP contra la API: token, JSON y errores.
lib/services/pawlife_repository.dart  Mascotas, vacunas, medicamentos, pesos y recordatorios.
lib/services/walk_repository.dart  Paseos: guardar y listar.
lib/services/location_service.dart Geolocator.
lib/services/walk_task_handler.dart  Foreground service que registra la ruta.
lib/viewmodels/route_view_model.dart Estado del paseo en curso.
lib/views/                         Pantallas.
```

## Acceso a la app

El login es obligatorio: no hay sesión anónima. `AuthGate` (en `main.dart`)
escucha `authStateChanges` y decide la pantalla raíz — `WelcomeScreen` si no
hay sesión, `HomeScreen` si la hay. Firebase guarda la sesión en el
dispositivo, así que solo hay que entrar la primera vez.

Por eso las pantallas de login y registro **no navegan al Home**: al terminar
solo hacen `popUntil(isFirst)`, y el gate, que está debajo, ya se reconstruyó
con el usuario nuevo. Si además hicieran `pushReplacement` habría dos Home
apilados. Lo mismo al cerrar sesión (menú del avatar en el Home): el stream
emite `null` y el gate vuelve solo a la bienvenida.

### Configuración que hay que hacer en la consola

Sin esto el acceso falla, y el código no puede suplirlo:

1. **Firebase Console → Authentication → Sign-in method**: habilitar
   *Correo electrónico/contraseña* y *Google*. Si falta alguno, la app avisa
   con "Este método de acceso no está habilitado en el proyecto de Firebase".
2. **Configuración del proyecto → Tus apps → Android → Agregar huella
   digital**: la SHA-1 de la máquina que compila. Para sacarla:

   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore \
           -alias androiddebugkey -storepass android -keypass android
   ```

   (en Windows, si `keytool` falla con `MissingFormatArgumentException`, es un
   bug del JDK con el locale: añadí `-J-Duser.language=en -J-Duser.country=US`).
3. **Volver a descargar `google-services.json`** y reemplazar el de
   `android/app/`. Es el paso que más se olvida: hasta que la SHA-1 no está
   registrada, ese archivo trae `"oauth_client": []` y Google Sign-In falla con
   el inútil `ApiException: 10`.

   Para comprobar que el archivo nuevo sirve, tiene que traer una entrada con
   `"client_type": 3` (el cliente web). Si la hay, el plugin la lee solo y no
   hace falta configurar nada en Dart. Si no, se puede pasar a mano:

   ```bash
   flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<web client id>
   ```

Cada máquina que compile en debug tiene su propia SHA-1, y la de release es
otra distinta: hay que registrarlas todas.

Para **iOS** falta además `GoogleService-Info.plist` en `ios/Runner/` y el
`CFBundleURLSchemes` con el `REVERSED_CLIENT_ID` en `Info.plist`.

## Fotos de las mascotas

Es la única excepción a "todos los datos pasan por el backend": la app sube el
archivo directamente a **Firebase Storage** y a la API le manda solo la URL, que
es lo que guarda en `fotoUrl`. Pasar el binario por una función serverless de
Vercel obligaría a reenviarlo dos veces y choca con el límite de tamaño de
cuerpo.

Como aquí el cliente sí accede directamente, las reglas de `storage.rules` son
lo único que impide que alguien lea o sobrescriba las fotos de otra persona. La
ruta es siempre `users/{uid}/mascotas/{mascotaId}/...` y la regla exige que ese
uid sea el de quien sube.

Hay que **habilitar Storage** en la consola de Firebase y publicar las reglas:

```bash
firebase deploy --only storage,firestore:rules
```

## Pendiente

- Formularios para dar de alta **vacunas, medicamentos y recordatorios**. En el
  detalle de mascota ya se ven, pero solo en modo lectura. El único registro
  que se puede crear desde la app es el de peso.
- Las secciones **Tareas** y **Perfil** de la barra inferior avisan con un
  snackbar: todavía no existen.
- **Notificaciones push a medias**: `lib/services/push_service.dart` solo
  imprime el token FCM. No llega al backend, no hay manejadores de mensajes y
  se inicializa antes del login, cuando aún no hay uid al que asociarlo.
- El Home sigue con el resumen de actividad y la lista de tareas escritos a
  mano.
