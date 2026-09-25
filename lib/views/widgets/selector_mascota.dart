// views/widgets/selector_mascota.dart
//
// Hoja para elegir mascota. La piden tres sitios (cambiarla en el Home,
// elegir a quién se le atribuye un paseo, y el botón de paseo del listado),
// así que vive en uno.

import 'package:flutter/material.dart';

import '../../models/pawlife_models.dart';
import '../../theme/app_colors.dart';
import 'foto_mascota.dart';

/// Devuelve la mascota elegida, o null si se cerró la hoja sin elegir.
///
/// [seleccionadaId] marca con un tilde la que ya está activa, para que se vea
/// de dónde se parte.
Future<Mascota?> elegirMascota(
  BuildContext context,
  List<Mascota> mascotas, {
  String titulo = 'Elegí una mascota',
  String? seleccionadaId,
}) {
  return showModalBottomSheet<Mascota>(
    context: context,
    builder: (contexto) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          // Una lista scrollable y acotada: con muchas mascotas, una Column
          // suelta se saldría de la pantalla.
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final mascota in mascotas)
                  ListTile(
                    leading: AvatarMascota(mascota: mascota, radio: 18),
                    title: Text(mascota.nombre),
                    subtitle: Text(mascota.subtitulo),
                    trailing: mascota.id == seleccionadaId
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.verdeAcento,
                          )
                        : null,
                    onTap: () => Navigator.of(contexto).pop(mascota),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
