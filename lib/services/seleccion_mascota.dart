// services/seleccion_mascota.dart
//
// Qué mascota está "activa" en la app. La elige el usuario en el Home y la
// usan tanto esa pantalla como el botón de paseo, que antes preguntaba cada
// vez a cuál atribuirlo.
//
// Se guarda el id y no el objeto: si se guarda la Mascota entera, al editarla
// desde otra pantalla esta copia se queda con el nombre y la foto viejos.
//
// Vive solo en memoria, así que al reabrir la app se vuelve a la primera
// mascota. Persistirla pediría `shared_preferences`, y para una preferencia
// tan liviana no parece que valga una dependencia más; si molesta, ese es el
// cambio.

import 'package:flutter/foundation.dart';

import '../models/pawlife_models.dart';

abstract final class SeleccionMascota {
  static final ValueNotifier<String?> id = ValueNotifier<String?>(null);

  static void seleccionar(Mascota mascota) => id.value = mascota.id;

  /// La mascota activa dentro de [mascotas], o la primera si la guardada ya no
  /// existe (pudo borrarse desde el listado) o si no hay ninguna guardada.
  ///
  /// Devuelve null solo si el usuario no tiene mascotas.
  static Mascota? resolver(List<Mascota> mascotas) {
    if (mascotas.isEmpty) return null;

    final guardado = id.value;
    if (guardado != null) {
      for (final mascota in mascotas) {
        if (mascota.id == guardado) return mascota;
      }
    }

    return mascotas.first;
  }
}
