import 'package:flutter/material.dart';

import '../../models/pawlife_models.dart';
import '../../services/pawlife_repository.dart';
import '../../services/seleccion_mascota.dart';
import '../../services/walk_repository.dart';
import '../../viewmodels/route_view_model.dart';
import 'wearable_controller.dart';
import 'wearable_theme.dart';
import 'wearable_walk_view.dart';

/// Interfaz de reloj: un marco circular de 250×250 sobre negro puro, conectado
/// al paseo real. Se abre desde el icono de reloj del Home.
class WearableScreen extends StatefulWidget {
  const WearableScreen({super.key, this.controller});

  /// Permite inyectar un controlador (pruebas y capturas).
  final WearableController? controller;

  @override
  State<WearableScreen> createState() => _WearableScreenState();
}

class _WearableScreenState extends State<WearableScreen> {
  late final WearableController _controller = widget.controller ?? _crearReal();

  static WearableController _crearReal() {
    final walks = WalkRepository();
    return WearableController(
      paseo: WearablePaseoReal(RouteViewModel()),
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
    if (widget.controller == null) _controller.preparar();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
