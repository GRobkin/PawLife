import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/foto_mascota.dart';
import '../../models/pawlife_models.dart';
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
                width: 132,
                height: 132,
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
          const SizedBox(height: 8),
          _SelectorMascota(controller: controller),
        ],
      ),
    );
  }
}

/// Mascota del paseo: la elegida al centro con anillo verde y las vecinas
/// atenuadas a los lados. Un toque o un deslizamiento cambia de mascota.
class _SelectorMascota extends StatelessWidget {
  const _SelectorMascota({required this.controller});
  final WearableController controller;

  @override
  Widget build(BuildContext context) {
    final mascota = controller.mascota;
    if (mascota == null) return const SizedBox.shrink();
    final lista = controller.mascotas;
    final varias = lista.length > 1;
    final indice = lista.indexWhere((m) => m.id == mascota.id);
    Mascota? vecina(int paso) => varias && indice >= 0
        ? lista[(indice + paso + lista.length) % lista.length]
        : null;
    // Con solo dos mascotas la anterior y la siguiente son la misma: se
    // muestra una vez.
    final anterior = lista.length > 2 ? vecina(-1) : null;
    final siguiente = vecina(1);
    final d = controller.sentido.toDouble();

    Widget fila() => Column(
      key: ValueKey(mascota.id),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (anterior != null)
              _Foto(mascota: anterior, radio: 13, tenue: true),
            if (anterior != null) const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: WearableColors.acento, width: 2),
              ),
              child: _Foto(mascota: mascota, radio: 20),
            ),
            if (siguiente != null) const SizedBox(width: 10),
            if (siguiente != null)
              _Foto(mascota: siguiente, radio: 13, tenue: true),
          ],
        ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Text(
            mascota.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: WearableColors.etiqueta.copyWith(fontSize: 14),
          ),
        ),
      ],
    );

    final contenido = AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animacion) {
        final entra = child.key == ValueKey(mascota.id);
        return FadeTransition(
          opacity: animacion,
          child: SlideTransition(
            position: Tween(
              begin: Offset((entra ? d : -d) * 0.45, 0),
              end: Offset.zero,
            ).animate(animacion),
            child: child,
          ),
        );
      },
      child: fila(),
    );

    return Semantics(
      button: varias,
      label: mascota.nombre,
      excludeSemantics: true,
      child: _Tocable(
        activo: varias,
        onTap: controller.siguienteMascota,
        onDeslizar: (haciaLaIzquierda) => haciaLaIzquierda
            ? controller.siguienteMascota()
            : controller.anteriorMascota(),
        child: contenido,
      ),
    );
  }
}

class _Foto extends StatelessWidget {
  const _Foto({required this.mascota, required this.radio, this.tenue = false});
  final Mascota mascota;
  final double radio;
  final bool tenue;

  @override
  Widget build(BuildContext context) {
    final foto = proveedorDeFoto(mascota.fotoUrl);
    return Opacity(
      opacity: tenue ? 0.45 : 1,
      child: CircleAvatar(
        radius: radio,
        backgroundColor: WearableColors.secundario,
        backgroundImage: foto,
        child: foto == null
            ? Text(
                mascota.inicial,
                style: WearableColors.etiqueta.copyWith(fontSize: radio * 0.9),
              )
            : null,
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
    required this.onDeslizar,
    required this.child,
  });
  final bool activo;
  final VoidCallback onTap;
  final void Function(bool haciaLaIzquierda) onDeslizar;
  final Widget child;

  @override
  Widget build(BuildContext context) => activo
      ? GestureDetector(
          key: const Key('wearable-mascota'),
          onTap: onTap,
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v.abs() > 120) onDeslizar(v < 0);
          },
          behavior: HitTestBehavior.opaque,
          child: child,
        )
      : child;
}
