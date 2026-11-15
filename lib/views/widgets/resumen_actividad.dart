import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

/// Una cifra del resumen: icono, título, valor grande y una línea de apoyo.
class CifraResumen {
  const CifraResumen(this.icono, this.titulo, this.valor, this.pista);
  final IconData icono;
  final String titulo;
  final String valor;
  final String pista;
}

/// Resumen de actividad de Home: el último paseo manda (cifra grande a la
/// izquierda), el tiempo activo va en un bloque menta y debajo una tira con los
/// kilómetros de los últimos 7 días, con el de hoy resaltado.
class ResumenActividad extends StatelessWidget {
  const ResumenActividad({
    super.key,
    required this.principal,
    required this.secundaria,
    this.kmPorDia,
  });

  final CifraResumen principal;
  final CifraResumen secundaria;

  /// Kilómetros de los últimos 7 días; el último es hoy. Null mientras carga.
  final List<double>? kmPorDia;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme;
    final hayBarras = kmPorDia != null && kmPorDia!.any((k) => k > 0);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: context.superficie,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 11,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Titulo(principal.icono, principal.titulo),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          principal.valor,
                          style: estilo.displaySmall?.copyWith(
                            fontSize: 40,
                            height: 1.05,
                            color: context.texto,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        principal.pista,
                        style: estilo.bodySmall?.copyWith(
                          color: context.textoTenue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 9,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: context.mentaSuave,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Titulo(secundaria.icono, secundaria.titulo),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            secundaria.valor,
                            style: estilo.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.marca,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          secundaria.pista,
                          style: estilo.bodySmall?.copyWith(
                            color: context.textoSuave,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hayBarras) ...[
            const SizedBox(height: 14),
            _TiraSemana(km: kmPorDia!),
          ],
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.icono, this.texto);
  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icono, size: 16, color: context.marca),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          texto,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: context.textoSuave),
        ),
      ),
    ],
  );
}

/// Siete barras (una por día, la última es hoy) con la inicial del día debajo.
class _TiraSemana extends StatelessWidget {
  const _TiraSemana({required this.km});
  final List<double> km;

  static const double _alto = 34;

  @override
  Widget build(BuildContext context) {
    final letras = MaterialLocalizations.of(context).narrowWeekdays;
    final hoy = DateTime.now();
    final maximo = km.reduce((a, b) => a > b ? a : b);
    final ultimo = km.length - 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < km.length; i++)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: _alto,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 14,
                      height: km[i] <= 0
                          ? 4
                          : 6 + (_alto - 6) * (km[i] / maximo),
                      decoration: BoxDecoration(
                        color: i == ultimo
                            ? context.marca
                            : km[i] <= 0
                            ? context.bordeSuave
                            : context.marca.withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  letras[hoy.subtract(Duration(days: ultimo - i)).weekday % 7],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: i == ultimo ? FontWeight.w900 : FontWeight.w600,
                    color: i == ultimo ? context.texto : context.textoTenue,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
