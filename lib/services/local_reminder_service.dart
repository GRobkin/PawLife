import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:intl/intl.dart';

import '../l10n/active_locale.dart';
import '../models/horario_silencio.dart';
import '../models/pawlife_models.dart';
import 'pawlife_repository.dart';

class LocalReminderService {
  LocalReminderService._();

  static final instance = LocalReminderService._();

  final _notifications = FlutterLocalNotificationsPlugin();
  Future<void> _queue = Future.value();
  bool _initialized = false;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'pawlife_cuidados',
      'Cuidados y tareas',
      channelDescription: 'Avisos de vacunas, medicamentos y tareas',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_stat_pawlife',
      color: Color(0xFF12352A),
    ),
    iOS: DarwinNotificationDetails(),
  );

  static int _idFor(String key) {
    var hash = 0x811c9dc5;
    for (final byte in key.codeUnits) {
      hash = ((hash ^ byte) * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  Future<void> showIncoming({
    required String reminderId,
    required String title,
    required String body,
  }) async {
    if (!_supported) return;
    // En "no molestar" no se muestra; el aviso sigue en la lista de tareas.
    if ((await HorarioSilencio.leer()).contiene(DateTime.now())) return;
    await _init();
    await _notifications.show(
      id: _idFor('recordatorio:$reminderId'),
      title: title,
      body: body,
      notificationDetails: _details,
    );
  }

  Future<void> _init() async {
    if (!_supported || _initialized) return;
    timezone_data.initializeTimeZones();
    try {
      final zone = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(zone));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      // El canal existe desde el principio: los push del servidor lo piden
      // por su id y, si no existiera, caerían en uno genérico.
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          'pawlife_cuidados',
          'Cuidados y tareas',
          description: 'Avisos de vacunas, medicamentos y tareas',
          importance: Importance.high,
        ),
      );
      await android?.requestNotificationsPermission();
    }
    _initialized = true;
  }

  Future<void> clear() {
    final result = _queue.then((_) async {
      if (!_supported) return;
      await _init();
      await _notifications.cancelAllPendingNotifications();
    });
    _queue = result.catchError((Object _) {});
    return result;
  }

  Future<void> sync(PawLifeRepository repository) {
    final result = _queue.then((_) => _sync(repository));
    _queue = result.catchError((Object _) {});
    return result;
  }

  Future<void> syncBestEffort(PawLifeRepository repository) async {
    try {
      await sync(repository);
    } catch (_) {
      // Best effort: sin avisos locales la app sigue funcionando y se
      // reintenta en la próxima sincronización.
    }
  }

  Future<void> _sync(PawLifeRepository repository) async {
    if (!_supported) return;
    await _init();
    final privacy = await repository.fetchPrivacy();
    final preferences = privacy['preferencias'];
    if (preferences is! Map<String, dynamic>) {
      throw const FormatException('Preferencias inválidas.');
    }
    if (preferences['recordatoriosCuidados'] == false) {
      await _notifications.cancelAllPendingNotifications();
      return;
    }
    final pets = await repository.fetchMascotas();
    final reminders = await repository.fetchRecordatorios();
    final now = DateTime.now();
    final events = <_Notice>[];
    final t = ActiveLocale.strings;
    final dateFormat = DateFormat.yMd(ActiveLocale.current.toLanguageTag());

    for (final reminder in reminders) {
      if (!reminder.completado && reminder.fecha.isAfter(now)) {
        events.add(
          _Notice(
            'recordatorio:${reminder.id}',
            reminder.fecha,
            'PawLife',
            reminder.mensaje,
          ),
        );
      }
    }

    for (final pet in pets) {
      // Solo la dosis vigente de cada vacuna: las anteriores son historial.
      final vaccines = dosisVigentes(await repository.fetchVacunas(pet.id));
      for (final vaccine in vaccines) {
        final due = vaccine.proximaFecha;
        final notice = DateTime(
          due.year,
          due.month,
          due.day,
          9,
        ).subtract(Duration(days: vaccine.anticipacionDias));
        if (notice.isAfter(now) &&
            !_covered(reminders, pet.id, 'vacuna', notice)) {
          events.add(
            _Notice(
              'vacuna:${vaccine.id}',
              notice,
              t.noticeVaccineTitle(pet.nombre),
              t.noticeVaccineBody(vaccine.nombre, dateFormat.format(due)),
            ),
          );
        }
      }

      final medicines = await repository.fetchMedicamentos(pet.id);
      for (final medicine in medicines.where((m) => m.activo)) {
        for (var day = 0; day < 30; day++) {
          final date = DateTime(now.year, now.month, now.day + day);
          if (date.isBefore(
            DateTime(
              medicine.fechaInicio.year,
              medicine.fechaInicio.month,
              medicine.fechaInicio.day,
            ),
          )) {
            continue;
          }
          final end = medicine.fechaFin;
          if (end != null &&
              date.isAfter(DateTime(end.year, end.month, end.day))) {
            continue;
          }
          for (final horario in medicine.horarios) {
            final parts = horario.split(':');
            if (parts.length != 2) continue;
            final hour = int.tryParse(parts[0]);
            final minute = int.tryParse(parts[1]);
            if (hour == null || minute == null || hour > 23 || minute > 59) {
              continue;
            }
            final time = DateTime(
              date.year,
              date.month,
              date.day,
              hour,
              minute,
            );
            if (time.isAfter(now) &&
                !_covered(reminders, pet.id, 'medicamento', time)) {
              events.add(
                _Notice(
                  'medicamento:${medicine.id}:${date.toIso8601String()}:$horario',
                  time,
                  t.noticeMedicationTitle(pet.nombre),
                  t.noticeMedicationBody(medicine.nombre, medicine.dosis),
                ),
              );
            }
          }
        }
      }
    }

    final silencio = await HorarioSilencio.leer();
    await _enviarHorarioAlServidor(repository, preferences, silencio);
    final programados = planificarAvisos([
      for (final e in events) AvisoPlanificado(e.key, e.at, e.title, e.body),
    ], silencio);
    await _notifications.cancelAllPendingNotifications();
    for (final event in programados) {
      await _notifications.zonedSchedule(
        id: _idFor(event.key),
        title: event.title,
        body: event.body,
        scheduledDate: tz.TZDateTime.from(event.at, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Lleva el horario de no molestar al servidor: con la app cerrada es él
  /// quien decide si manda el push. Solo escribe si hay diferencia; si falla,
  /// reintenta en la próxima sincronización.
  Future<void> _enviarHorarioAlServidor(
    PawLifeRepository repository,
    Map<String, dynamic> preferences,
    HorarioSilencio silencio,
  ) async {
    try {
      final zona = (await FlutterTimezone.getLocalTimezone()).identifier;
      if (silencio.coincideConServidor(preferences['noMolestar'], zona)) {
        return;
      }
      await repository.updatePreferences({'noMolestar': silencio.aApi(zona)});
    } catch (_) {
      // Sin red o sin zona: queda el horario local y se reintenta luego.
    }
  }

  bool _covered(
    List<Recordatorio> reminders,
    String petId,
    String type,
    DateTime time,
  ) {
    return reminders.any(
      (r) =>
          !r.completado &&
          r.mascotaId == petId &&
          r.tipo == type &&
          r.fecha.difference(time).inHours.abs() < 12,
    );
  }
}

/// Un aviso con su hora ya calculada.
class AvisoPlanificado {
  const AvisoPlanificado(this.key, this.at, this.title, this.body);
  final String key;
  final DateTime at;
  final String title;
  final String body;
}

/// iOS admite un número limitado de avisos pendientes: se programan los
/// próximos, como máximo este número.
const int maxAvisosProgramados = 60;

/// Pospone los avisos que caen en "no molestar" hasta que termina la franja,
/// los ordena por hora y se queda con los próximos [maxAvisosProgramados].
List<AvisoPlanificado> planificarAvisos(
  Iterable<AvisoPlanificado> avisos,
  HorarioSilencio silencio,
) {
  final lista = [
    for (final e in avisos)
      AvisoPlanificado(e.key, silencio.ajustar(e.at), e.title, e.body),
  ]..sort((a, b) => a.at.compareTo(b.at));
  return lista.take(maxAvisosProgramados).toList();
}

class _Notice {
  const _Notice(this.key, this.at, this.title, this.body);
  final String key;
  final DateTime at;
  final String title;
  final String body;
}
