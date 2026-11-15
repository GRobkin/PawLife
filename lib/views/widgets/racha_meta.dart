import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/estadisticas_paseos.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_palette.dart';
import 'motion.dart';

/// ¿Hay que apilar la racha y la meta en vertical? Sí en pantallas angostas o
/// con el texto agrandado: en fila no caben sin cortarse.
/// La tarjeta es verde bosque (en oscuro, un nivel por encima del fondo) con el
/// verde menta como único acento: se distingue del resumen blanco de arriba.
Color _fondoTarjeta(BuildContext context) =>
    context.esOscuro ? AppColors.oscuroNivel2 : AppColors.verdeOscuro;
const Color _menta = AppColors.verdeAcento;
const Color _blanco = Colors.white;
final Color _blancoSuave = Colors.white.withValues(alpha: 0.72);
final Color _linea = Colors.white.withValues(alpha: 0.16);

bool _apilar(BuildContext context, double ancho) {
  final escala = MediaQuery.textScalerOf(context).scale(10) / 10;
  return ancho < 330 || escala > 1.25;
}

/// Tarjeta de Home con la racha de días y el avance de la meta semanal.
/// Tocar la meta permite elegir cuántos paseos por semana.
class RachaMeta extends StatelessWidget {
  const RachaMeta({
    super.key,
    required this.estadisticas,
    required this.meta,
    required this.onCambiarMeta,
    this.nombreMascota,
    this.limitada = false,
  });

  final EstadisticasPaseos estadisticas;
  final int meta;
  final VoidCallback onCambiarMeta;

  /// La racha es de la mascota activa; con el nombre se ve de quién es.
  final String? nombreMascota;

  /// Plan gratis: el servidor solo entrega 7 días de paseos, así que la racha
  /// no puede pasar de 7 y se muestra como "7+".
  final bool limitada;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, caja) {
        final apilar = _apilar(context, caja.maxWidth);
        final racha = _bloqueRacha(context);
        final metaSemanal = _bloqueMeta(context);
        return Container(
          padding: apilar
              ? const EdgeInsets.fromLTRB(16, 14, 12, 8)
              : const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            color: _fondoTarjeta(context),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (apilar) ...[
                racha,
                Divider(height: 22, thickness: 1, color: _linea),
                metaSemanal,
              ] else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 9, child: racha),
                      VerticalDivider(width: 20, thickness: 1, color: _linea),
                      Expanded(flex: 11, child: metaSemanal),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              _TiraDias(estadisticas: estadisticas),
            ],
          ),
        );
      },
    );
  }

  Widget _bloqueRacha(BuildContext context) {
    final t = AppLocalizations.of(context);
    final e = estadisticas;
    final tope = limitada && e.racha >= 7;
    final pista = tope
        ? t.streakFreeLimit
        : e.racha == 0
        ? t.streakStart
        : e.paseoHoy
        ? t.streakToday
        : t.streakKeep;
    final titulo = nombreMascota == null || nombreMascota!.isEmpty
        ? t.streakTitle
        : '${t.streakTitle} · $nombreMascota';
    return Row(
      children: [
        Icon(
          Icons.local_fire_department_rounded,
          size: 30,
          color: e.racha > 0 ? _menta : _blancoSuave,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _blancoSuave,
                ),
              ),
              // El número grande y la unidad al lado: no se corta.
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    tope ? '${e.racha}+' : '${e.racha}',
                    style: TextStyle(
                      fontSize: 30,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      color: _blanco,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      t.streakUnit(e.racha),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        color: _blanco,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                pista,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  color: _blancoSuave,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bloqueMeta(BuildContext context) {
    final t = AppLocalizations.of(context);
    final e = estadisticas;
    final cumplida = e.paseosSemana >= meta;
    final avance = (e.paseosSemana / meta).clamp(0.0, 1.0);
    return Semantics(
      button: true,
      label:
          '${t.weeklyGoalTitle}. ${t.weeklyGoalProgress(e.paseosSemana, meta)}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onCambiarMeta,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: avance),
                      duration: reducirMovimiento(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, _) => SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: v,
                          strokeWidth: 6,
                          strokeCap: StrokeCap.round,
                          backgroundColor: _linea,
                          color: _menta,
                        ),
                      ),
                    ),
                    // Insignia: avisa de que la meta se puede cambiar.
                    Positioned(
                      right: -5,
                      bottom: -5,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _fondoTarjeta(context),
                          border: Border.all(color: _linea),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 10,
                          color: _blancoSuave,
                        ),
                      ),
                    ),
                    cumplida
                        ? Icon(Icons.check_rounded, size: 24, color: _menta)
                        : Text(
                            '${e.paseosSemana}/$meta',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: _blanco,
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.weeklyGoalTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _blancoSuave,
                      ),
                    ),
                    Text(
                      cumplida
                          ? t.weeklyGoalDone
                          : t.weeklyGoalProgress(e.paseosSemana, meta),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: _blanco,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lunes a domingo: un círculo por día. Con paseo, relleno menta con tilde;
/// hoy sin paseo, contorno menta; el resto, tenue.
class _TiraDias extends StatelessWidget {
  const _TiraDias({required this.estadisticas});
  final EstadisticasPaseos estadisticas;

  @override
  Widget build(BuildContext context) {
    // narrowWeekdays empieza en domingo; la semana de la tarjeta, en lunes.
    final letras = MaterialLocalizations.of(context).narrowWeekdays;
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CirculoDia(
                    paseo: estadisticas.semana[i],
                    hoy: i == estadisticas.diaHoy,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    letras[(i + 1) % 7],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: i == estadisticas.diaHoy
                          ? FontWeight.w900
                          : FontWeight.w600,
                      color: i == estadisticas.diaHoy ? _blanco : _blancoSuave,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CirculoDia extends StatelessWidget {
  const _CirculoDia({required this.paseo, required this.hoy});
  final bool paseo;
  final bool hoy;

  @override
  Widget build(BuildContext context) => Container(
    width: 26,
    height: 26,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: paseo ? _menta : _linea.withValues(alpha: 0.1),
      border: hoy && !paseo ? Border.all(color: _menta, width: 2) : null,
    ),
    child: paseo
        ? const Icon(
            Icons.check_rounded,
            size: 16,
            color: AppColors.verdeOscuro,
          )
        : null,
  );
}

/// Mismo tamaño y estructura que [RachaMeta], con bloques en lugar de datos:
/// ocupa su lugar mientras llegan los paseos y nada salta al aparecer.
class RachaMetaEsqueleto extends StatelessWidget {
  const RachaMetaEsqueleto({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, caja) {
        final apilar = _apilar(context, caja.maxWidth);
        // En fila la tarjeta real mide unos 112 px (la pista ocupa dos líneas).
        final racha = _EsqueletoRacha(alto: apilar ? 60 : 84);
        const meta = _EsqueletoMeta();
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: _fondoTarjeta(context),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              if (apilar) ...[
                racha,
                Divider(height: 22, thickness: 1, color: _linea),
                meta,
              ] else
                Row(
                  children: [
                    Expanded(flex: 9, child: racha),
                    const SizedBox(width: 20),
                    const Expanded(flex: 11, child: meta),
                  ],
                ),
              const SizedBox(height: 12),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _EsqueletoRacha extends StatelessWidget {
  const _EsqueletoRacha({required this.alto});

  final double alto;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: alto,
    child: const Row(
      children: [
        Esqueleto(alto: 28, ancho: 28, radio: 14),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Esqueleto(alto: 10, ancho: 56, radio: 5),
              SizedBox(height: 8),
              Esqueleto(alto: 20, ancho: 90, radio: 10),
              SizedBox(height: 8),
              Esqueleto(alto: 9, ancho: 70, radio: 5),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EsqueletoMeta extends StatelessWidget {
  const _EsqueletoMeta();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 54,
    child: Row(
      children: [
        Esqueleto(alto: 50, ancho: 50, radio: 25),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Esqueleto(alto: 10, ancho: 64, radio: 5),
              SizedBox(height: 8),
              Esqueleto(alto: 14, ancho: 84, radio: 7),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Hoja para elegir cuántos paseos por semana. Devuelve null si se cierra sin
/// elegir.
Future<int?> elegirMetaSemanal(BuildContext context, int actual) {
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    backgroundColor: context.superficie,
    constraints: const BoxConstraints(maxWidth: 480),
    builder: (sheetContext) {
      final t = AppLocalizations.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.weeklyGoalPick,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final n in MetaSemanal.opciones)
                    ChoiceChip(
                      key: ValueKey('meta-$n'),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '$n',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      selected: n == actual,
                      onSelected: (_) => Navigator.pop(sheetContext, n),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
