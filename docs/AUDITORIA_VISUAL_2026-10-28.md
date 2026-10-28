# Auditoría visual de la app Flutter — propuestas (T16)

Fecha: 28/10/2026. **Solo propuestas: no se implementó nada de esto.** Pendiente tu aprobación, punto por punto.

## Alcance y método

- Base: rama `feature/us28-us29-idiomas-tema` (idiomas y modo oscuro ya implementados).
- Revisé el código de todas las pantallas de `lib/views/` y las capturas renderizadas en test (bienvenida, historial de paseos, historial de peso, cambio de contraseña, selector de idioma, tarjeta de compartir; es/en/pt, claro/oscuro).
- **No pude ver renderizadas** Home, Mascotas, detalle de mascota, ruta en curso, resumen ni Privacidad: crean sus repositorios internamente y no se pueden alimentar con datos de ejemplo en un test. Mis comentarios sobre ellas salen del código. Nada se probó en dispositivo.
- Identidad a conservar: verde bosque/menta (`#12352A`, `#5CC58F`), tipografía NunitoSans, fotografía de mascotas. Las referencias (FIX Dessert Chocolatier, KINORIA, Cuberto, Lusion, Nike) se toman como principios —tipografía grande, composición con intención, movimiento con propósito—, no como interfaces a copiar.
- El panel admin queda fuera (conserva su diseño propio).

## Lo funcional ya resuelto (no es estética)

US28 (idiomas) y US29 (modo oscuro) están implementadas y commiteadas en local. Pendiente de lo funcional, aparte de esta auditoría: revisión lingüística, contraste medido, pruebas en dispositivo, y mensajes en español de algunos servicios.

## Hallazgos principales

1. **No hay escala tipográfica.** Cada pantalla fija sus tamaños a mano (`fontSize: 24/26/30…`). La "tipografía editorial grande" de la marca solo aparece en la bienvenida y en los títulos del historial; el resto es texto Material estándar.
2. **Tres estilos de campo de texto.** Login/registro y formularios de mascota usan campos con borde redondeado; los formularios de cuidados, cambio de contraseña/correo y Privacidad usan el campo Material por defecto (línea inferior). Se ve en las capturas: `Cambiar contraseña` parece de otra app.
3. **Tarjetas blancas uniformes.** Home apila tarjeta de mascota, tarjeta de paseo, dos tarjetas de resumen y filas de tareas, todas con la misma forma y peso visual. No hay jerarquía clara entre "lo que importa ahora" y el resto.
4. **La foto de la mascota se usa poco.** Solo el detalle tiene portada grande. En Home y Mascotas la foto es un avatar de 22–28 px, siendo el activo más emotivo de la app.
5. **Transiciones y movimiento por defecto.** Todas las rutas son `MaterialPageRoute` sin transición propia; los indicadores de carga son círculos genéricos; no hay microinteracciones (completar tarea, guardar paseo, cambiar de mascota).
6. **Modo oscuro correcto pero plano.** Tres superficies casi iguales; el acento verde carga todo el énfasis. Falta jerarquía de elevación.
7. **Espacio en pantallas anchas.** Solo el registro limita el ancho (420). En tablet o web las listas y formularios se estiran sin criterio.
8. **Detalles de accesibilidad.** Rótulos de 10–11 px (barra inferior, métricas), estados que dependen solo del color (vacuna vencida/próxima), objetivos táctiles de la barra inferior justos. Contraste del tema oscuro sin medir.
9. **Deuda de tokens.** Varias pantallas antiguas aún declaran `_kDarkGreen`, `_kAccentGreen`, etc. propios; el verde de acento ya difiere entre archivos (`#5CC58F` vs `#3FB77E`).

## Propuestas priorizadas

Impacto: A alto / M medio / B bajo. Dificultad: 1 baja (horas) / 2 media (1–2 días) / 3 alta (varios días).

| # | Propuesta | Impacto | Dif. | Tipo |
|---|-----------|:------:|:----:|------|
| 1 | **Unificar campos de texto y botones** en un único tema de componentes (`InputDecorationTheme`, `FilledButtonTheme`, etc. en `AppTheme`) y borrar los estilos locales | A | 1–2 | Base |
| 2 | **Escala tipográfica de marca**: 5–6 estilos (display, título, subtítulo, cuerpo, etiqueta) con pesos y tracking propios; aplicarla en saludo del Home, "Mis mascotas", títulos de paseo | A | 1–2 | Base |
| 3 | **Home con una jerarquía clara**: tarjeta de mascota grande con su foto como protagonista, "Iniciar paseo" como acción principal destacada, resumen de actividad en una sola banda con cifras grandes y tareas del día debajo | A | 2 | Pantalla |
| 4 | **Mascotas con tarjetas de foto**: imagen a sangre con nombre superpuesto (como la portada del detalle) y el estado de salud como indicador con icono + texto | A | 2 | Pantalla |
| 5 | **Transiciones con propósito**: transición compartida entre lista y detalle con la foto de la mascota (`Hero`), entradas escalonadas en listas, cambio de pestaña con fundido | M–A | 2 | Movimiento |
| 6 | **Microinteracciones** en tareas (tachado animado), guardado de paseo (check que se dibuja), cambio de mascota activa; respetando `reduceMotion` | M | 2 | Movimiento |
| 7 | **Esqueletos de carga** (shimmer sutil) en Home, Mascotas y Tareas en lugar de círculos | M | 1–2 | Movimiento |
| 8 | **Paseo en curso con cronómetro dominante**: cifras grandes, estado GPS como pulso, botón de finalizar con confirmación de mantener pulsado (esto último cambia comportamiento: requiere tu decisión) | M–A | 2 | Pantalla |
| 9 | **Resumen de paseo animado**: la traza se dibuja y las cifras cuentan hacia arriba | M | 2 | Movimiento |
| 10 | **Tarjeta para compartir** con variantes de composición (cifras grandes, foto más protagonista) manteniendo su fondo verde fijo; el PNG sigue legible | M | 2 | Pantalla |
| 11 | **Modo oscuro con elevación**: 3–4 niveles de superficie bien diferenciados y acento usado con mesura; medir contraste AA | M | 1–2 | Base |
| 12 | **Ancho máximo y márgenes por tamaño**: contenedor de 560–720 en tablet/web; en detalle, dos columnas | M | 1–2 | Base |
| 13 | **Barra inferior**: objetivos táctiles de 48 px, etiquetas ≥ 11 px, indicador de sección activa más claro y botón de paseo integrado en la barra | M | 2 | Pantalla |
| 14 | **Estados vacíos con personalidad**: ilustración o foto de mascota en lugar de icono gris + texto | B–M | 2 | Pantalla |
| 15 | **Bienvenida**: wordmark mayor, entrada animada del logo y los botones, foto con zoom lento; el botón de idioma se mantiene | M | 2 | Pantalla |
| 16 | **Estados de salud sin depender del color**: icono distinto y texto en vacuna vencida/próxima/sana | M | 1 | Accesibilidad |
| 17 | **Limpieza de tokens**: borrar constantes locales de color y usar solo `AppColors`/`AppPalette`; decidir un único verde de acento | B (interno) | 1–2 | Deuda |

### Orden sugerido

1. **Base primero** (1, 2, 11, 12, 17): todo lo demás se apoya en esto y casi no cambia la apariencia por sí solo, solo la vuelve coherente.
2. **Pantallas de mayor visibilidad** (3, 4, 15).
3. **Movimiento** (5, 6, 7, 9) una vez estables las pantallas.
4. **Paseo en curso y compartir** (8, 10) con cuidado: la tarjeta PNG es una entrega visible y la pantalla de paseo toca GPS.
5. **Accesibilidad** (13, 16) en paralelo con lo anterior.

## Decisiones que necesito de vos

- ¿Aprobás empezar por la **base** (1, 2, 11, 12, 17)? Es el cambio más seguro y se puede revisar con capturas antes/después.
- La propuesta 8 incluye un cambio de comportamiento (finalizar paseo manteniendo pulsado). ¿La querés o solo el cambio visual?
- ¿Tipografía: seguir con NunitoSans o evaluar una fuente de titulares con más carácter (con coste de peso y licencia)?
- ¿Querés maquetas antes/después de Home y Mascotas **antes** de aprobar? Las puedo preparar sin tocar la app.

## Qué no se midió

- Contraste (WCAG AA) del tema oscuro y de los textos pequeños.
- Rendimiento de animaciones propuestas en gama baja.
- Pantallas Home, Mascotas, detalle, ruta, resumen y Privacidad renderizadas.
- Cualquier cosa en dispositivo físico.

## Estado de implementación (actualizado)

Hechas (rama `feature/us28-us29-idiomas-tema`, sin probar en dispositivo): 1, 2 (definida; aplicada en Home y Mascotas), 3, 4, 5 (transición compartida con la foto; sin transiciones de ruta propias), 6 (tareas del Home), 7 (esqueletos en Home, Mascotas y Tareas), 9 (distancia del resumen cuenta hacia arriba; la traza no se dibuja animada), 11, 12, 13, 15 (entrada animada; sin zoom lento de la foto), 16, 17, y cifras grandes en el cronómetro del paseo (parte visual de la 8).

No hechas: 8 (finalizar manteniendo pulsado: cambia comportamiento), 10 (variantes de la tarjeta PNG), 14 (estados vacíos con ilustración), aplicar la escala tipográfica en el resto de pantallas, transiciones de ruta propias.
