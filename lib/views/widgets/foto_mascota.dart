// views/widgets/foto_mascota.dart
//
// Pintar la foto de una mascota en un solo sitio.
//
// `fotoUrl` puede traer dos cosas y conviene que solo haya un lugar que lo
// sepa: un data URI con la miniatura embebida, que es lo que guarda la app
// desde que se descartó Firebase Storage (ver services/photo_service.dart), o
// una URL http, que es lo que guardaban las versiones anteriores.

import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/pawlife_models.dart';
import '../../theme/app_colors.dart';

/// Convierte el `fotoUrl` de una mascota en algo que Flutter pueda pintar.
/// Devuelve null si no hay foto o si el valor no se entiende.
ImageProvider? proveedorDeFoto(String? fotoUrl) {
  if (fotoUrl == null || fotoUrl.isEmpty) return null;

  if (fotoUrl.startsWith('data:')) {
    final coma = fotoUrl.indexOf(',');
    if (coma == -1) return null;

    try {
      return MemoryImage(base64Decode(fotoUrl.substring(coma + 1)));
    } on FormatException {
      // Un base64 corrupto no debe tumbar la pantalla: se cae al avatar con
      // la inicial, igual que si no hubiera foto.
      return null;
    }
  }

  return NetworkImage(fotoUrl);
}

/// Foto circular de la mascota, o un círculo con su inicial si no tiene.
class AvatarMascota extends StatelessWidget {
  const AvatarMascota({
    super.key,
    required this.mascota,
    required this.radio,
  });

  final Mascota mascota;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final foto = proveedorDeFoto(mascota.fotoUrl);

    return CircleAvatar(
      radius: radio,
      backgroundColor: AppColors.verdeSuave,
      backgroundImage: foto,
      child: foto != null
          ? null
          : Text(
              mascota.inicial,
              style: TextStyle(
                fontSize: radio * 0.8,
                fontWeight: FontWeight.bold,
                color: AppColors.verdeOscuro,
              ),
            ),
    );
  }
}
