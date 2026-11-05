import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Deja libre la barra de navegación del sistema (atrás / inicio / recientes)
/// en Android para TODAS las pantallas.
///
/// Con la pantalla de borde a borde, esa barra se dibuja encima de la app y
/// tapa lo de abajo: botones, el final de las listas, el último párrafo. Las
/// pantallas con `ListView(padding: ...)` o sin `SafeArea` no descuentan ese
/// espacio por su cuenta. Aquí se reserva una sola vez, arriba de todo, y se
/// pone a cero en el `MediaQuery` de los hijos para que ningún `SafeArea`
/// interior lo vuelva a restar.
///
/// Con el teclado abierto no se reserva nada: el teclado ya cubre la barra y el
/// `Scaffold` se encarga de subir el contenido.
class AreaSegura extends StatelessWidget {
  const AreaSegura({super.key, required this.child, this.siempre = false});

  final Widget child;

  /// Aplica el margen en cualquier plataforma (pruebas). Por omisión, solo en
  /// Android: en iOS y escritorio no cambia nada.
  final bool siempre;

  @override
  Widget build(BuildContext context) {
    final esAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (!siempre && !esAndroid) return child;
    final mq = MediaQuery.of(context);
    final reservado = math.max(
      0.0,
      mq.viewPadding.bottom - mq.viewInsets.bottom,
    );
    if (reservado == 0) return child;
    return Padding(
      padding: EdgeInsets.only(bottom: reservado),
      child: MediaQuery(
        data: mq.copyWith(
          padding: mq.padding.copyWith(bottom: 0),
          viewPadding: mq.viewPadding.copyWith(bottom: 0),
        ),
        child: child,
      ),
    );
  }
}
