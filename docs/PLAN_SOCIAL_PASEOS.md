# Batallas de paseos y paseo dúo: propuesta adaptada a PawLife

Fecha: 30/10/2026. Solo plan: no se implementó nada. Prioridad: Could Have.

Este documento toma la propuesta social (batallas, paseo dúo, moderación) y la ajusta a lo que PawLife ya tiene hoy y a las reglas del proyecto. Lo que cambia respecto de la propuesta original está marcado como "Ajuste".

## 1. Punto de partida real

Lo que ya existe y se reutiliza:

- Seguimiento GPS con `geolocator` y `flutter_foreground_task`, mapa con `flutter_map`.
- `GpsPointFilter` (`lib/services/gps_point_filter.dart`): descarta lecturas con precisión peor de 25 m (50 m si lleva 30 s sin puntos), lecturas fuera de orden y saltos con velocidad mayor a 30 km/h. Es Dart puro y tiene tests.
- Cada punto de la ruta trae latitud, longitud y hora (`RoutePoint`). No guarda precisión ni si la lectura es simulada.
- Plan gratuito y Premium con límites que impone el servidor (`PlanLimits`): 2 mascotas, 5 tareas pendientes, historial de 7 días.
- API en PHP sobre Vercel y un Worker de Cloudflare con cron cada 5 minutos. Datos en Firestore.
- Privacidad ya resuelta: borrado de cuenta reanudable, exportación de datos, consentimientos, preferencias.

Lo que no existe:

- Amigos, invitaciones, retos, bloqueos ni reportes. No hay ninguna entidad social.
- Detección de ubicación simulada (`Position.isMocked`) ni podómetro.
- Moderación automática. La decisión vigente (T08) es solo confirmación humana de texto, porque los proveedores automáticos exigen facturación.

## 2. Restricciones que cambian la propuesta

| Propuesta original | Realidad del proyecto | Ajuste |
|---|---|---|
| Cloud Functions calculan puntos y arman el trazo recortado | Cloud Functions exige el plan Blaze (de pago), y la regla es mantener Firebase gratis | Esa lógica va como endpoints PHP en `apipaw` (Vercel), con el mismo patrón de `PlanLimits` y `AccountLifecycle`. Lo asíncrono lo dispara el cron del Worker |
| Firebase Storage para fotos | Storage exige Blaze. Las fotos hoy van reducidas dentro del documento | Mismo método para fotos del reto. Sin Storage |
| SafeSearch y Gemini para moderar imágenes y dibujos | Requieren facturación activada. Decisión vigente: no activarla sin autorización | Primera versión sin moderación automática de imágenes: el modo libre no permite exportar imagen, solo verse en la app, más reportes y bloqueos. Lista de palabras para texto |
| Lottie o Rive para la animación del reto | Agrega dependencia y peso | Animación propia con las piezas de `motion.dart` (entradas, rebote, resorte). Reduce movimiento ya está respetado |
| Reglas de Firestore evitan leer puntos GPS ajenos | La app escribe y lee a través de la API, no directo a Firestore | Se mantiene la regla: los puntos GPS de un paseo solo los lee su dueño. Lo compartido es un documento aparte con puntajes y, en el dúo, el trazo recortado |

## 3. Decisiones de producto que hace falta tomar

1. Amigos: ¿cómo se agregan? Opciones: código de invitación corto, enlace, o correo exacto. Sugerencia: código de invitación, porque no expone correos y no exige buscar usuarios (evita enumeración de cuentas).
2. Qué es gratis y qué es Premium. Propuesta: batalla asíncrona gratis (alimenta el uso y no cuesta tracking en vivo); paseo dúo Premium, como ya decía la propuesta. Máximo de amigos en plan gratuito, por ejemplo 5, impuesto por el servidor.
3. Mascota o persona: el puntaje es del paseo, y cada paseo ya pertenece a una mascota. Falta decidir si el reto es entre personas o entre mascotas. Sugerencia: entre personas, usando la mascota que cada una elija para esa batalla.
4. Edad mínima y consentimiento: es el primer lugar donde otra persona ve datos tuyos. Requiere aviso en privacidad y términos antes de activarlo, y un interruptor para desactivarlo por completo.

## 4. Arquitectura propuesta

### Datos nuevos en Firestore (todos con `userId` y cubiertos por el borrado y la exportación)

- `amistades/{id}`: dos usuarios, estado (pendiente, aceptada, bloqueada), quién invitó, fechas.
- `retos/{id}`: retador, retado, estado (propuesto, aceptado, rechazado, en curso, terminado, vencido), plazo, mascota de cada uno, puntajes finales. Lo escribe solo el servidor.
- `retoParticipaciones/{id}`: vínculo entre un reto y un paseo propio, con la verificación hecha. Solo lo lee su dueño y el servidor.
- `duos/{id}`: invitación, modo (molde o libre), estado, y la imagen o el trazo recortado final. Solo lo escribe el servidor.
- `reportes/{id}`: reportante, objeto reportado, motivo. Solo lo lee el equipo.

Hay que sumar estas colecciones a `AccountLifecycle::OWNED` y a `ExportService::ROOTS`, y definir qué pasa con un reto cuando una de las dos cuentas se borra (se cierra y se anonimiza el nombre en la otra).

### Endpoints nuevos en `apipaw`

- Amigos: crear código, canjear código, listar, aceptar, rechazar, bloquear, eliminar.
- Retos: proponer, responder, listar, ver resultado. Un paseo terminado se adjunta a un reto en curso con un POST, y el servidor lo puntúa.
- Dúo: invitar, responder, adjuntar paseo, obtener el resultado recortado.
- Reportar y bloquear.

Todos reutilizan el mismo esquema de autenticación, límites de frecuencia (`ReminderRateLimiter`) y bloqueo de cuentas en borrado. La regla de precio y estado tomado del cliente aplica igual que en Premium: el servidor decide el puntaje y quién gana, la app solo lo muestra.

### Puntaje (en el servidor)

La velocidad se eliminó como criterio de victoria: incentiva arrastrar al perro y haría que un chihuahua pierda siempre contra un border collie. La regla tiene que poder explicarse en una línea en la pantalla de resultados.

El cliente sube los puntos del paseo ya filtrados por `GpsPointFilter`. El servidor los vuelve a revisar con sus propias reglas, sin confiar en la app:

- 1 punto por cada 100 m a ritmo de caminata (2 a 7 km/h).
- Los tramos entre 7 y 10 a 12 km/h no suman. Por encima de 10 a 12 km/h el paseo se marca como sospechoso y no puntúa.
- +5 puntos cada 10 minutos de actividad sin pausas largas.
- Misma duración para los dos, a elegir al retar: 30 minutos, 1 hora o un día. Gana quien suma más.

Ajuste sobre la propuesta de sincronizar los puntajes cada 5 a 10 segundos con Firestore: el proyecto no tiene un canal en tiempo real, solo la API y un cron de 5 minutos. En la versión asíncrona no hace falta: cada paseo se puntúa al terminar. Una batalla en vivo con puntajes actualizándose requeriría consultas periódicas desde la app (cada 10 a 15 segundos) o un servicio de tiempo real, y se deja para una fase posterior.

Sobre `GpsPointFilter`: hoy corta a 30 km/h, un umbral pensado para descartar saltos del GPS. Para el puntaje hace falta una regla más estricta, y vive aparte, para no cambiar cómo se dibujan los paseos normales.

### Anti trampa

- Agregar `isMocked` y la precisión a cada punto guardado de un paseo que participa en un reto. Hoy `RoutePoint` no los guarda. Solo Android entrega `isMocked`; en iOS no existe, por lo que ahí la verificación depende del servidor.
- Descartar saltos imposibles y tramos con velocidad de vehículo, en el servidor.
- El podómetro queda como opción posterior: agrega un permiso y una dependencia. Serviría para casos como 3 km recorridos con 200 pasos.
- Ninguna regla evita todo. El diseño asume que un amigo tramposo se nota y se reporta, y que el premio es solo social.

### Paseo dúo en detalle

Técnicamente es casi una batalla sin puntaje, así que sale barato una vez hechas las batallas, y es la parte con más posibilidad de compartirse.

- Cada persona ve solo su recorrido durante el paseo.
- Al terminar, los dos trazos se unen por forma y no por ubicación: cada mitad se ancla donde la hizo cada una, así que se puede hacer con alguien de otra ciudad y el resultado no revela dónde caminó la otra persona. Cada trazo lleva su color y el inicio y el final ya recortados.

Modo con molde:

- Se elige una figura (corazón, estrella, huella). Cada persona dibuja su mitad.
- Al empezar elige dónde arranca. La plantilla aparece semitransparente sobre su mapa, anclada en esa posición, y puede escalarla y rotarla para que encaje con las calles.
- Lo recorrido se pinta del color de la persona y el siguiente tramo se resalta. No hay indicaciones de giro como en un GPS de auto: se ve la línea y se camina sobre ella.
- Si se desvía más de 20 a 30 m, el tramo se pinta de rojo o vibra el teléfono.
- Se muestra el porcentaje de la mitad propia y de la del compañero, solo el número.
- Cada mitad debe tener entre 300 y 500 m como mínimo, por el error del GPS de 5 a 15 m.
- Primera versión con plantillas que funcionen en cuadrícula. Ajustar figuras a calles reales queda para después.
- No requiere moderar dibujos, porque las figuras las define el equipo.

Modo libre:

- Sin figura previa. Cada persona ve solo su propio trazo, nunca el del compañero.
- Se muestran en semitransparente las zonas que se recortarán, para dibujar sin perder las puntas. Son círculos y no metros de recorrido, como las zonas de privacidad de Strava:
  - Inicio: círculo de unos 150 m alrededor de la salida. Lo recorrido adentro se ve tenue con "no se mostrará". El dibujo empieza al cruzar el borde.
  - Final: el círculo sigue la posición actual y muestra qué parte del trazo se perdería si se terminara ahí. Así se sabe que hay que cerrar la figura y seguir caminando hasta que el círculo ya no la toque.
- Botón "pausar dibujo": el tramo siguiente (por ejemplo, volver a casa) sigue sumando a las estadísticas pero no entra en el dibujo compartido. Con eso el recorte casi nunca afecta la figura.

## 5. Privacidad

- Nunca se comparte la ubicación en vivo. Cada persona ve solo su mapa y, en la batalla, los puntos de los dos.
- Batalla: lo único compartido es el puntaje. Sin mapa del rival.
- Dúo: lo único que ve la otra persona es el resultado recortado y alineado, generado por el servidor al terminar. Los trazos crudos no se leen nunca entre usuarios.
- Recorte: ~150 m al inicio y al final, solo en el dúo. En el paseo normal no cambia nada, el historial propio sigue completo.
- Bloqueo: quien bloquea no recibe más retos ni invitaciones, y las anteriores se cancelan.
- Todo lo social se puede apagar desde Privacidad y mis datos.

## 5 bis. Moderación

- Texto (nombres, apodos, mensajes de reto): lista de palabras prohibidas en español, con variantes rioplatenses, validada en el servidor.
- Reportar un dibujo o un usuario, y bloquear (impide retar o invitar). Los reportes van a una colección que revisa el equipo.
- Dibujos del modo libre: es el caso más difícil. Un filtro de fotos no detecta un símbolo de odio o un genital dibujado con una línea sobre un mapa. La solución completa es renderizar el trazo como imagen simple (línea negra sobre blanco, sin mapa) y clasificarla con un modelo multimodal al terminar el dúo, y si se marca no se genera ni se comparte la imagen. Eso requiere un proveedor de pago y facturación, así que queda fuera de la primera versión.
- El riesgo real aparece cuando la imagen sale de la app, porque dentro la ven solo dos amigos que eligieron hacerlo juntos. Por eso en la primera versión el modo libre no permite exportar la imagen. Compartir fuera de la app queda bloqueado hasta resolver la moderación.
- Si más adelante se permite compartir un paseo normal como imagen, se aplica el mismo recorte a la imagen exportada, aunque el historial propio siga completo.

## 6. Interfaz

Respeta la identidad vigente: verde bosque y menta, tipografía editorial grande, fotos de mascotas. Para esta funcionalidad:

- Pantalla de reto con dos columnas para los participantes, la foto de cada mascota y el nombre, y las cifras en grande. La entrada reutiliza las animaciones propias.
- Estados de carga con esqueletos que copian la forma real, como el resto de la app.
- Reducir movimiento: sin animación de entrada, solo el estado final.
- Evitar los rasgos de interfaz hecha por IA que ya se acordaron: sin degradados duros, sin íconos de brillos, sin cuadrículas de tarjetas idénticas. Los dibujos del dúo se ven como trazo limpio sobre el mapa de la propia persona.

### Animación del enfrentamiento ("showdown")

Pedido del usuario (30/10/2026): tiene que sentirse como la intro de pelea de un videojuego o un anime, intensa y muy bien elaborada visual y gráficamente. Es la pieza más vistosa de la función y la que se comparte. La maqueta aprobada como dirección tiene: franjas de cine, corte en diagonal verde bosque y menta, tarjetas de personaje con retrato, nombre en itálica gigante y km de la semana, onomatopeyas ("¡GUAU!", "¡GRR!"), tajo de luz, "VS" que se clava, destello, astillas, trama de puntos, sacudida y retratos que pasan de blanco y negro a color en el impacto.

Para llegar a calidad de videojuego hace falta más de lo que dan las animaciones básicas:

- Guion por tiempos (storyboard) antes de programar: cada golpe con su milisegundo, como en una intro de pelea. Duración total entre 2 y 3 segundos.
- Acercamiento de cámara a cada mascota antes del choque, con líneas de velocidad detrás de cada retrato.
- Retratos recortados (la mascota sin fondo) para que "salgan" de la tarjeta. Sin Storage ni un recortador automático, la primera versión usa la foto actual con un marco dinámico.
- Efectos con shaders de Flutter (`FragmentProgram`): destello, onda expansiva y trama de puntos de cómic dibujados en la GPU.
- Herramienta: evaluar Rive para la secuencia completa. Antes se había descartado por la dependencia nueva, pero para este nivel de calidad es la herramienta adecuada: permite animar a mano, con curvas y capas, y pesa poco. La decisión queda abierta.
- Vibración con patrón: un toque al entrar cada mascota y uno fuerte en el "VS".
- Sonido opcional (golpe, latido), apagado si el teléfono está en silencio.
- Rendimiento: 60 cuadros por segundo en teléfonos de gama media. Nada de desenfoque en tiempo real; precargar las fotos antes de empezar.
- Se puede saltar con un toque. Con "reducir movimiento" se muestra solo el cuadro final, sin destello ni sacudida.
- Diseño previo en Figma o Rive, aprobado por el usuario, antes de implementar.

## 7. Fases

| Fase | Contenido | Esfuerzo | Depende de |
|---|---|---|---|
| 0 | Decidir los 4 puntos de la sección 3, actualizar términos y privacidad | Bajo | Usuario |
| 1 | Amistades por código, bloqueo y reporte (sin retos todavía) | Medio | Fase 0 |
| 2 | Batalla asíncrona con puntaje en el servidor y revancha | Alto | Fase 1 |
| 3 | Anti trampa reforzado: `isMocked`, precisión por punto, revisión de saltos | Medio | Fase 2 |
| 4 | Paseo dúo en modo libre, con recorte y resultado como imagen en la app | Alto | Fase 1 |
| 5 | Dúo con molde, plantillas en cuadrícula | Alto | Fase 4 |
| 6 | Rachas, medallas y ranking semanal | Medio | Fase 2 |

Sugerencia: empezar por las fases 1 y 2. Entregan la parte social con menos riesgo y sin tracking en vivo.

## 8. Riesgos

- Mucho trabajo de servidor y de reglas de datos para una función "Could Have". Cada fase agrega colecciones, endpoints y casos de borrado.
- Moderación sin proveedor automático: depende de reportes y de revisión humana. Con pocos usuarios es viable; con muchos, no.
- Compartir imágenes del dúo fuera de la app obliga a decidir moderación antes de habilitarlo.
- El error normal del GPS (5 a 15 m) limita el modo con molde: figuras de menos de unos 300 a 500 m salen deformadas.
- Los retos en vivo (los dos paseando al mismo tiempo) necesitarían estado compartido en tiempo real, que no se resuelve con el cron de 5 minutos. Por eso se recomienda solo la versión asíncrona.

## 9. Pruebas necesarias antes de publicar

- Tests de puntaje con recorridos simulados: caminata, trote, bici, auto, saltos de GPS, pausas largas.
- Tests de aislamiento: una cuenta nunca lee puntos de otra, ni siquiera dentro de un reto.
- Tests de borrado y exportación con las colecciones nuevas.
- Pruebas en dispositivos reales: GPS en exteriores, ubicación simulada en Android, comportamiento con la pantalla apagada.

## 10. Descartado

No volver a proponer:

- Mostrar en vivo la ubicación del rival durante la batalla, o su mapa al final.
- Usar la velocidad como criterio para ganar.
- Ver el trazo del compañero mientras se dibuja en el modo libre.
- Indicaciones de navegación tipo GPS de auto en el modo con molde.

## 11. Pregunta abierta

La idea original habla de pasear con "otra gente", que puede ser más de una persona. Hoy el diseño es para dos. Falta decidir si se permiten grupos y cómo se divide la figura en ese caso. Con grupos cambia el modelo de datos del dúo (de un par a una lista) y el cálculo de porcentajes.

## 12. Otras ideas para después

- Rachas: días seguidos paseando, con una recompensa visible.
- Medallas: primer paseo, 10 km acumulados, primera batalla ganada, primer dibujo.
- Ranking semanal entre amigos, que se reinicia cada lunes para que nadie quede atrás para siempre.
- Desafíos semanales de la app, por ejemplo caminar 5 km en la semana o pasear antes de las 9.
- Foto del perro al terminar el paseo, que queda en la tarjeta del recorrido y pasa por el mismo filtro de imágenes.
