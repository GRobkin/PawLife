# Plan: pendientes de PawLife + interfaz de reloj (wearable)

Fecha: 28/10/2026. Es un plan: nada de la sección 2 está implementado todavía.

## 1. Decisiones ya tomadas

| Tema | Decisión |
|---|---|
| Función central del reloj (Core) | **Paseo: iniciar, pausar y terminar** |
| Datos | **Conectada al paseo real**: reutiliza la lógica existente (tiempo, GPS, guardado). Un paseo hecho desde el reloj queda guardado como cualquier otro |
| Acceso | **Barra superior del Home**: icono de reloj (`Icons.watch`) junto al avatar |
| Prioridad | Es una mejora más del proyecto; se integra después de lo que ya está en curso |
| Calorías (US27) | Descartada |

Fuente del requisito: «O mundo no pulso» (Prof. Matheus Fialho) y el enunciado pegado. Resumen de lo que exige:
- 5 segundos para resolver la acción; una o dos funciones.
- Fondo `#000000` absoluto, alto contraste, pesos medios a pesados, textos de una o dos palabras, color de acento puro solo para confirmar o alertar.
- Sin teclado ni `TextField`; botones grandes.
- Contenido centrado en un área **exacta de 250 × 250 px**; bonus: `ClipOval` como padre.
- Código aislado en su propia carpeta y ruta; en la app, `lib/views/wearable/` (la carpeta actual se llama `views`, no `view`).
- Probar en Flutter Web con 250 × 250 antes que en hardware real.

## 2. Reloj (wearable)

### 2.1 Pantalla y estados (un solo flujo, siempre una acción principal)

```
 Reposo ──(tocar INICIAR)──▶ En paseo ──(PAUSAR)──▶ Pausado
   ▲                          │  ▲                      │
   │                          │  └──────(SEGUIR)────────┘
   └────(listo)◀── Terminado ◀┘ (TERMINAR)
```

| Estado | Contenido (máx. 2 elementos de interacción) | Textos |
|---|---|---|
| Reposo | Botón circular gigante «INICIAR» con el nombre de la mascota activa debajo | «INICIAR», nombre |
| En paseo | Tiempo grande (`mm:ss`) + botón «PAUSAR»; pulsación larga o segundo botón para terminar | «PAUSAR» |
| Pausado | Tiempo atenuado + «SEGUIR» y «TERMINAR» | «SEGUIR», «TERMINAR» |
| Terminado | Distancia y tiempo + confirmación «GUARDADO» en el verde de marca | «GUARDADO» |
| Error | Un icono y 2 palabras («SIN GPS», «SIN MASCOTA») | |

Regla de los 5 segundos, medible: **iniciar un paseo = 1 toque**; pausar = 1 toque; terminar = 1 toque (con confirmación visual, no diálogo). Se comprueba con un test que cuenta los toques.

### 2.2 Estructura de archivos (aislada del móvil)
```
lib/views/wearable/
  wearable_screen.dart        ← ruta + marco 250×250 (ClipOval > Container 250×250 negro)
  wearable_walk_view.dart     ← estados y botones
  wearable_theme.dart         ← negro puro, tipografía pesada, acento
  wearable_controller.dart    ← adapta RouteViewModel al reloj (sin lógica de GPS propia)
lib/l10n/*.arb                ← textos cortos es/en/pt (claves wearable*)
test/wearable_test.dart       ← 250×250, sin TextField, conteo de toques, estados
```
Acceso: un `IconButton(Icons.watch)` en la barra superior del Home que hace `Navigator.push` a `WearableScreen`. El resto de la app no se modifica.

### 2.3 Reglas de diseño traducidas a comprobaciones
| Regla | Cómo se comprueba |
|---|---|
| 250 × 250 exactos | Test: `tester.getSize(find.byKey('wearable-frame')) == Size(250, 250)` |
| Fondo `#000000` | Test: el color del `Scaffold` y del marco es `Colors.black` |
| Sin teclado | Test: `find.byType(TextField)` y `TextFormField` no existen |
| Alto contraste | Test de contraste ≥ 7:1 para cada par texto/fondo (cálculo WCAG) |
| 1–2 interacciones | Test: máximo 2 widgets pulsables por estado |
| Textos cortos | Test: cada texto visible ≤ 12 caracteres (salvo la mascota) |
| Redondo vs cuadrado | `MediaQuery`/`LayoutBuilder`: contenido crítico dentro del círculo inscrito; márgenes extra en las esquinas |
| Sin gasto innecesario | El cronómetro se repinta **una vez por segundo**, no en cada fotograma; sin red en la pantalla |
| Sin movimiento molesto | Sin animaciones continuas; respeta «reducir movimiento» |

### 2.4 Pausar: cambio en la lógica compartida (lo único que toca el paseo móvil)
`RouteViewModel` hoy solo tiene `startWalk`/`stopWalk`. Para «Pausar» hay que agregar `pauseWalk`/`resumeWalk`:
- Al pausar: no se acumulan tiempo ni distancia; los puntos GPS recibidos se descartan.
- Al reanudar: el primer punto no se une al último anterior (evita contar el salto como distancia).
- El servicio en segundo plano sigue vivo (si no, Android puede matar la sesión).
- Decisión propuesta: la pantalla del paseo del móvil también muestra el estado «Pausado» (sin cambiar su diseño).
- Tests unitarios del ViewModel: pausa/reanuda no suma distancia ni tiempo; terminar estando pausado guarda bien.

### 2.5 Fases
| # | Fase | Resultado verificable |
|---|---|---|
| W1 | Maqueta autónoma con datos de ejemplo: marco 250×250 + `ClipOval`, 5 estados, tema negro | Capturas por estado en la galería de tests; tests 2.3 verdes |
| W2 | Pausar/reanudar en `RouteViewModel` | Tests unitarios del ViewModel |
| W3 | Conectar el controlador al ViewModel real y a la mascota activa | Un paseo iniciado en el reloj se guarda igual (test con repositorio simulado) |
| W4 | Botón de acceso en el Home + textos es/en/pt | Test de navegación; `flutter analyze` limpio |
| W5 | Prueba en Flutter Web 250×250 en el navegador (el PDF la recomienda) | Capturas del navegador; sin errores de consola |
| W6 | Hardware real (Wear OS) | **Fuera de alcance por ahora**: requiere un reloj y un proyecto Wear OS aparte |

Fuera de alcance: app nativa Wear OS/watchOS, complicaciones, sincronización Bluetooth real, voz.

## 3. Todo lo que falta del resto del proyecto

### A. Necesita tu autorización o tu cuenta (yo no puedo)
1. **Subir el trabajo** (push): `PawLife` `feature/us28-us29-idiomas-tema` y las ramas de `apipaw` (`feature/t11-premium-manual` incluye T04 y T09).
2. **Desplegar** la API (Vercel) y el Worker (`wrangler deploy`): sin esto el cron no llama al borrado, la inactividad ni el envío a todos.
3. **Firma Android** de distribución.
4. **Ejecutar** `tool/configure-premium-admins.cjs` (primero en simulación) y `tool/report-data-issues.cjs`.
5. Crear/confirmar **índices** de Firestore: `paseos`, `dispositivos`, `premiumGrants`, `subscriptions`.
6. Consultar `GET /api/admin/diagnostics/photos` tras desplegar (el runtime no publica GD).

### B. Decisiones tuyas (propuestas en `apipaw/docs/DECISIONES_PENDIENTES.md`)
Consentimiento y moderación de avisos globales; qué hacer con envíos inciertos; beneficios, precios y proveedor de Premium (T10) y valores heredados; alcance de visitas al veterinario; horas de descanso para inactividad; fuente tipográfica de titulares; finalizar paseo manteniendo pulsado; variantes de la tarjeta PNG; estados vacíos con ilustración.

### C. Pruebas que requieren un teléfono o servicios reales
GPS en exteriores, cámara, notificaciones (primer plano, segundo plano, cerrada), compartir PNG, avisos locales; correo de verificación y borrado completo contra Firebase real; envío a todos con Firestore/FCM reales; contraste y texto grande en pantallas reales; tests del panel antiguo.

### D. Código que puedo hacer sin decisiones tuyas (después del reloj)
- Visitas al veterinario, **solo si aprobás el alcance mínimo** (fecha, motivo corto y recordatorio).
- Aplicar la escala tipográfica a las cifras restantes si querés unificarlas.
- Nonce en la firma del cron (mitiga su reutilización dentro de 3 minutos).
- Mensaje del servidor para avisos globales por idioma (hoy el texto es el que escribe el administrador).

### E. Bloqueado por acceso o por terceros
Revisión externa de seguridad (paquete listo en `apipaw/docs/SEGURIDAD_REVISION_EXTERNA.md`); decisión de proveedor de pagos y de moderación (requiere facturación).

## 4. Orden propuesto
1. **Reloj W1 → W5** (aislado, no afecta lo desplegable).
2. Tu autorización de push/despliegue + ejecución de las herramientas (A).
3. Pruebas reales (C) con lo ya desplegado.
4. Decisiones (B) en el orden: consentimiento global → Premium → visitas al veterinario.
5. D según lo que decidas.

## 5. Preguntas abiertas → decididas (28/10/2026)
1. **Pausar**: no cuenta tiempo ni distancia mientras está pausado.
2. **Terminar**: sin confirmación extra; desde Pausado, «TERMINAR» es un toque y ya confirma.
3. **Vibración**: corta al iniciar y al terminar; sin sonido.
4. **Mascota**: la activa del Home; con varias y ninguna activa, la primera (como el botón de paseo actual).
5. **Idioma**: textos del reloj en es/en/pt.

## 6. Verificación e integración de git (revisado el 28/10/2026)

### Estado encontrado
| Repo | Rama actual | Commits sobre `master` | `master` vs remoto | Cambios sin commit |
|---|---|---|---|---|
| `PawLife` | `feature/us28-us29-idiomas-tema` | 14 (lineales) | igual al remoto (`d9d1b08`), 0 atrás | ninguno |
| `apipaw` | `feature/t11-premium-manual` | 11 (lineales) | igual al remoto (`e475895`), 0 atrás | `docs/IMPLEMENTATION_PROGRESS.md` (+36 líneas, del 27/10) |

- Las ramas de cada repo forman **una cadena sin divergencias**: se puede integrar con *fast-forward* sin conflictos (en `apipaw`: `respaldo/…` → `t04` → `t09` → `t11`; en `PawLife`: `respaldo/…` → `feature/us28-us29…`).
- Nada se publicó: ninguna rama existe en el remoto.

### Revisión del contenido
- Sin archivos grandes nuevos (>300 KB), sin claves privadas ni tokens en el diff. `.env.example` solo trae marcadores.
- Líneas finales: `apipaw` tiene `.gitattributes` (`eol=lf`); `PawLife` no, pero el índice está en LF y el árbol de trabajo en CRLF por `autocrlf`. Coherente, aunque conviene un `.gitattributes` en `PawLife`.
- `docs/IMPLEMENTATION_PROGRESS.md`: el cambio sin commit documenta T07 y el cambio de correo (27/10); **está desactualizado** (no menciona T04, T09, T11, idiomas, modo oscuro, ni el reloj) y todavía dice «sin smartwatch».
- Pruebas en la punta de cada rama: `apipaw` 16 scripts PHP + 13 Node verdes; `PawLife` `flutter analyze` limpio y 103 tests verdes.

### Pasos propuestos
1. **Actualizar y commitear** `IMPLEMENTATION_PROGRESS.md` (T04, T09, T11, idiomas/tema, reloj, decisiones, cuentas pendientes) y quitar «sin smartwatch».
2. Agregar `.gitattributes` a `PawLife` (`* text=auto eol=lf`) si lo aprobás.
3. **Integrar**: elegir estrategia (ver pregunta): fast-forward a `master`, o PRs separados por tarea.
4. **No publicar** sin tu autorización: push y despliegue son un paso aparte.
5. Después de integrar, volver a correr ambas suites sobre `master`.

## 7. Revisión de interfaz «antes y después» (contigo)
Objetivo: que **vos decidas** qué UI queda, con evidencia visual, antes de seguir.

1. Genero la galería con lo actual (`build/test-artifacts/gallery-*.png`, ya existe: bienvenida, Home, Mascotas, historial, peso, contraseña, compartir, selector) **y** las capturas «antes» guardadas del estado previo a la base visual (`before/`).
2. Preparo para cada pantalla un par **antes / después**, en claro y oscuro, es/en/pt.
3. Por cada cambio te pregunto: **conservar / ajustar / revertir**, y qué ajustar.
4. Lo que marques como «revertir» o «ajustar» lo hago en commits separados para poder deshacerlo.
5. Las propuestas **no implementadas** de la auditoría (finalizar manteniendo pulsado, variantes de la tarjeta PNG, estados vacíos con ilustración, fuente de titulares) se muestran como maqueta y **solo se implementan si las aprobás**.
6. Lo mismo para el reloj: después de W1 te muestro las capturas por estado y decidís antes de conectar al paseo real (W3).

Orden: **(1) integración de git → (2) revisión UI antes/después → (3) reloj W1 → revisión → W2–W5**.

## Estado del reloj (28/10/2026)
W1–W4 hechos en local: pausar/reanudar en `RouteViewModel` (tests en `test/route_view_model_pause_test.dart`), pantalla en `lib/views/wearable/`, acceso con `Icons.watch_outlined` en la barra del Home, textos es/en/pt (`wearable*`), `test/wearable_test.dart` y capturas en `test/wearable_gallery_test.dart`.
Pendiente: W5 (prueba en navegador a 250×250) y W6 (hardware Wear OS, fuera de alcance). Nada se probó con GPS real ni en dispositivo. Al reanudar, el trazo une el último punto previo con el primero posterior (sin sumar esa distancia).
