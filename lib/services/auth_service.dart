// services/auth_service.dart
//
// Única puerta de entrada a la autenticación. Firebase ya no se usa para datos
// (de eso se encarga la API PHP en ../apipaw): se queda solo para identificar
// al usuario.
//
// El backend no guarda sesiones ni contraseñas. Confía en el ID token que
// emite Firebase aquí: lo verifica contra las claves públicas de Google, saca
// el uid y con él construye la ruta de Firestore donde viven los datos de esa
// persona. Por eso el token tiene que acompañar a TODAS las peticiones.
//
// Entrar con Google no cambia nada de eso: `google_sign_in` solo consigue la
// credencial de Google y quien abre la sesión sigue siendo firebase_auth, así
// que el backend recibe el mismo tipo de token venga de donde venga.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Error de autenticación con un mensaje ya listo para enseñar en pantalla.
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;

  /// Código interno, solo para que la UI distinga casos que no son errores
  /// de verdad. Ver [isCancelled].
  final String? code;

  /// El usuario cerró el diálogo de Google. No hay nada que reportar: mostrar
  /// un error rojo por esto es ruido.
  bool get isCancelled => code == 'cancelado';

  @override
  String toString() => message;
}

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// ID del cliente **web** de OAuth, necesario para que Google devuelva un
  /// ID token.
  ///
  /// Normalmente no hace falta: el plugin lo lee de `google-services.json`
  /// siempre que ese archivo traiga el cliente web (`"client_type": 3`), cosa
  /// que solo ocurre después de registrar la huella SHA-1 del proyecto en la
  /// consola de Firebase y volver a descargarlo.
  ///
  /// Si por lo que sea no está ahí, se puede pasar a mano:
  ///
  ///   flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=123-abc.apps.googleusercontent.com
  static const String _serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  /// `initialize` hay que llamarlo una sola vez antes del primer
  /// `authenticate`. Se guarda el Future en vez de un bool para que dos
  /// pulsaciones rápidas del botón no lancen dos inicializaciones a la vez.
  static Future<void>? _googleInit;

  User? get currentUser => _auth.currentUser;

  /// Lo escucha el AuthGate de main.dart para decidir qué pantalla mostrar.
  /// Emite al entrar, al salir y al restaurar la sesión guardada al arrancar.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ------------------------------------------------------------ email y clave

  Future<User> registerWithEmail({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('No se pudo crear la cuenta.');
      }

      // El nombre es parte del perfil de Firebase, no de nuestra base de
      // datos. Si falla no tiene sentido tirar abajo un registro que ya
      // funcionó: la cuenta existe y el nombre se puede corregir luego.
      try {
        await user.updateDisplayName(nombre.trim());
        await user.reload();
      } on FirebaseAuthException {
        // Se ignora a propósito.
      }

      return _auth.currentUser ?? user;
    } on FirebaseAuthException catch (e) {
      throw _traducir(e);
    }
  }

  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('No se pudo iniciar sesión.');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _traducir(e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _traducir(e);
    }
  }

  // ----------------------------------------------------------------- Google

  Future<User> signInWithGoogle() async {
    final google = GoogleSignIn.instance;

    if (!google.supportsAuthenticate()) {
      // Pasa en Flutter Web, donde Google obliga a usar su propio botón
      // (renderButton) en vez de un flujo lanzado desde código.
      throw const AuthException(
        'El acceso con Google no está disponible en esta plataforma.',
      );
    }

    try {
      _googleInit ??= google.initialize(
        serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
      );
      await _googleInit;

      final cuenta = await google.authenticate();
      final idToken = cuenta.authentication.idToken;

      if (idToken == null) {
        // Señal inequívoca de que falta el cliente web de OAuth: Google
        // autenticó al usuario pero no emitió un ID token, y sin él Firebase
        // no puede abrir la sesión.
        throw const AuthException(
          'Google no devolvió un token de identidad. Falta registrar la huella '
          'SHA-1 en Firebase y volver a descargar google-services.json.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final resultado = await _auth.signInWithCredential(credential);

      final user = resultado.user;
      if (user == null) {
        throw const AuthException('No se pudo iniciar sesión con Google.');
      }

      return user;
    } on GoogleSignInException catch (e) {
      throw _traducirGoogle(e);
    } on FirebaseAuthException catch (e) {
      throw _traducir(e);
    }
  }

  // ---------------------------------------------------------------- sesión

  Future<void> signOut() async {
    // Se cierra también la sesión de Google: si no, el siguiente "Continuar
    // con Google" volvería a entrar con la misma cuenta sin preguntar, y no
    // habría forma de cambiar de usuario.
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Si Google nunca se inicializó, esto falla y da igual.
    }

    await _auth.signOut();
  }

  /// ID token con el que se autentica cada llamada a la API.
  ///
  /// Caduca a la hora, pero no hace falta controlarlo desde fuera: el SDK
  /// guarda el refresh token y devuelve uno nuevo cuando el que tiene está a
  /// punto de expirar. [forceRefresh] solo se usa para reintentar tras un 401,
  /// por si el token cacheado se quedó atrás.
  Future<String> idToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException(
        'No hay sesión iniciada.',
        code: 'sin-sesion',
      );
    }

    try {
      final token = await user.getIdToken(forceRefresh);
      if (token == null || token.isEmpty) {
        throw const AuthException('Firebase no devolvió un token válido.');
      }

      return token;
    } on FirebaseAuthException catch (e) {
      throw _traducir(e);
    }
  }

  // ------------------------------------------------------------- traducción

  /// Los códigos de Firebase son estables; los mensajes que trae la excepción
  /// están en inglés y son bastante técnicos, así que se traducen aquí una vez
  /// en lugar de en cada pantalla.
  AuthException _traducir(FirebaseAuthException e) {
    final mensaje = switch (e.code) {
      'invalid-email' => 'El correo no tiene un formato válido.',
      'user-disabled' => 'Esta cuenta está deshabilitada.',
      // Firebase devuelve 'invalid-credential' tanto si el correo no existe
      // como si la contraseña está mal, a propósito: así nadie puede averiguar
      // qué correos están registrados probando uno a uno.
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' =>
        'Correo o contraseña incorrectos.',
      'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
      'weak-password' => 'La contraseña es demasiado débil (mínimo 6 caracteres).',
      'account-exists-with-different-credential' =>
        'Ya hay una cuenta con ese correo creada con otro método de acceso.',
      'requires-recent-login' =>
        'Por seguridad, volvé a iniciar sesión para hacer este cambio.',
      'too-many-requests' =>
        'Demasiados intentos fallidos. Esperá unos minutos y probá de nuevo.',
      'network-request-failed' =>
        'No hay conexión a internet.',
      // Este no es un error del usuario: es que falta habilitar el proveedor
      // en la consola de Firebase (Authentication > Sign-in method).
      'operation-not-allowed' =>
        'Este método de acceso no está habilitado en el proyecto de Firebase.',
      _ => e.message ?? 'No se pudo completar la operación (${e.code}).',
    };

    return AuthException(mensaje, code: e.code);
  }

  AuthException _traducirGoogle(GoogleSignInException e) {
    final mensaje = switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Acceso con Google cancelado.',
      GoogleSignInExceptionCode.interrupted =>
        'El acceso con Google se interrumpió. Probá de nuevo.',
      GoogleSignInExceptionCode.uiUnavailable =>
        'No se pudo abrir el diálogo de Google.',
      // Los dos de configuración son el fallo clásico de Android: la huella
      // SHA-1 no está registrada en Firebase, o google-services.json es
      // anterior a registrarla. Se dice explícitamente porque el mensaje
      // original ("ApiException: 10") no ayuda en nada.
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError =>
        'La app no está bien configurada para Google. Revisá que la huella '
            'SHA-1 esté registrada en Firebase, que el proveedor Google esté '
            'habilitado y que google-services.json sea el más reciente.',
      GoogleSignInExceptionCode.userMismatch =>
        'La cuenta de Google no coincide con la esperada.',
      GoogleSignInExceptionCode.unknownError =>
        e.description ?? 'Fallo al entrar con Google.',
    };

    return AuthException(
      mensaje,
      code: e.code == GoogleSignInExceptionCode.canceled ? 'cancelado' : 'google',
    );
  }
}
