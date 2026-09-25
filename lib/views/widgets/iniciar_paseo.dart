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
import '../route_screen.dart';
import 'foto_mascota.dart';

/// Pide las mascotas y abre la pantalla de paseo.
///
/// Con una sola mascota va directo; con varias pregunta, porque elegir la
/// primera sería adivinar y el paseo quedaría mal atribuido sin que se note.
/// Sin ninguna, avisa de que hay que crear una antes.
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

  if (disponibles.length == 1) {
    _abrir(context, disponibles.first);
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    builder: (contexto) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '¿Con quién vas a pasear?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          for (final mascota in disponibles!)
            ListTile(
              leading: AvatarMascota(mascota: mascota, radio: 18),
              title: Text(mascota.nombre),
              subtitle: Text(mascota.subtitulo),
              onTap: () {
                Navigator.of(contexto).pop();
                _abrir(context, mascota);
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

void _abrir(BuildContext context, Mascota mascota) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => RouteScreen(mascotaId: mascota.id)));
}
