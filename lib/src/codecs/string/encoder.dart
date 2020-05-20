import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import '../../recurrence_rule.dart';
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

  final RecurrenceRuleToStringOptions options;

  @override
  String convert(RecurrenceRule input) {
    final output = StringBuffer('RRULE:')
      ..write('FREQ=${_frequencyToString(input.frequency)}');

    if (input.until != null) {
      output
        ..writeKey('UNTIL')
        ..writeDateTime(input.until, options);
    }

    output
      ..writeSingle('COUNT', input.count)
      ..writeSingle('INTERVAL', input.interval)
      ..writeList('BYSECOND', input.bySeconds)
      ..writeList('BYMINUTE', input.byMinutes)
      ..writeList('BYHOUR', input.byHours)
      ..writeList(
        'BYDAY',
        input.byWeekDays
            .map((e) => '${e.occurrence ?? ''}${_weekDayToString(e.day)}'),
      )
      ..writeList('BYMONTHDAY', input.byMonthDays)
      ..writeList('BYYEARDAY', input.byYearDays)
      ..writeList('BYWEEKNO', input.byWeeks)
      ..writeList('BYMONTH', input.byMonths)
      ..writeList('BYSETPOS', input.bySetPositions)
      ..writeSingle('WKST', _weekDayToString(input.weekStart));

    return output.toString();
  }
}

String _frequencyToString(RecurrenceFrequency input) {
  if (input == null) {
    return null;
  }

  return frequencyStrings.entries.singleWhere((e) => e.value == input).key;
}

String _weekDayToString(DayOfWeek day) {
  if (day == null) {
    return null;
  }

  return weekDayStrings.entries.singleWhere((e) => e.value == day).key;
}

extension _RecurrenceRuleEncoderStringBuffer on StringBuffer {
  void writeDateTime(
    LocalDateTime input,
    RecurrenceRuleToStringOptions options,
  ) {
    assert(
      input.year <= 9999 && input.calendarDate.era == Era.common,
      'The date format used by RRULEs only support four-digit years. '
      'See https://tools.ietf.org/html/rfc5545#section-3.3.4 for more '
      'information.',
    );
    dateTimePattern.appendFormat(input, this);
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
