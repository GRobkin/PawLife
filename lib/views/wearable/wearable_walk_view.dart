import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
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
          SizedBox(
            width: 130,
            child: Text(
              controller.mascota?.nombre ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: WearableColors.etiqueta.copyWith(fontSize: 14),
            ),
          ),
        ],
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
