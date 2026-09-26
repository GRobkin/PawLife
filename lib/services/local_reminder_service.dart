import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

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
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
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
    } catch (error) {
      debugPrint('No se pudieron actualizar los avisos locales: $error');
    }
  }

  Future<void> _sync(PawLifeRepository repository) async {
    if (!_supported) return;
    await _init();
    final pets = await repository.fetchMascotas();
    final reminders = await repository.fetchRecordatorios();
    final now = DateTime.now();
    final events = <_Notice>[];

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
      final vaccines = await repository.fetchVacunas(pet.id);
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
              'Vacuna de ${pet.nombre}',
              'Se acerca ${vaccine.nombre}: ${due.day}/${due.month}/${due.year}.',
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
                  'Medicamento de ${pet.nombre}',
                  '${medicine.nombre}: ${medicine.dosis}.',
                ),
              );
            }
          }
        }
      }
    }

    events.sort((a, b) => a.at.compareTo(b.at));
    await _notifications.cancelAllPendingNotifications();
    // iOS admite un número limitado de avisos pendientes. Se priorizan los próximos.
    for (var index = 0; index < events.length && index < 60; index++) {
      final event = events[index];
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

class _Notice {
  const _Notice(this.key, this.at, this.title, this.body);
  final String key;
  final DateTime at;
  final String title;
  final String body;
}
