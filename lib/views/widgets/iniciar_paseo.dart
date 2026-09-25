// views/widgets/iniciar_paseo.dart
//
// Arrancar un paseo necesita saber a qué mascota atribuirlo, y eso se resuelve
// igual desde el Home, desde el listado y desde el detalle. Vive aquí para no
// repetirlo en tres sitios.
//
// Sustituye al `buddy_123` fijo que usaba el Home antes de que existiera la
// pantalla de mascotas: se creaba una mascota llamada Buddy si no existía y
// todos los paseos se le atribuían, hubiera las mascotas que hubiera.

import 'package:flutter/material.dart';

import '../../models/pawlife_models.dart';
import '../../services/pawlife_repository.dart';
import '../../services/seleccion_mascota.dart';
import '../route_screen.dart';
import 'selector_mascota.dart';

/// Pide las mascotas si hace falta y abre la pantalla de paseo.
///
/// Usa la mascota activa (la que se elige en el Home) en vez de preguntar cada
/// vez: ya es una elección del usuario, y volver a pedirla en cada paseo sería
/// insistir. Solo pregunta si hay varias y ninguna está activa todavía.
///
/// [mascotas] permite pasar una lista ya cargada para ahorrarse la petición,
/// como hace el listado, que acaba de pedirlas.
Future<void> iniciarPaseo(
  BuildContext context, {
  List<Mascota>? mascotas,
}) async {
  var disponibles = mascotas;

  if (disponibles == null) {
    try {
      disponibles = await PawLifeRepository().fetchMascotas();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar tus mascotas: $e')),
      );
      return;
    }
  }

  if (!context.mounted) return;

  if (disponibles.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Agregá una mascota antes de registrar un paseo.'),
      ),
    );
    return;
  }

  // `resolver` cae en la primera mascota cuando no hay ninguna activa, así que
  // con una sola mascota nunca llega a preguntar.
  final elegida = disponibles.length == 1
      ? disponibles.first
      : SeleccionMascota.resolver(disponibles) ??
            await elegirMascota(
              context,
              disponibles,
              titulo: '¿Con quién vas a pasear?',
            );

  if (elegida == null || !context.mounted) return;

  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => RouteScreen(mascotaId: elegida.id)));
}
