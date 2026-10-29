// views/widgets/esqueletos.dart
//
// Esqueletos de carga con la forma de lo que va a aparecer: misma estructura,
// tamaños y separaciones que el contenido real. Toda pantalla que carga datos
// usa uno de estos dentro de `TransicionCarga`, así la espera y la llegada se
// ven igual en toda la app. Los indicadores giratorios quedan solo dentro de
// botones (guardar, comprar), donde la acción es de la persona.

import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import 'motion.dart';

/// Línea de texto simulada: un porcentaje del ancho disponible.
class _Linea extends StatelessWidget {
  const _Linea(this.fraccion, {this.alto = 12});

  final double fraccion;
  final double alto;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    alignment: Alignment.centerLeft,
    widthFactor: fraccion,
    child: Esqueleto(alto: alto, radio: alto / 2),
  );
}

/// Fila de lista: icono cuadrado, título, detalle y acción a la derecha.
/// Imita las filas de tareas, visitas, peso e historial.
class EsqueletoFila extends StatelessWidget {
  const EsqueletoFila({super.key, this.anchoTitulo = 0.6, this.accion = true});

  final double anchoTitulo;
  final bool accion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Esqueleto(alto: 40, ancho: 40, radio: 12),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Linea(anchoTitulo, alto: 14),
                const SizedBox(height: 8),
                const _Linea(0.4, alto: 11),
              ],
            ),
          ),
          if (accion) ...[
            const SizedBox(width: 14),
            const Esqueleto(alto: 24, ancho: 24, radio: 12),
          ],
        ],
      ),
    );
  }
}

/// Varias filas seguidas, separadas como en las listas reales.
class EsqueletoLista extends StatelessWidget {
  const EsqueletoLista({super.key, this.filas = 5, this.padding});

  final int filas;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    const anchos = [0.62, 0.48, 0.7, 0.55, 0.4, 0.66];
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (var i = 0; i < filas; i++)
          EsqueletoFila(anchoTitulo: anchos[i % anchos.length]),
      ],
    );
  }
}

/// Tarjeta de mascota del listado: avatar, nombre y raza, estado, peso y
/// próxima vacuna.
class EsqueletoTarjetaMascota extends StatelessWidget {
  const EsqueletoTarjetaMascota({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.superficie,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Esqueleto(alto: 60, ancho: 60, radio: 30),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Linea(0.45, alto: 16),
                    SizedBox(height: 8),
                    _Linea(0.6, alto: 12),
                  ],
                ),
              ),
              Esqueleto(alto: 36, ancho: 36, radio: 18),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Esqueleto(alto: 58, radio: 12)),
              SizedBox(width: 10),
              SizedBox(width: 120, child: Esqueleto(alto: 58, radio: 12)),
            ],
          ),
          SizedBox(height: 10),
          Esqueleto(alto: 58, radio: 12),
        ],
      ),
    );
  }
}

/// Listado de Mascotas: título, subtítulo y dos tarjetas.
class EsqueletoMascotas extends StatelessWidget {
  const EsqueletoMascotas({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
      children: const [
        _Linea(0.5, alto: 26),
        SizedBox(height: 10),
        _Linea(0.75, alto: 12),
        SizedBox(height: 22),
        EsqueletoTarjetaMascota(),
        SizedBox(height: 14),
        EsqueletoTarjetaMascota(),
      ],
    );
  }
}

/// Tarjeta del carrusel "Hoy": icono, hora, check y título.
class EsqueletoTareaHoy extends StatelessWidget {
  const EsqueletoTareaHoy({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.superficie,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Esqueleto(alto: 34, ancho: 34, radio: 11),
                  SizedBox(width: 10),
                  Esqueleto(alto: 13, ancho: 48, radio: 6),
                  Spacer(),
                  Esqueleto(alto: 28, ancho: 28, radio: 14),
                ],
              ),
              Spacer(),
              _Linea(0.55, alto: 15),
            ],
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}

/// Perfil: avatar, campo de nombre, preferencias y opciones agrupadas.
class EsqueletoPerfil extends StatelessWidget {
  const EsqueletoPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        const Center(child: Esqueleto(alto: 84, ancho: 84, radio: 42)),
        const SizedBox(height: 12),
        const Center(child: Esqueleto(alto: 12, ancho: 160, radio: 6)),
        const SizedBox(height: 28),
        const Esqueleto(alto: 56, radio: 14),
        const SizedBox(height: 24),
        const _Linea(0.25, alto: 12),
        const SizedBox(height: 10),
        const Esqueleto(alto: 48, radio: 24),
        const SizedBox(height: 18),
        const _Linea(0.3, alto: 12),
        const SizedBox(height: 10),
        const Esqueleto(alto: 48, radio: 24),
        const SizedBox(height: 18),
        const Esqueleto(alto: 52, radio: 14),
        const SizedBox(height: 28),
        Container(
          decoration: BoxDecoration(
            color: context.superficie,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            children: [
              EsqueletoFila(anchoTitulo: 0.35, accion: false),
              EsqueletoFila(anchoTitulo: 0.5, accion: false),
            ],
          ),
        ),
      ],
    );
  }
}

/// Premium: cabecera grande y los beneficios con su icono.
class EsqueletoPremium extends StatelessWidget {
  const EsqueletoPremium({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: const [
            Esqueleto(alto: 176, radio: 24),
            SizedBox(height: 26),
            _Linea(0.3, alto: 14),
            SizedBox(height: 10),
            EsqueletoFila(anchoTitulo: 0.5, accion: false),
            EsqueletoFila(anchoTitulo: 0.42, accion: false),
            EsqueletoFila(anchoTitulo: 0.36, accion: false),
            EsqueletoFila(anchoTitulo: 0.46, accion: false),
            EsqueletoFila(anchoTitulo: 0.52, accion: false),
          ],
        ),
      ),
    );
  }
}

/// Paseo recién abierto: el lugar del mapa y la tarjeta de cifras.
class EsqueletoPaseo extends StatelessWidget {
  const EsqueletoPaseo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(child: Esqueleto(alto: double.infinity, radio: 24)),
          SizedBox(height: 16),
          Esqueleto(alto: 120, radio: 20),
          SizedBox(height: 16),
          Esqueleto(alto: 56, radio: 16),
        ],
      ),
    );
  }
}

/// Filas sin scroll propio, para meter dentro de una pestaña o una lista.
class EsqueletoFilas extends StatelessWidget {
  const EsqueletoFilas({super.key, this.filas = 4});

  final int filas;

  @override
  Widget build(BuildContext context) {
    const anchos = [0.62, 0.48, 0.7, 0.55, 0.4, 0.66];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < filas; i++)
          EsqueletoFila(anchoTitulo: anchos[i % anchos.length]),
      ],
    );
  }
}

/// Tarjeta del historial de paseos: título, traza, fecha y cifras.
class EsqueletoTarjetaPaseo extends StatelessWidget {
  const EsqueletoTarjetaPaseo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.superficie,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Linea(0.45, alto: 14),
          SizedBox(height: 12),
          Esqueleto(alto: 120, radio: 14),
          SizedBox(height: 12),
          _Linea(0.35, alto: 11),
          SizedBox(height: 8),
          _Linea(0.55, alto: 18),
        ],
      ),
    );
  }
}
