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

El cliente sube los puntos del paseo ya filtrados por `GpsPointFilter`. El servidor los vuelve a revisar con sus propias reglas, sin confiar en la app:

- 1 punto por cada 100 m a ritmo de caminata (2 a 7 km/h).
- Los tramos entre 7 y 10 a 12 km/h no suman. Por encima de 10 a 12 km/h el paseo se marca como sospechoso y no puntúa.
- +5 puntos cada 10 minutos de actividad sin pausas largas.
- Misma duración para los dos.

Sobre `GpsPointFilter`: hoy corta a 30 km/h, un umbral pensado para descartar saltos del GPS. Para el puntaje hace falta una regla más estricta, y vive aparte, para no cambiar cómo se dibujan los paseos normales.

### Anti trampa

- Agregar `isMocked` y la precisión a cada punto guardado de un paseo que participa en un reto. Hoy `RoutePoint` no los guarda. Solo Android entrega `isMocked`; en iOS no existe, por lo que ahí la verificación depende del servidor.
- Descartar saltos imposibles y tramos con velocidad de vehículo, en el servidor.
- El podómetro queda como opción posterior: agrega un permiso y una dependencia.
- Ninguna regla evita todo. El diseño asume que un amigo tramposo se nota y se reporta, y que el premio es solo social.

## 5. Privacidad

- Nunca se comparte la ubicación en vivo. Cada persona ve solo su mapa y, en la batalla, los puntos de los dos.
- Batalla: lo único compartido es el puntaje. Sin mapa del rival.
- Dúo: lo único que ve la otra persona es el resultado recortado y alineado, generado por el servidor al terminar. Los trazos crudos no se leen nunca entre usuarios.
- Recorte: ~150 m al inicio y al final, solo en el dúo. En el paseo normal no cambia nada, el historial propio sigue completo.
- Bloqueo: quien bloquea no recibe más retos ni invitaciones, y las anteriores se cancelan.
- Todo lo social se puede apagar desde Privacidad y mis datos.

## 6. Interfaz

Respeta la identidad vigente: verde bosque y menta, tipografía editorial grande, fotos de mascotas. Para esta funcionalidad:

- Pantalla de reto con dos columnas para los participantes, la foto de cada mascota y el nombre, y las cifras en grande. La entrada reutiliza las animaciones propias.
- Estados de carga con esqueletos que copian la forma real, como el resto de la app.
- Reducir movimiento: sin animación de entrada, solo el estado final.
- Evitar los rasgos de interfaz hecha por IA que ya se acordaron: sin degradados duros, sin íconos de brillos, sin cuadrículas de tarjetas idénticas. Los dibujos del dúo se ven como trazo limpio sobre el mapa de la propia persona.

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
