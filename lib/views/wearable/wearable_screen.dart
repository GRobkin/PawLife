import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/pawlife_models.dart';
import '../../services/pawlife_repository.dart';
import '../../services/seleccion_mascota.dart';
import '../../services/walk_repository.dart';
import '../../viewmodels/route_view_model.dart';
import '../premium_screen.dart';
import 'wearable_controller.dart';
import 'wearable_theme.dart';
import 'wearable_walk_view.dart';

/// Interfaz de reloj: un marco circular de 250×250 sobre negro puro, conectado
/// al paseo real. Se abre desde el icono de reloj del Home.
class WearableScreen extends StatefulWidget {
  const WearableScreen({super.key, this.controller, this.comprobarPremium});

  /// Permite inyectar un controlador (pruebas y capturas).
  final WearableController? controller;

  /// Comprueba el plan. Sin controlador inyectado consulta al servidor; con uno
  /// (pruebas y capturas) se omite salvo que se pase esta función.
  final Future<bool> Function()? comprobarPremium;

  @override
  State<WearableScreen> createState() => _WearableScreenState();
}

class _WearableScreenState extends State<WearableScreen> {
  late final WearableController _controller = widget.controller ?? _crearReal();
  bool? _acceso;

  static WearableController _crearReal() {
    final walks = WalkRepository();
    return WearableController(
      paseo: WearablePaseoReal(RouteViewModel()),
      cargarMascotas: () async =>
          (await PawLifeRepository().fetchMascotas()).toList(),
      alElegirMascota: SeleccionMascota.seleccionar,
      cargarMascota: () async {
        final Iterable<Mascota> lista = await PawLifeRepository()
            .fetchMascotas();
        return SeleccionMascota.resolver(lista.toList());
      },
      guardar: (mascotaId, sesion) =>
          walks.savePaseo(mascotaId: mascotaId, session: sesion),
    );
  }

  @override
  void initState() {
    super.initState();
    final comprobar =
        widget.comprobarPremium ??
        (widget.controller == null ? _premiumReal : null);
    if (comprobar == null) {
      _acceso = true;
      if (widget.controller == null) _controller.preparar();
    } else {
      comprobar()
          .then((v) {
            if (!mounted) return;
            // El controlador (GPS, mascotas) solo se crea con acceso.
            if (v && widget.controller == null) _controller.preparar();
            setState(() => _acceso = v);
          })
          .catchError((_) {
            if (mounted) setState(() => _acceso = false);
          });
    }
  }

  static Future<bool> _premiumReal() async {
    final repo = PawLifeRepository();
    try {
      return (await repo.fetchPremium())['activo'] == true;
    } finally {
      repo.client.close();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null && _acceso == true) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_acceso != true) return _Bloqueo(comprobando: _acceso == null);
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        // Con un paseo en curso no se sale por accidente: perdería el registro.
        return PopScope(
          canPop: !_controller.enCurso,
          child: Scaffold(
            backgroundColor: WearableColors.fondo,
            body: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: ClipOval(
                      child: Container(
                        key: const Key('wearable-frame'),
                        width: WearableColors.lado,
                        height: WearableColors.lado,
                        color: WearableColors.fondo,
                        child: WearableWalkView(controller: _controller),
                      ),
                    ),
                  ),
                  if (!_controller.enCurso)
                    Positioned(
                      left: 4,
                      top: 4,
                      child: IconButton(
                        color: WearableColors.textoTenue,
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Sin Premium el reloj no se abre: el límite se ve y lleva a la oferta.
class _Bloqueo extends StatelessWidget {
  const _Bloqueo({required this.comprobando});

  final bool comprobando;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: WearableColors.fondo,
      appBar: AppBar(
        backgroundColor: WearableColors.fondo,
        foregroundColor: WearableColors.textoTenue,
      ),
      body: Center(
        child: comprobando
            ? const SizedBox.shrink()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    t.wearablePremiumOnly,
                    key: const Key('wearable-bloqueado'),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) =>
                            PremiumScreen(repository: PawLifeRepository()),
                      ),
                    ),
                    child: Text(t.wearableSeePremium),
                  ),
                ],
              ),
      ),
    );
  }
}
