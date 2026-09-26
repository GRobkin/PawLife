// views/widgets/eliminar_mascota.dart
//
// Borrar una mascota se pide desde dos sitios (el menú de su tarjeta en el
// listado y el botón de la papelera en el detalle) y tiene que avisar de lo
// mismo en los dos, así que la confirmación vive aquí.

import 'package:flutter/material.dart';

import '../../models/pawlife_models.dart';
import '../../services/pawlife_repository.dart';
import '../../theme/app_colors.dart';

/// Pide confirmación y borra. Devuelve true solo si se borró de verdad.
///
/// El diálogo enumera lo que se lleva por delante: el backend borra las
/// registros relacionados en cascada y no hay forma de recuperarlos, así que quien
/// pulsa tiene que saber que no se está borrando "solo la ficha".
Future<bool> confirmarYEliminarMascota(
  BuildContext context,
  Mascota mascota, {
  PawLifeRepository? repositorio,
}) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text('¿Eliminar a ${mascota.nombre}?'),
      content: const Text(
        'Se borrarán también sus vacunas, medicamentos, registros de peso y '
        'paseos. No se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(contexto).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(contexto).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.alerta),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (confirmado != true || !context.mounted) return false;

  try {
    await (repositorio ?? PawLifeRepository()).deleteMascota(mascota.id);
    if (!context.mounted) return true;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${mascota.nombre} eliminada.')));

    return true;
  } catch (e) {
    if (!context.mounted) return false;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));

    return false;
  }
}
