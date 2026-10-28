# Plan técnico: Wear OS real (W6) — 28/10/2026

Decisión del usuario: **control remoto del teléfono**. El teléfono sigue haciendo GPS, sesión y guardado; el reloj inicia, pausa, termina y muestra el tiempo.

## Estado
| Pieza | Estado |
|---|---|
| Protocolo y puente del lado teléfono (`lib/views/wearable/wearable_puente.dart`) | Hecho, con tests (`test/wearable_puente_test.dart`). No está conectado a ningún transporte real |
| Interfaz del reloj (`WearableWalkView`) | Hecha, probada en tests y en navegador con datos simulados |
| Transporte Data Layer en el teléfono (Kotlin) | **Sin hacer** |
| App Wear OS (proyecto Android aparte) | **Sin hacer** |
| Compilación y pruebas en reloj/emulador | **Imposible hoy**: el equipo no tiene Android SDK ni reloj |

## Protocolo (versión 1)
- Reloj → teléfono, comando: `{"v":1,"comando":"iniciar|pausar|reanudar|terminar|aceptar"}`.
- Teléfono → reloj, estado: `{"v":1,"estado","segundos","distanciaMetros","mascota","error"}`.
- Mensajes de otra versión o mal formados se ignoran. Ningún comando borra datos.

## Lo que falta (en orden)
1. **Android SDK + Android Studio** y un emulador Wear OS (o un reloj con depuración por Wi-Fi).
2. **Módulo `wear/`** (app Wear OS, Flutter o Kotlin/Compose). Debe declarar `android.hardware.type.watch` y usar el mismo `applicationId` que la app del teléfono (requisito del Data Layer).
3. **Transporte en el teléfono:** un `MethodChannel`/`EventChannel` que implemente `WearableTransporte` con `MessageClient` (comandos) y `DataClient` (estado) de Google Play Services Wearable.
4. **Transporte en el reloj:** lo mismo del otro lado; la vista `WearableWalkView` se reutiliza alimentada por `WearableEstadoMensaje`.
5. **Segundo plano:** el paseo corre en el servicio de primer plano del teléfono; si el reloj se desconecta, el paseo sigue y al reconectar recibe el estado actual.
6. **Pruebas reales:** con el teléfono lejos/cerca, reloj sin conexión, pausa larga, guardado fallido.

## Decisiones/riesgos abiertos
- Publicar en Play Store una app de reloj exige la misma firma que el teléfono y revisión de Google para Wear OS.
- Dependencia nueva de Google Play Services Wearable (gratuita).
- No se evaluó iOS/watchOS (fuera de alcance).

## Qué NO se puede afirmar todavía
Que el reloj funcione en un dispositivo. Solo está probada la lógica en Dart con transportes simulados.
