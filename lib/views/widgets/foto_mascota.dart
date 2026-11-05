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
import '../../theme/app_palette.dart';

/// Proveedores ya construidos, por `fotoUrl`. Decodificar el base64 en cada
/// rebuild creaba un `MemoryImage` nuevo cada vez: Flutter no lo reconocía en
/// su caché y volvía a decodificar la imagen entera al scrollear o animar.
final _proveedores = <String, ImageProvider?>{};
const _maxProveedores = 24;

/// Convierte el `fotoUrl` de una mascota en algo que Flutter pueda pintar.
/// Devuelve null si no hay foto o si el valor no se entiende.
ImageProvider? proveedorDeFoto(String? fotoUrl) {
  if (fotoUrl == null || fotoUrl.isEmpty) return null;

  if (_proveedores.containsKey(fotoUrl)) {
    // Se vuelve a insertar para que quede como el más reciente.
    final guardado = _proveedores.remove(fotoUrl);
    _proveedores[fotoUrl] = guardado;
    return guardado;
  }

  final proveedor = _construir(fotoUrl);
  _proveedores[fotoUrl] = proveedor;
  if (_proveedores.length > _maxProveedores) {
    _proveedores.remove(_proveedores.keys.first);
  }
  return proveedor;
}

ImageProvider? _construir(String fotoUrl) {
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
  const AvatarMascota({super.key, required this.mascota, required this.radio});

  final Mascota mascota;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final original = proveedorDeFoto(mascota.fotoUrl);
    // Se decodifica al tamaño real del círculo, no la foto completa.
    final lado = (radio * 2 * MediaQuery.devicePixelRatioOf(context)).ceil();
    final foto = original == null
        ? null
        : ResizeImage.resizeIfNeeded(lado, null, original);

    return CircleAvatar(
      radius: radio,
      backgroundColor: context.mentaSuave,
      backgroundImage: foto,
      child: foto != null
          ? null
          : Text(
              mascota.inicial,
              style: TextStyle(
                fontSize: radio * 0.8,
                fontWeight: FontWeight.bold,
                color: context.marca,
              ),
            ),
    );
  }
}
