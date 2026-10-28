// views/widgets/portada_mascota.dart
//
// Foto de la mascota a sangre, con un velo en la parte inferior para poder
// superponer texto. Sin foto, un fondo de marca con la inicial en grande.
// Lo usan las tarjetas de Mascotas y la tarjeta de mascota del Home.

import 'package:flutter/material.dart';

import '../../models/pawlife_models.dart';
import '../../theme/app_palette.dart';
import 'foto_mascota.dart';

class PortadaMascota extends StatelessWidget {
  const PortadaMascota({
    super.key,
    required this.mascota,
    required this.height,
    this.children = const [],
    this.heroTag,
  });

  final Mascota mascota;
  final double height;

  /// Widgets posicionados (`Positioned`) sobre la foto.
  final List<Widget> children;

  /// Si se indica, la foto vuela hacia el detalle con la misma etiqueta.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final foto = proveedorDeFoto(mascota.fotoUrl);
    Widget fondo = foto == null
        ? _FondoSinFoto(inicial: mascota.inicial)
        : Image(
            image: foto,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _FondoSinFoto(inicial: mascota.inicial),
          );
    if (heroTag != null) fondo = Hero(tag: heroTag!, child: fondo);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          fondo,
          // Velo: sin él, el texto blanco desaparece sobre una foto clara.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x99000000)],
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _FondoSinFoto extends StatelessWidget {
  const _FondoSinFoto({required this.inicial});

  final String inicial;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.esOscuro
              ? const [Color(0xFF1D3328), Color(0xFF16241D)]
              : const [Color(0xFFE8D9C0), Color(0xFFD5E3D2)],
        ),
      ),
      child: Center(
        child: Text(
          inicial,
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w800,
            color: context.marca.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}
