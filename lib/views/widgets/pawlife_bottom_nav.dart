// views/widgets/pawlife_bottom_nav.dart
//
// Barra inferior compartida. Los prototipos la repiten igual en Inicio,
// Mascotas y el detalle de mascota, así que vive en un solo sitio.
//
// Navega ella misma entre las secciones que existen. Las que todavía no están
// hechas (Tareas y Perfil) avisan en lugar de no hacer nada: un botón que se
// pulsa y no responde parece una app rota.

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_palette.dart';
import '../pets_screen.dart';
import '../tasks_screen.dart';
import '../profile_screen.dart';

enum SeccionNav { inicio, mascotas, tareas, perfil }

class PawLifeBottomNav extends StatelessWidget {
  const PawLifeBottomNav({
    super.key,
    required this.activa,
    required this.onPaseo,
    this.onReturn,
  });

  final SeccionNav activa;

  /// Qué hace el botón central. Lo decide cada pantalla porque el paseo
  /// necesita saber a qué mascota atribuirlo, y eso solo lo sabe quien llama.
  final VoidCallback onPaseo;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BottomAppBar(
      color: context.superficie,
      // Altura y padding explícitos. Material 3 le pone al BottomAppBar 80 de
      // alto con 12 de padding vertical propio, y sumándole el padding de aquí
      // el contenido no cabía: salía el "BOTTOM OVERFLOWED BY 4.0 PIXELS".
      //
      // Con 70 de alto y el padding propio a cero, el contenido (icono 22 +
      // rótulo de 10) entra con holgura incluso si el teléfono tiene la escala
      // de fuente subida.
      height: 70,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Item(
              icono: Icons.home_outlined,
              iconoActivo: Icons.home,
              etiqueta: t.navHome,
              seccion: SeccionNav.inicio,
              activa: activa,
              onTap: () => _irA(context, SeccionNav.inicio),
            ),
            _Item(
              icono: Icons.pets_outlined,
              iconoActivo: Icons.pets,
              etiqueta: t.navPets,
              seccion: SeccionNav.mascotas,
              activa: activa,
              onTap: () => _irA(context, SeccionNav.mascotas),
            ),
            // Botón central de paseo. No es una sección: es una acción, y por
            // eso nunca se pinta como activa.
            Semantics(
              button: true,
              label: t.startWalk,
              child: GestureDetector(
                onTap: onPaseo,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: context.botonFondo,
                  child: Icon(
                    Icons.directions_walk,
                    color: context.botonTexto,
                    size: 20,
                  ),
                ),
              ),
            ),
            _Item(
              icono: Icons.assignment_outlined,
              iconoActivo: Icons.assignment,
              etiqueta: t.navTasks,
              seccion: SeccionNav.tareas,
              activa: activa,
              onTap: () => _irA(context, SeccionNav.tareas),
            ),
            _Item(
              icono: Icons.person_outline,
              iconoActivo: Icons.person,
              etiqueta: t.navProfile,
              seccion: SeccionNav.perfil,
              activa: activa,
              onTap: () => _irA(context, SeccionNav.perfil),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _irA(BuildContext context, SeccionNav destino) async {
    if (destino == activa) return;

    switch (destino) {
      case SeccionNav.inicio:
        // Inicio es la raíz que monta el AuthGate, así que se vuelve vaciando
        // la pila en lugar de empujar otro Home encima.
        Navigator.of(context).popUntil((ruta) => ruta.isFirst);

      case SeccionNav.mascotas:
        // Se vacía la pila primero para que saltar entre secciones no la vaya
        // acumulando: Inicio > Mascotas > Inicio > Mascotas dejaría cuatro
        // pantallas vivas y el botón atrás recorriéndolas todas.
        Navigator.of(context).popUntil((ruta) => ruta.isFirst);
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PetsScreen()));

      case SeccionNav.tareas:
        Navigator.of(context).popUntil((ruta) => ruta.isFirst);
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TasksScreen()));
        onReturn?.call();

      case SeccionNav.perfil:
        Navigator.of(context).popUntil((ruta) => ruta.isFirst);
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
        onReturn?.call();
    }
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icono,
    required this.iconoActivo,
    required this.etiqueta,
    required this.seccion,
    required this.activa,
    required this.onTap,
  });

  final IconData icono;
  final IconData iconoActivo;
  final String etiqueta;
  final SeccionNav seccion;
  final SeccionNav activa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final esActiva = seccion == activa;
    final color = esActiva ? context.marca : context.textoTenue;

    return Semantics(
      button: true,
      selected: esActiva,
      label: etiqueta,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(esActiva ? iconoActivo : icono, color: color, size: 22),
                const SizedBox(height: 2),
                // Sin pasar de 1.3x: con más escala el rótulo desborda la barra.
                MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.3,
                  child: Text(
                    etiqueta,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: esActiva ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
