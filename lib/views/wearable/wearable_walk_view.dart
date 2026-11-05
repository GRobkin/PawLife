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
      WearableEstado.reposo ||
      WearableEstado.iniciando => _Reposo(controller: controller, t: t),
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

/// Botón principal: degradado con luz arriba a la izquierda, borde de cristal
/// y un halo verde. Da volumen sin salirse de la paleta del reloj.
BoxDecoration _decoracionAcento() => BoxDecoration(
  shape: BoxShape.circle,
  gradient: const RadialGradient(
    center: Alignment(-0.35, -0.5),
    radius: 1.05,
    colors: [Color(0xFF8DE8BE), WearableColors.acento, Color(0xFF3FA878)],
    stops: [0, 0.55, 1],
  ),
  border: Border.all(color: Colors.white.withValues(alpha: .22), width: 1.5),
  boxShadow: [
    BoxShadow(
      color: WearableColors.acento.withValues(alpha: .38),
      blurRadius: 22,
      spreadRadius: 1,
    ),
  ],
);

BoxDecoration _decoracionSecundaria() => BoxDecoration(
  shape: BoxShape.circle,
  gradient: const RadialGradient(
    center: Alignment(-0.35, -0.5),
    radius: 1.05,
    colors: [Color(0xFF454545), WearableColors.secundario, Color(0xFF1C1C1C)],
    stops: [0, 0.55, 1],
  ),
  border: Border.all(color: Colors.white.withValues(alpha: .12), width: 1.5),
);

/// [_Pulsable] solo cuando está activo; si no, el contenido va sin toque.
class _PulsableSi extends StatelessWidget {
  const _PulsableSi({
    required this.activo,
    required this.onTap,
    required this.child,
  });

  final bool activo;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      activo ? _Pulsable(onTap: onTap, child: child) : child;
}

/// Pulsable con respuesta: al apretar se hunde un 4 % rápido (100 ms) y al
/// soltar vuelve con calma (200 ms), para que el toque se sienta escuchado.
class _Pulsable extends StatefulWidget {
  const _Pulsable({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_Pulsable> createState() => _PulsableState();
}

class _PulsableState extends State<_Pulsable> {
  bool _apretado = false;

  void _poner(bool v) {
    if (_apretado != v) setState(() => _apretado = v);
  }

  @override
  Widget build(BuildContext context) {
    final quieto = MediaQuery.disableAnimationsOf(context);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _poner(true),
      onTapUp: (_) => _poner(false),
      onTapCancel: () => _poner(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _apretado && !quieto ? 0.96 : 1,
        duration: Duration(milliseconds: _apretado ? 100 : 200),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
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
  static const double diametro = 64;
  final bool primario;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: etiqueta,
      excludeSemantics: true,
      child: _Pulsable(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: diametro,
              height: diametro,
              decoration: primario
                  ? _decoracionAcento()
                  : _decoracionSecundaria(),
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

  static const double _anillo = 124;
  static const double _boton = 108;

  @override
  Widget build(BuildContext context) {
    final buscando = controller.estado == WearableEstado.iniciando;
    // Un solo grupo centrado en el cristal: el botón como protagonista y, debajo,
    // quién pasea y los puntos de las demás mascotas. Mientras se busca el GPS
    // la mascota y los puntos se retiran y el botón queda en el centro.
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: !buscando,
            label: buscando ? t.wearableLocating : t.wearableStart,
            excludeSemantics: true,
            child: _PulsableSi(
              activo: !buscando,
              onTap: controller.iniciar,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Anillo fino alrededor del botón: lo enmarca como un
                  // objetivo. Buscando GPS, un arco gira por él.
                  Container(
                    width: _anillo,
                    height: _anillo,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: WearableColors.acento.withValues(alpha: .35),
                        width: 1.5,
                      ),
                    ),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: buscando ? .55 : 1,
                      child: Container(
                        width: _boton,
                        height: _boton,
                        alignment: Alignment.center,
                        decoration: _decoracionAcento(),
                        child: buscando
                            ? const Icon(
                                Icons.my_location_rounded,
                                size: 42,
                                color: WearableColors.sobreAcento,
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 50,
                                    color: WearableColors.sobreAcento,
                                  ),
                                  Text(
                                    t.wearableStart,
                                    style: const TextStyle(
                                      fontFamily: 'NunitoSans',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      letterSpacing: 1.2,
                                      height: 1,
                                      color: WearableColors.sobreAcento,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  if (buscando)
                    const SizedBox(
                      width: _anillo,
                      height: _anillo,
                      child: CircularProgressIndicator(
                        color: WearableColors.acento,
                        strokeWidth: 3,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Debajo del botón: el estado de la búsqueda, o la mascota.
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: buscando
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      t.wearableLocating,
                      style: WearableColors.etiqueta.copyWith(
                        fontSize: 11,
                        letterSpacing: 1.6,
                        color: WearableColors.acento,
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      _SelectorMascota(controller: controller),
                      _PuntosMascotas(controller: controller),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Mascota del paseo, arriba: una pastilla con su inicial y su nombre. Con más
/// de una lleva flechas, y un toque o un deslizamiento cambia de mascota.
class _SelectorMascota extends StatelessWidget {
  const _SelectorMascota({required this.controller});
  final WearableController controller;

  @override
  Widget build(BuildContext context) {
    final mascota = controller.mascota;
    if (mascota == null) return const SizedBox.shrink();
    final varias = controller.mascotas.length > 1;
    final d = controller.sentido.toDouble();
    final foto = proveedorDeFoto(mascota.fotoUrl);

    Widget flecha(IconData icono) => Icon(
      icono,
      size: 18,
      color: varias ? WearableColors.acento : Colors.transparent,
    );

    Widget fila() => Row(
      key: ValueKey(mascota.id),
      mainAxisSize: MainAxisSize.min,
      children: [
        flecha(Icons.chevron_left_rounded),
        const SizedBox(width: 2),
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: WearableColors.acento,
            image: foto == null
                ? null
                : DecorationImage(
                    image: ResizeImage.resizeIfNeeded(66, null, foto),
                    fit: BoxFit.cover,
                  ),
          ),
          child: foto != null
              ? null
              : Text(
                  mascota.inicial,
                  style: const TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    height: 1,
                    color: WearableColors.sobreAcento,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 72),
          child: Text(
            mascota.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: WearableColors.etiqueta.copyWith(fontSize: 15),
          ),
        ),
        const SizedBox(width: 2),
        flecha(Icons.chevron_right_rounded),
      ],
    );

    final contenido = AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animacion) {
        final entra = child.key == ValueKey(mascota.id);
        return FadeTransition(
          opacity: animacion,
          child: SlideTransition(
            position: Tween(
              begin: Offset((entra ? d : -d) * 0.4, 0),
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
        onTapAnterior: controller.anteriorMascota,
        onDeslizar: (haciaLaIzquierda) => haciaLaIzquierda
            ? controller.siguienteMascota()
            : controller.anteriorMascota(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: contenido,
        ),
      ),
    );
  }
}

/// Un punto por mascota, con la elegida alargada. Solo se muestra con varias.
class _PuntosMascotas extends StatelessWidget {
  const _PuntosMascotas({required this.controller});
  final WearableController controller;

  @override
  Widget build(BuildContext context) {
    final lista = controller.mascotas;
    final mascota = controller.mascota;
    if (mascota == null || lista.length < 2) return const SizedBox.shrink();
    final indice = lista.indexWhere((m) => m.id == mascota.id);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < lista.length && i < 6; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
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
            size: 40,
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
          Icon(icono, size: 40, color: WearableColors.error),
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
    required this.onTapAnterior,
    required this.onDeslizar,
    required this.child,
  });
  final bool activo;

  /// Toque en la mitad derecha: la siguiente mascota.
  final VoidCallback onTap;

  /// Toque en la mitad izquierda: la anterior.
  final VoidCallback onTapAnterior;
  final void Function(bool haciaLaIzquierda) onDeslizar;
  final Widget child;

  @override
  Widget build(BuildContext context) => activo
      ? GestureDetector(
          key: const Key('wearable-mascota'),
          onTapUp: (d) {
            final ancho = (context.findRenderObject() as RenderBox).size.width;
            if (d.localPosition.dx < ancho / 2) {
              onTapAnterior();
            } else {
              onTap();
            }
          },
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v.abs() > 120) onDeslizar(v < 0);
          },
          behavior: HitTestBehavior.opaque,
          child: child,
        )
      : child;
}
