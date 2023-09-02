import 'dart:convert';

import 'package:meta/meta.dart';

import '../../by_week_day_entry.dart';
import '../../frequency.dart';
import '../../recurrence_rule.dart';
import '../../utils.dart';
import 'ical.dart';
import 'string.dart';

@immutable
class RecurrenceRuleToStringOptions {
  const RecurrenceRuleToStringOptions({
    this.isTimeUtc = false,
  });

  /// If true, all time strings will be suffixed with a 'Z' to indicate they are
  /// in UTC.
  ///
  /// See [RFC 5545 Section 3.3.12](https://tools.ietf.org/html/rfc5545#section-3.3.12)
  /// for more information.
  final bool isTimeUtc;
}

@immutable
class RecurrenceRuleToStringEncoder extends Converter<RecurrenceRule, String> {
  const RecurrenceRuleToStringEncoder({
    this.options = const RecurrenceRuleToStringOptions(),
  });

  static const _byWeekDayEntryEncoder = ByWeekDayEntryToStringEncoder();

  final RecurrenceRuleToStringOptions options;

  @override
  String convert(RecurrenceRule input) {
    final value = StringBuffer(
      '$recurRulePartFreq=${frequencyToString(input.frequency)}',
    );

    if (input.until != null) {
      value
        ..writeKey(recurRulePartUntil)
        ..writeDateTime(input.until!, options);
    }

    value
      ..writeSingle(recurRulePartCount, input.count)
      ..writeSingle(recurRulePartInterval, input.interval)
      ..writeList(recurRulePartBySecond, input.bySeconds)
      ..writeList(recurRulePartByMinute, input.byMinutes)
      ..writeList(recurRulePartByHour, input.byHours)
      ..writeList(
        recurRulePartByDay,
        input.byWeekDays.map(_byWeekDayEntryEncoder.convert),
      )
      ..writeList(recurRulePartByMonthDay, input.byMonthDays)
      ..writeList(recurRulePartByYearDay, input.byYearDays)
      ..writeList(recurRulePartByWeekNo, input.byWeeks)
      ..writeList(recurRulePartByMonth, input.byMonths)
      ..writeList(recurRulePartBySetPos, input.bySetPositions);
    if (input.weekStart != null) {
      value.writeSingle(recurRulePartWkSt, weekDayToString(input.weekStart!));
    }

    return const ICalPropertyStringCodec().encode(ICalProperty(
      name: rruleName,
      value: value.toString(),
    ));
  }
}

String? frequencyToString(Frequency? input) {
  if (input == null) return null;

  return recurFreqValues.entries.singleWhere((e) => e.value == input).key;
}

String weekDayToString(int dayOfWeek) {
  assert(dayOfWeek.isValidRruleDayOfWeek);

  return recurWeekDayValues.entries
      .singleWhere((e) => e.value == dayOfWeek)
      .key;
}

extension _RecurrenceRuleDateString on DateTime {
  /// Pattern corresponding to the `DATE-TIME` rule specified in
  /// [RFC 5545 Section 3.3.5: Date-Time](https://tools.ietf.org/html/rfc5545#section-3.3.5).
  // It is based on DateTime.toIso8601String excluding 6 digit years
  String toRecurrenceRulePattern() {
    assert(
      0 <= year && year <= iCalMaxYear,
      'Years with more than four digits are not supported.',
    );

    final y = _fourDigits(year);
    final m = _twoDigits(month);
    final d = _twoDigits(day);
    final h = _twoDigits(hour);
    final min = _twoDigits(minute);
    final sec = _twoDigits(second);
    return '$y$m${d}T$h$min$sec';
  }

  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  static String _fourDigits(int n) {
    final absN = n.abs();
    final sign = n < 0 ? '-' : '';
    if (absN >= 1000) return '$n';
    if (absN >= 100) return '${sign}0$absN';
    if (absN >= 10) return '${sign}00$absN';
    return '${sign}000$absN';
  }
}

extension _RecurrenceRuleEncoderStringBuffer on StringBuffer {
  void writeDateTime(
    DateTime input,
    RecurrenceRuleToStringOptions options,
  ) {
    assert(input.isValidRruleDateTime);
    assert(
      0 <= input.year && input.year <= iCalMaxYear,
      'The date format used by RRULEs only support four-digit years. '
      'See https://tools.ietf.org/html/rfc5545#section-3.3.4 for more '
      'information.',
    );
    write(input.toRecurrenceRulePattern());
    if (options.isTimeUtc) write('Z');
  }

  void writeKey(String key) {
    write(';');
    write(key);
    write('=');
  }

  void writeSingle(String key, Object? value) {
    if (value == null) return;

    writeKey(key);
    write(value);
  }

  void writeList(String key, Iterable<Object> entries) {
    if (entries.isEmpty) return;

    writeKey(key);
    writeAll(entries, ',');
  }
}

@immutable
class ByWeekDayEntryToStringEncoder extends Converter<ByWeekDayEntry, String> {
  const ByWeekDayEntryToStringEncoder();

  @override
  String convert(ByWeekDayEntry input) =>
      '${input.occurrence ?? ''}${weekDayToString(input.day)}';
}
