// Adapta el paseo real al reloj. No tiene lógica de GPS propia: delega en un
// [WearablePaseo] (en la app, el RouteViewModel) y en funciones inyectadas
// para la mascota y el guardado, de modo que se pueda probar sin plataforma.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../models/pawlife_models.dart';
import '../../models/route_point.dart';
import '../../viewmodels/route_view_model.dart';

enum WearableEstado {
  reposo,
  iniciando,
  enPaseo,
  pausado,
  guardando,
  terminado,
  error,
}

/// Errores que la pantalla del reloj sabe nombrar en dos palabras.
enum WearableError { sinGps, sinMascota, noGuardo }

/// Lo mínimo que el reloj necesita de un paseo en curso.
abstract class WearablePaseo {
  /// Devuelve null si el paseo arrancó, o un código de error de ubicación.
  Future<String?> iniciar();
  void pausar();
  void reanudar();
  WalkSession terminar();
  Duration get tiempo;
  double get distanciaMetros;
  Listenable get cambios;
  void liberar();
}

class WearablePaseoReal implements WearablePaseo {
  WearablePaseoReal(this._vm);
  final RouteViewModel _vm;

  @override
  Future<String?> iniciar() async {
    await _vm.init();
    return _vm.status == RouteScreenStatus.error
        ? (_vm.errorCode ?? 'location-failed')
        : null;
  }

  @override
  void pausar() => _vm.pauseWalk();
  @override
  void reanudar() => _vm.resumeWalk();
  @override
  WalkSession terminar() => _vm.stopWalk();
  @override
  Duration get tiempo => _vm.elapsed;
  @override
  double get distanciaMetros => _vm.distanceMeters;
  @override
  Listenable get cambios => _vm;
  @override
  void liberar() => _vm.dispose();
}

class WearableController extends ChangeNotifier {
  WearableController({
    required this.paseo,
    required this.cargarMascota,
    required this.guardar,
    this.vibrar = _vibrar,
  }) {
    paseo.cambios.addListener(_alCambiarPaseo);
  }

  final WearablePaseo paseo;
  final Future<Mascota?> Function() cargarMascota;
  final Future<void> Function(String mascotaId, WalkSession sesion) guardar;
  final Future<void> Function() vibrar;

  static Future<void> _vibrar() => HapticFeedback.lightImpact();

  WearableEstado estado = WearableEstado.reposo;
  WearableError? error;
  Mascota? mascota;
  WalkSession? _sesion;

  /// Último resultado, para la pantalla «guardado».
  Duration tiempoFinal = Duration.zero;
  double distanciaFinalM = 0;

  int _segundosMostrados = -1;
  bool _liberado = false;

  bool get enCurso =>
      estado == WearableEstado.iniciando ||
      estado == WearableEstado.enPaseo ||
      estado == WearableEstado.pausado ||
      estado == WearableEstado.guardando;

  Duration get tiempo => paseo.tiempo;

  /// Carga la mascota activa; sin mascota no se puede pasear.
  Future<void> preparar() async {
    try {
      mascota = await cargarMascota();
    } catch (_) {
      mascota = null;
    }
    if (mascota == null) {
      _fallar(WearableError.sinMascota);
    } else {
      notifyListeners();
    }
  }

  Future<void> iniciar() async {
    if (estado != WearableEstado.reposo) return;
    if (mascota == null) {
      _fallar(WearableError.sinMascota);
      return;
    }
    estado = WearableEstado.iniciando;
    notifyListeners();
    final fallo = await paseo.iniciar();
    if (fallo != null) {
      _fallar(WearableError.sinGps);
      return;
    }
    _segundosMostrados = -1;
    estado = WearableEstado.enPaseo;
    await vibrar();
    notifyListeners();
  }

  Future<void> pausar() async {
    if (estado != WearableEstado.enPaseo) return;
    paseo.pausar();
    estado = WearableEstado.pausado;
    await vibrar();
    notifyListeners();
  }

  Future<void> reanudar() async {
    if (estado != WearableEstado.pausado) return;
    paseo.reanudar();
    estado = WearableEstado.enPaseo;
    await vibrar();
    notifyListeners();
  }

  Future<void> terminar() async {
    if (estado != WearableEstado.enPaseo && estado != WearableEstado.pausado) {
      return;
    }
    _sesion = paseo.terminar();
    tiempoFinal = _sesion!.duration;
    distanciaFinalM = _sesion!.distanceMeters;
    estado = WearableEstado.guardando;
    await vibrar();
    notifyListeners();
    await _guardar();
  }

  /// Reintenta un guardado fallido.
  Future<void> reintentar() async {
    if (_sesion == null || estado != WearableEstado.error) return;
    estado = WearableEstado.guardando;
    error = null;
    notifyListeners();
    await _guardar();
  }

  Future<void> _guardar() async {
    try {
      await guardar(mascota!.id, _sesion!);
      _sesion = null;
      estado = WearableEstado.terminado;
      notifyListeners();
    } catch (_) {
      _fallar(WearableError.noGuardo);
    }
  }

  /// Vuelve al reposo tras ver el resultado o un error sin paseo pendiente.
  void aceptar() {
    if (estado == WearableEstado.terminado ||
        (estado == WearableEstado.error && _sesion == null)) {
      error = null;
      estado = mascota == null ? WearableEstado.error : WearableEstado.reposo;
      if (mascota == null) error = WearableError.sinMascota;
      notifyListeners();
    }
  }

  void _fallar(WearableError e) {
    error = e;
    estado = WearableEstado.error;
    notifyListeners();
  }

  /// El cronómetro se repinta una vez por segundo, no con cada punto GPS.
  void _alCambiarPaseo() {
    if (estado != WearableEstado.enPaseo) return;
    final segundos = paseo.tiempo.inSeconds;
    if (segundos == _segundosMostrados) return;
    _segundosMostrados = segundos;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_liberado) super.notifyListeners();
  }

  @override
  void dispose() {
    _liberado = true;
    paseo.cambios.removeListener(_alCambiarPaseo);
    if (enCurso) paseo.liberar();
    super.dispose();
  }
}
