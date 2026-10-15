# Cierre de paseos y notificaciones — 15/10/2026

## Funciones implementadas

- **Historial:** Inicio → Ver historial de paseos, o ficha de mascota → Paseos → Abrir historial. Selección de mascota, fechas, distancia, duración, vista previa de ruta, actualización, errores y páginas de 30 registros. La API verifica dueño de mascota y cursor.
- **Detalle:** mapa, inicio/final del recorrido, estadísticas, foto y eliminación con confirmación. El historial se actualiza después de borrar.
- **PNG:** disponible al finalizar y desde un paseo guardado. Vista previa con mascota, foto del paseo si existe, fecha, distancia, duración y traza GPS. Imagen al triple de resolución de la tarjeta. No contiene calles ni coordenadas. Abre el menú de compartir; el navegador descarga el archivo cuando no admite compartir.
- **Cámara:** abre la cámara durante el paseo; permite cancelar, reemplazar o quitar la foto. Guarda una imagen reducida junto al recorrido sin Firebase Storage ni plan de pago.
- **Guardado:** identificador estable para reintentos; una respuesta perdida no duplica paseos. Fecha y mascota reales, errores visibles y confirmación antes de salir sin guardar.
- **Panel:** `https://apipaw.vercel.app/notificaciones`. Login Firebase por correo o Google; permisos por UID comprobados en el servidor. Búsqueda por correo completo, selección de destinatario, vista previa y confirmación. Hasta tres dispositivos distintos recientes, excluyendo demo/inactivos, cuota y registro de resultado. Repetir la misma solicitud no vuelve a enviar.

## Administración

Los permisos están en `configuracion/panel-notificaciones.administradores`, con UIDs de Authentication. Las reglas de Firestore impiden modificarlo desde la app. Los correos del perfil y los campos premium no conceden acceso.

Firebase encontró y habilitó `nespiuy@gmail.com`. No encontró cuentas activas para `erickdpino@gmail.com` ni `lautarotegui4@gmail.com`: primero deben ingresar o registrarse con esos correos en PawLife. El README del backend explica cómo asociar los UIDs después.

FCM puede aceptar un mensaje sin que el teléfono lo muestre. El panel informa la aceptación y los errores. No reintenta automáticamente avisos manuales, para evitar duplicados si se pierde una respuesta.

## Verificación

- Seis pruebas Flutter: historial, error/vacío, cursor HTTP, guardado sin duplicados, PNG válido y casos límite GPS.
- Pruebas PHP existentes más acceso administrativo, destinatarios, dispositivos ajenos/demo, repetición, foto y consulta paginada.
- Análisis Dart sin incidencias, compilación web release y revisión visual del panel y PNG. La compilación conserva un aviso por la fuente CupertinoIcons no declarada; los iconos Material de las pantallas nuevas se verificaron en el PNG.
- API y panel publicados: prueba real con dos cuentas temporales y 31 paseos de igual fecha. Se comprobaron dos páginas sin omisiones/duplicados, borrado, rechazo del acceso a paseos ajenos, rechazo del cursor de otra cuenta y rechazo del panel a usuarios comunes. Se eliminaron las cuentas y datos de prueba y se verificó el rechazo de sus sesiones antiguas. No se enviaron avisos a personas reales.
- El panel público cargó correctamente en Vercel, con login Firebase habilitado y sin errores de consola. No se ingresó con las cuentas del equipo ni se comprobó recepción FCM en un teléfono.

## Pendiente para validar la entrega completa

1. Android real: login, registro FCM, avisos con app abierta/en fondo/cerrada y permisos denegados/recuperados.
2. Paseo real con pantalla apagada, cámara, guardado, historial, compartir a otra app, borrado y pérdida de conexión.
3. No hay Android SDK en el equipo ni firma de producción configurada; no se verificó APK/AAB. La configuración existente firma release con la clave de depuración: debe reemplazarse antes de distribuir en una tienda. No cambiar applicationId sin registrar de nuevo la app en Firebase.
4. iOS requiere compilación y prueba en macOS/dispositivo. Se agregaron descripciones de permisos de cámara/galería; no se probó iOS aquí.
5. El PDF original de requisitos y los ZIP originales ya no están en las rutas compartidas. Se conservan los informes y el diseño extraído. Hay que contrastar otra vez con la especificación original antes de afirmar que se cumplieron todos sus requisitos.
6. La recuperación de datos sigue pendiente dentro del presupuesto gratuito; no se activaron copias de pago ni recuperación a un punto anterior.

Las pruebas automatizadas no sustituyen la verificación en dispositivo ni la comparación con los requisitos originales.
