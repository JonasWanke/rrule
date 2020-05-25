import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import '../../by_week_day_entry.dart';
import '../../frequency.dart';
import '../../recurrence_rule.dart';
import 'ical.dart';
import 'string.dart';

@immutable
class RecurrenceRuleToStringOptions {
  const RecurrenceRuleToStringOptions({
    this.isTimeUtc = false,
  }) : assert(isTimeUtc != null);

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
  }) : assert(options != null);

  static const _byWeekDayEntryEncoder = ByWeekDayEntryToStringEncoder();

  final RecurrenceRuleToStringOptions options;

  @override
  String convert(RecurrenceRule input) {
    final value = StringBuffer(
        '$recurRulePartFreq=${_frequencyToString(input.frequency)}');

    if (input.until != null) {
      value
        ..writeKey(recurRulePartUntil)
        ..writeDateTime(input.until, options);
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
      ..writeList(recurRulePartBySetPos, input.bySetPositions)
      ..writeSingle(recurRulePartWkSt, _weekDayToString(input.weekStart));

    return ICalPropertyStringCodec().encode(ICalProperty(
      name: rruleName,
      value: value.toString(),
    ));
  }
}

String _frequencyToString(RecurrenceFrequency input) {
  if (input == null) {
    return null;
  }

  return recurFreqValues.entries.singleWhere((e) => e.value == input).key;
}

String _weekDayToString(DayOfWeek day) {
  if (day == null) {
    return null;
  }

  return recurWeekDayValues.entries.singleWhere((e) => e.value == day).key;
}

extension _RecurrenceRuleEncoderStringBuffer on StringBuffer {
  void writeDateTime(
    LocalDateTime input,
    RecurrenceRuleToStringOptions options,
  ) {
    assert(
      input.year <= iCalMaxYear && input.calendarDate.era == Era.common,
      'The date format used by RRULEs only support four-digit years. '
      'See https://tools.ietf.org/html/rfc5545#section-3.3.4 for more '
      'information.',
    );
    iCalDateTimePattern.appendFormat(input, this);
    if (options.isTimeUtc) {
      write('Z');
    }
  }

  void writeKey(String key) {
    write(';');
    write(key);
    write('=');
  }

  void writeSingle(String key, Object value) {
    if (value == null) {
      return;
    }

    writeKey(key);
    write(value);
  }

  void writeList(String key, Iterable<Object> entries) {
    if (entries.isEmpty) {
      return;
    }

    writeKey(key);
    writeAll(entries, ',');
  }
}

@immutable
class ByWeekDayEntryToStringEncoder extends Converter<ByWeekDayEntry, String> {
  const ByWeekDayEntryToStringEncoder();

  @override
  String convert(ByWeekDayEntry input) =>
      '${input.occurrence ?? ''}${_weekDayToString(input.day)}';
}
