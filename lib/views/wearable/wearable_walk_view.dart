import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/foto_mascota.dart';
import 'wearable_controller.dart';
import 'wearable_theme.dart';

/// Contenido del reloj para cada estado. Siempre hay una acción principal y,
/// como mucho, dos elementos pulsables.
class WearableWalkView extends StatelessWidget {
  const WearableWalkView({super.key, required this.controller});

  final WearableController controller;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return switch (controller.estado) {
      WearableEstado.reposo => _Reposo(controller: controller, t: t),
      WearableEstado.iniciando => const _Centro(
        hijo: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: WearableColors.acento,
            strokeWidth: 4,
          ),
        ),
      ),
      WearableEstado.enPaseo ||
      WearableEstado.pausado => _EnPaseo(controller: controller, t: t),
      WearableEstado.guardando => _Centro(
        hijo: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                color: WearableColors.acento,
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 14),
            Text(t.wearableSaving, style: WearableColors.etiqueta),
          ],
        ),
      ),
      WearableEstado.terminado => _Terminado(controller: controller, t: t),
      WearableEstado.error => _Fallo(controller: controller, t: t),
    };
  }
}

String formatoReloj(Duration d) {
  final h = d.inHours;
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

class _Centro extends StatelessWidget {
  const _Centro({required this.hijo});
  final Widget hijo;

  @override
  Widget build(BuildContext context) => Center(child: hijo);
}

/// Botón circular con icono y etiqueta corta debajo.
class _BotonRedondo extends StatelessWidget {
  const _BotonRedondo({
    required this.icono,
    required this.etiqueta,
    required this.onTap,
    this.primario = true,
  });

  final IconData icono;
  final String etiqueta;
  final VoidCallback onTap;
  static const double diametro = 72;
  final bool primario;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: etiqueta,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: diametro,
              height: diametro,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primario
                    ? WearableColors.acento
                    : WearableColors.secundario,
              ),
              child: Icon(
                icono,
                size: diametro * 0.46,
                color: primario
                    ? WearableColors.sobreAcento
                    : WearableColors.texto,
              ),
            ),
            const SizedBox(height: 6),
            Text(etiqueta, style: WearableColors.etiqueta),
          ],
        ),
      ),
    );
  }
}

class _Reposo extends StatelessWidget {
  const _Reposo({required this.controller, required this.t});
  final WearableController controller;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: t.wearableStart,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: controller.iniciar,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 150,
                height: 150,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: WearableColors.acento,
                ),
                child: Text(
                  t.wearableStart,
                  style: const TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: WearableColors.sobreAcento,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _SelectorMascota(controller: controller),
        ],
      ),
    );
  }
}

/// Mascota del paseo: foto, nombre y puntos. Un toque pasa a la siguiente.
class _SelectorMascota extends StatelessWidget {
  const _SelectorMascota({required this.controller});
  final WearableController controller;

  @override
  Widget build(BuildContext context) {
    final mascota = controller.mascota;
    if (mascota == null) return const SizedBox.shrink();
    final varias = controller.mascotas.length > 1;
    final indice = controller.mascotas.indexWhere((m) => m.id == mascota.id);
    final foto = proveedorDeFoto(mascota.fotoUrl);
    return Semantics(
      button: varias,
      label: mascota.nombre,
      excludeSemantics: true,
      child: _Tocable(
        activo: varias,
        onTap: controller.siguienteMascota,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animacion) => FadeTransition(
            opacity: animacion,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0.25, 0),
                end: Offset.zero,
              ).animate(animacion),
              child: child,
            ),
          ),
          child: Column(
            key: ValueKey(mascota.id),
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: WearableColors.secundario,
                    backgroundImage: foto,
                    child: foto == null
                        ? Text(
                            mascota.inicial,
                            style: WearableColors.etiqueta.copyWith(
                              fontSize: 12,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 90),
                    child: Text(
                      mascota.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WearableColors.etiqueta.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
              if (varias) ...[
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (
                      var i = 0;
                      i < controller.mascotas.length && i < 6;
                      i++
                    )
                      Container(
                        width: i == indice ? 14 : 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: i == indice
                              ? WearableColors.acento
                              : WearableColors.textoTenue,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EnPaseo extends StatelessWidget {
  const _EnPaseo({required this.controller, required this.t});
  final WearableController controller;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final pausado = controller.estado == WearableEstado.pausado;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatoReloj(controller.tiempo),
            style: WearableColors.tiempo.copyWith(
              color: pausado ? WearableColors.textoTenue : WearableColors.texto,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BotonRedondo(
                icono: pausado ? Icons.play_arrow_rounded : Icons.pause_rounded,
                etiqueta: pausado ? t.wearableResume : t.wearablePause,
                onTap: pausado ? controller.reanudar : controller.pausar,
              ),
              const SizedBox(width: 20),
              _BotonRedondo(
                icono: Icons.stop_rounded,
                etiqueta: t.wearableStop,
                primario: false,
                onTap: controller.terminar,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Terminado extends StatelessWidget {
  const _Terminado({required this.controller, required this.t});
  final WearableController controller;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final km = (controller.distanciaFinalM / 1000).toStringAsFixed(2);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 44,
            color: WearableColors.acento,
          ),
          const SizedBox(height: 6),
          Text(
            t.wearableSaved,
            style: WearableColors.etiqueta.copyWith(
              color: WearableColors.acento,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text('$km km', style: WearableColors.tiempo.copyWith(fontSize: 30)),
          Text(
            formatoReloj(controller.tiempoFinal),
            style: WearableColors.etiqueta.copyWith(
              fontSize: 16,
              color: WearableColors.textoTenue,
            ),
          ),
          const SizedBox(height: 10),
          _Pildora(texto: t.wearableDone, onTap: controller.aceptar),
        ],
      ),
    );
  }
}

class _Fallo extends StatelessWidget {
  const _Fallo({required this.controller, required this.t});
  final WearableController controller;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final e = controller.error ?? WearableError.noGuardo;
    final texto = switch (e) {
      WearableError.sinGps => t.wearableNoGps,
      WearableError.sinMascota => t.wearableNoPet,
      WearableError.noGuardo => t.wearableNotSaved,
    };
    final icono = switch (e) {
      WearableError.sinGps => Icons.location_off_outlined,
      WearableError.sinMascota => Icons.pets,
      WearableError.noGuardo => Icons.cloud_off_outlined,
    };
    // Con sesión pendiente se reintenta el guardado; si no, se vuelve.
    final reintenta = e == WearableError.noGuardo;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 44, color: WearableColors.error),
          const SizedBox(height: 8),
          Text(
            texto,
            style: WearableColors.etiqueta.copyWith(
              color: WearableColors.error,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          _Pildora(
            texto: reintenta ? t.wearableRetry : t.wearableDone,
            onTap: reintenta ? controller.reintentar : controller.aceptar,
          ),
        ],
      ),
    );
  }
}

class _Pildora extends StatelessWidget {
  const _Pildora({required this.texto, required this.onTap});
  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: texto,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: WearableColors.acento,
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              texto,
              style: WearableColors.etiqueta.copyWith(
                color: WearableColors.sobreAcento,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Solo es pulsable cuando hay algo que elegir: con una sola mascota la
/// pantalla conserva un único elemento de interacción.
class _Tocable extends StatelessWidget {
  const _Tocable({
    required this.activo,
    required this.onTap,
    required this.child,
  });
  final bool activo;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => activo
      ? GestureDetector(
          key: const Key('wearable-mascota'),
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: child,
        )
      : child;
}
