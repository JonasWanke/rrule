import 'dart:convert';

import 'package:meta/meta.dart';

import '../../recurrence_rule.dart';
import '../string/encoder.dart';
import '../string/ical.dart';

@immutable
class RecurrenceRuleToJsonOptions {
  const RecurrenceRuleToJsonOptions({
    this.isTimeUtc = false,
  });

  /// If true, all date/time strings will be suffixed with a 'Z' to indicate
  /// they are in UTC.
  final bool isTimeUtc;
}

@immutable
class RecurrenceRuleToJsonEncoder
    extends Converter<RecurrenceRule, Map<String, dynamic>> {
  const RecurrenceRuleToJsonEncoder({
    this.options = const RecurrenceRuleToJsonOptions(),
  });

  static const _byWeekDayEntryEncoder = ByWeekDayEntryToStringEncoder();

  final RecurrenceRuleToJsonOptions options;

  @override
  Map<String, dynamic> convert(RecurrenceRule input) {
    return <String, dynamic>{
      'freq': frequencyToString(input.frequency),
      if (input.until != null) 'until': _formatDateTime(input.until!),
      if (input.count != null) 'count': input.count,
      if (input.interval != null) 'interval': input.interval,
      if (input.bySeconds.isNotEmpty) 'bysecond': input.bySeconds.toList(),
      if (input.byMinutes.isNotEmpty) 'byminute': input.byMinutes.toList(),
      if (input.byHours.isNotEmpty) 'byhour': input.byHours.toList(),
      if (input.byWeekDays.isNotEmpty)
        'byday': input.byWeekDays.map(_byWeekDayEntryEncoder.convert).toList(),
      if (input.byMonthDays.isNotEmpty)
        'bymonthday': input.byMonthDays.toList(),
      if (input.byYearDays.isNotEmpty) 'byyearday': input.byYearDays.toList(),
      if (input.byWeeks.isNotEmpty) 'byweekno': input.byWeeks.toList(),
      if (input.byMonths.isNotEmpty) 'bymonth': input.byMonths.toList(),
      if (input.bySetPositions.isNotEmpty)
        'bysetpos': input.bySetPositions.toList(),
      if (input.weekStart != null) 'wkst': weekDayToString(input.weekStart!),
    };
  }

  String _formatDateTime(DateTime dateTime) {
    // Modified version of `dateTime.toIso8601String()` without sub-second
    // precision.
    assert(
      0 <= dateTime.year && dateTime.year <= iCalMaxYear,
      'Years with more than four digits are not supported.',
    );

    String twoDigits(int n) => n < 10 ? '0$n' : '$n';

    String fourDigits(int n) {
      final absolute = n.abs();
      final sign = n < 0 ? '-' : '';
      if (absolute >= 1000) return '$n';
      if (absolute >= 100) return '${sign}0$absolute';
      if (absolute >= 10) return '${sign}00$absolute';
      return '${sign}000$absolute';
    }

    final year = fourDigits(dateTime.year);
    final month = twoDigits(dateTime.month);
    final day = twoDigits(dateTime.day);
    final hour = twoDigits(dateTime.hour);
    final minute = twoDigits(dateTime.minute);
    final second = twoDigits(dateTime.second);
    final utcSuffix = options.isTimeUtc ? 'Z' : '';
    return '$year-$month-${day}T$hour:$minute:$second$utcSuffix';
  }
}
