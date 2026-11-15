import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/estadisticas_paseos.dart';
import '../../theme/app_palette.dart';
import 'motion.dart';

/// ¿Hay que apilar la racha y la meta en vertical? Sí en pantallas angostas o
/// con el texto agrandado: en fila no caben sin cortarse.
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
            color: context.superficie,
            borderRadius: BorderRadius.circular(20),
          ),
          child: apilar
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    racha,
                    Divider(
                      height: 22,
                      thickness: 1,
                      color: context.bordeSuave,
                    ),
                    metaSemanal,
                  ],
                )
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 9, child: racha),
                      VerticalDivider(
                        width: 20,
                        thickness: 1,
                        color: context.bordeSuave,
                      ),
                      Expanded(flex: 11, child: metaSemanal),
                    ],
                  ),
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
          size: 28,
          color: e.racha > 0 ? context.marca : context.textoTenue,
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
                  color: context.textoSuave,
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
                      fontSize: 26,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      color: context.texto,
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
                        color: context.texto,
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
                  color: context.textoSuave,
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
                          backgroundColor: context.mentaSuave,
                          color: context.marca,
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
                          color: context.superficie,
                          border: Border.all(color: context.bordeSuave),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 10,
                          color: context.textoSuave,
                        ),
                      ),
                    ),
                    cumplida
                        ? Icon(
                            Icons.check_rounded,
                            size: 24,
                            color: context.marca,
                          )
                        : Text(
                            '${e.paseosSemana}/$meta',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: context.texto,
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
                        color: context.textoSuave,
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
                        color: context.texto,
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
            color: context.superficie,
            borderRadius: BorderRadius.circular(20),
          ),
          child: apilar
              ? Column(
                  children: [
                    racha,
                    Divider(
                      height: 22,
                      thickness: 1,
                      color: context.bordeSuave,
                    ),
                    meta,
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 9, child: racha),
                    const SizedBox(width: 20),
                    const Expanded(flex: 11, child: meta),
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
