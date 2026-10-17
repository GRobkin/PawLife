# Plan de implementación y cierre: US15–US29

Fecha: 15/10/2026. Basado en la imagen de requisitos del usuario y la revisión del código actual. US20 (anuncios) queda expresamente excluido por solicitud del usuario. Este documento es un plan: no implica que las funciones pendientes ya estén implementadas.

## Alcance confirmado y decisiones abiertas

- Preservar la identidad de PawLife y los flujos que funcionan. El panel administrativo conserva su diseño propio.
- Idiomas: español, inglés y portugués únicamente en Flutter. Incluir formularios, errores, fechas, notificaciones locales y pantallas de compartir, no solo el menú.
- Premium debe tener cobros reales y permisos comprobados por el servidor. Aún faltan aprobación de beneficios, precio, moneda, proveedor/cuenta de cobro y alojamiento apto para una aplicación comercial.
- Propuesta de beneficios pendiente de aprobación: informe veterinario PDF y estadísticas avanzadas. Cuidado compartido requiere otro proyecto de permisos y queda fuera de la primera versión propuesta.
- El usuario pide planificar los pendientes del rango US15–US29. US27 se incluye como investigación e implementación condicionada aunque el documento original lo marcaba Won’t Have for now.
- No restringir retroactivamente datos ni funciones de usuarios existentes para introducir el plan de pago.
- La agenda veterinaria que hoy aparece como bloque vacío no pertenece a estas historias. Completarla requiere aprobar alcance adicional; de lo contrario, retirar la promesa visual vacía.

## Estado por historia y aceptación

| ID | Estado actual | Trabajo y criterio de aceptación |
| --- | --- | --- |
| US15 | Pendiente | Preferencia por mascota para avisar tras un plazo sin paseo registrado; se puede activar/desactivar y elegir el plazo. Un paseo guardado cancela/reprograma el aviso. No avisar por mascotas eliminadas ni de otra cuenta. Sin duplicados al sincronizar varios dispositivos; comprobar zona horaria, reconexión y permisos denegados. |
| US16 | Implementado | Conservar cálculo, resumen y detalle de velocidad máxima. Validar ausencia de GPS, puntos anómalos, pausas, unidades y resultados con un recorrido real. No duplicar esta funcionalidad. |
| US17 | Implementado | Conservar PNG y compartir. Verificar archivo íntegro, captura larga, nombres largos, idiomas, ambas apariencias, cancelar el menú y compartir realmente a otra app. No añadir ubicación más precisa que la que el usuario acepta compartir. |
| US18 | Parcial | Añadir cambio de contraseña desde Perfil para cuentas con contraseña. Reautenticar con Firebase, confirmar contraseña nueva, limpiar campos sensibles y dar errores útiles. Para acceso Google, usar el proveedor correspondiente; no inventar una contraseña ni cambiar el método de acceso sin consentimiento. Verificar vigencia/revocación de sesiones y recuperación por correo. |
| US19 | Nativo implementado; web incompleto | El servicio actual rechaza plataformas donde GoogleSignIn no admite authenticate, incluido su flujo web. Implementar rama Firebase Auth web soportada, conservando el flujo nativo. Comprobar popup cancelado/bloqueado, redirección si se adopta, cuenta existente, OAuth autorizado, cambio de usuario y cierre de sesión. |
| US21 | Pendiente | Implementar contratación, restauración/consulta de acceso, renovación, cancelación, vencimiento, pago rechazado y reembolso. Los beneficios se autorizan en la API; la UI no concede Premium. Precio y términos deben estar aprobados antes de activar el cobro. |
| US22 | Implementado | Verificar listado real por usuario, vacíos, errores, actualización al volver, varias mascotas y datos antiguos. Añadir paginación donde los límites actuales puedan ocultar tareas sin aviso. |
| US23 | Implementado | Verificar completar/reabrir, persistencia, error de red, actualización del Home y cancelación/reprogramación de avisos. Evitar doble acción y resultados tardíos después de cambiar de cuenta. |
| US24 | Implementado | Verificar alta y consulta de peso, validación de valores/fechas, edición si forma parte del flujo y persistencia. Formato decimal localizable sin alterar la unidad guardada. |
| US25 | Implementado | Verificar notas, borrado del contenido, Unicode, límites del servidor y aislamiento. Renderizar como texto, nunca como HTML. |
| US26 | Implementado para vacunas | Cerrar la aceptación con anticipación configurable para vacunas: 0 días, varios días, fecha pasada y cambio posterior. El horario del medicamento sigue siendo el horario de la dosis. Si se amplía a otros tipos, definir reglas por tipo y evitar dos avisos equivalentes. |
| US27 | Pendiente, condicionado | Elegir y documentar un modelo veterinario respaldado para las especies/actividades admitidas. Requiere peso y recorrido válido. Presentar estimación y sus límites; devolver «datos insuficientes/no disponible» cuando corresponda. No reutilizar una fórmula humana ni prometer exactitud o recomendaciones alimentarias. Comparar resultados con casos de referencia antes de exponer la función. |
| US28 | Pendiente | Localización completa es/en/pt, selector en Perfil y acceso previo al login, cambio inmediato y preferencia persistente. Nombres, notas y mensajes escritos por personas conservan su contenido original. Los identificadores de especies/tipos guardados no cambian con la traducción. |
| US29 | Pendiente | Modos claro, oscuro y sistema, con preferencia persistente. Conservar verdes de marca, contraste, estados de error, campos, diálogos, mapas y permisos. Revisar textos grandes y escalado del sistema; el PDF/PNG debe mantener una apariencia exportable legible. |

## Secuencia de implementación

### 0. Base de seguridad y preparación de entrega

1. Resolver la firma Android de producción, con clave fuera de Git y procedimiento de recuperación de esa clave. Mantener applicationId/Firebase hasta coordinar un cambio explícito. La firma de depuración actual no sirve como cierre de distribución.
2. Definir límites de texto/listas en los esquemas de la API acordes con los formularios, con errores 422 legibles. El límite global de 2 MiB no sustituye los límites por campo ni el límite del documento de Firestore.
3. Exigir autenticación reciente en acciones sensibles como borrar la cuenta/cambiar credenciales, verificada en el servidor cuando la operación pasa por la API. La confirmación visual no basta.
4. Completar el timeout de ApiClient para que cubra la recepción completa del cuerpo; actualmente solo cubre la espera inicial del stream.
5. Añadir protección de cuotas proporcional para búsquedas administrativas y escrituras generales; existen cuotas para recordatorios y envíos manuales, no un control global de todos los recursos.
6. Revisar configuración desplegada de CORS, autenticación, reglas, cuentas administrativas, logs y dependencias. Mantener sesiones web en memoria, CSP y comprobación de UID en cada endpoint del panel.

Salida: pruebas negativas de acceso y validación pasan; no hay claves privadas versionadas; versión de producción identificada; pendientes de infraestructura registrados sin ocultarlos.

### 1. Preferencias, idiomas y apariencia — US28/US29

1. Crear ARB y AppLocalizations con el generador de Flutter y una única fuente de traducciones. Validar placeholders, plurales, fechas, horas, decimales y mensajes de validación. No traducir en ejecución sustituyendo fragmentos de frases.
2. Introducir un controlador de preferencias para idioma y ThemeMode, con almacenamiento local y sincronización de campos permitidos del perfil cuando corresponda. Mantener preferencias visuales separadas de tokens y privilegios.
3. Sustituir los colores de superficie/texto de AppColors estáticos por tokens contextuales de ThemeData/ColorScheme. Las fotografías y los colores propios de marca pueden permanecer fijos.
4. Recorrer bienvenida, login/registro, Home, mascotas, cuidados, tareas, perfil, paseo activo, resumen, historial, detalle, compartir, errores y avisos locales. Los errores de API requieren códigos estables o un mapeo explícito; no mostrar mensajes del servidor en español en una UI inglesa.
5. Pasar el idioma seleccionado al contenido de avisos automáticos cuando corresponda. Reprogramar avisos locales tras un cambio. Los mensajes manuales del administrador mantienen el texto que este escribió.

Aceptación: reiniciar mantiene la preferencia; sistema/claro/oscuro funciona; no quedan cadenas españolas fijas visibles al usar en/pt; traducciones revisadas lingüísticamente; capturas y pruebas con texto largo y escala de texto ampliada.

### 2. Cuenta y autenticación — US18/US19

Implementar los flujos descritos en la tabla mediante AuthService, sin manejar contraseñas en PHP ni guardarlas localmente. La UI depende del proveedor real de la cuenta. Verificar reautenticación fallida, cancelación de Google, cierre de sesión, cuenta eliminada y respuesta tardía de una sesión anterior.

Aceptación: no se puede cambiar la contraseña ni ejecutar la acción sensible usando solo una condición de interfaz; no aparecen contraseñas/tokens en logs; el acceso Google funciona en cada plataforma declarada.

### 3. Avisos y tareas — US15/US22/US23/US26

1. Persistir la preferencia de inactividad por mascota y derivar la fecha del próximo aviso a partir del último paseo confirmado, no de una pantalla abierta.
2. Usar el programador existente y/o los avisos locales con una estrategia explícita de deduplicación. Identificador estable por mascota, tipo y ciclo del aviso; volver a comprobar la última actividad antes de emitirlo.
3. Respetar zona horaria, baja de mascota/cuenta, opt-out y permisos. Limitar la cantidad y frecuencia de avisos por usuario; no recorrer toda la base sin paginación.
4. Verificar anticipación de vacunas y consistencia entre Tareas, Home y avisos. Añadir los índices necesarios antes de activar consultas nuevas.

Aceptación: guardar un paseo evita el aviso anterior; completar una tarea no deja un aviso obsoleto; cambios offline no producen duplicados al reconectar; las tareas de otra cuenta nunca aparecen.

### 4. Paseos y datos — US16/US17/US24/US25/US27

Validar las funciones ya implementadas con los casos de la tabla. Agregar solamente los ajustes comprobados como necesarios. US27 se activa cuando su modelo esté validado; no mostrar un número inventado para llenar la interfaz. Conservar trazas/identificadores y datos históricos al modificar esquemas.

### 5. Premium — US21

**Decisiones previas:** beneficios, precio/moneda, periodicidad, cuenta de cobro y responsable comercial. Mercado Pago es una opción evaluada para una primera versión web; la integración final depende de capacidades/condiciones de esa cuenta. No se ha contratado ni activado un servicio de pago.

1. Resolver alojamiento comercial: Vercel Hobby no admite uso comercial. Para Google Play/App Store deben revisarse las reglas de compra y registro de cada tienda; publicar gratis en web no equivale a poder vender igual en todas las tiendas.
2. Crear órdenes/suscripciones vinculadas al UID autenticado desde el servidor. El cliente no decide precio, moneda, propietario ni premiumHasta.
3. Confirmar el estado con la API del proveedor; verificar firma/autenticidad de las notificaciones conforme a su documentación vigente. Un retorno del checkout no concede acceso.
4. Procesar eventos con identificadores únicos y transiciones válidas, tolerando duplicados y desorden. Comprobar comercio receptor, producto/plan, importe, moneda y usuario vinculado.
5. Proteger todos los recursos Premium en el backend y reflejar acceso activo/vencido en Flutter. Expirar no borra datos del usuario. Definir qué sucede al cancelar al final del período y ante reembolsos.
6. En el panel administrativo, mostrar estado y auditoría si se agrega gestión de suscripciones. No usar el permiso general del panel de avisos para conceder Premium silenciosamente ni exponer credenciales del proveedor al navegador.
7. Verificar modo de prueba: pago válido, rechazado, pendiente, cancelación, renovación, vencimiento, reembolso, webhooks falsos/repetidos/desordenados y acceso directo a un recurso sin derecho. La prueba real requiere autorización y cuenta configurada.

Aceptación: no se puede activar Premium modificando el perfil o el JavaScript; el estado coincide con el proveedor después de reiniciar y reconectar; los cobros y fallos tienen trazabilidad sin tarjetas ni secretos en logs.

## Verificación final por capas

- Flutter: análisis, pruebas unitarias/widget de estado y preferencias, integración de auth, avisos, paseos y pagos. Las seis pruebas actuales de paseos no cubren toda la aplicación.
- API: autenticación, propietario/mascota, campos prohibidos, límites, cuotas, concurrencia e idempotencia. Las nuevas rutas deben tener pruebas de denegación además de casos felices.
- Panel: usuario común/administrador, revocación, destinatario y mensaje maliciosos, doble envío, timeout, cambio de sesión y permisos. Conservar texto seguro mediante textContent y sesión en memoria.
- Dispositivos: Android real con pantalla apagada, permisos revocados, retorno desde cámara, red intermitente y recepción FCM con app abierta/en fondo/cerrada. iOS requiere macOS y dispositivo.
- Visual: es/en/pt × claro/oscuro/sistema en pantallas representativas; verificar móvil/tableta/web, teclado, foco, lector de pantalla, texto ampliado y movimiento reducido. El panel web permanece en español conforme al alcance.
- Despliegue: comparar commit local, versión publicada y configuración remota. Revalidar los tres administradores pedidos y ensayar recuperación de datos. No ejecutar borrados o cobros reales como parte de una prueba automática sin alcance aprobado.

## Definición de terminado

Cada historia debe tener evidencia de persistencia y errores, controles de seguridad pertinentes, traducción/apariencia cuando aplique y prueba en su plataforma objetivo. Separar siempre: código implementado, prueba local, despliegue y validación real. Ninguna captura, compilación o skill por sí sola certifica una app 100 % segura.
