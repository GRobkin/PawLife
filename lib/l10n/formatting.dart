// l10n/formatting.dart
//
// Fechas y números según el idioma activo de la app.

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String formatDateTime(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMd(locale).add_Hm().format(value);
}

String formatDate(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMd(locale).format(value);
}

String formatTime(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.Hm(locale).format(value);
}

/// "14 sep, 18:40" / "Sep 14, 18:40".
String formatDayMonthTime(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return '${DateFormat.MMMd(locale).format(value)}, '
      '${DateFormat.Hm(locale).format(value)}';
}
