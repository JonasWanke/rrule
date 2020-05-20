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
class RecurrenceRuleEncoder extends Converter<RecurrenceRule, String> {
  const RecurrenceRuleEncoder({
    this.options = const RecurrenceRuleToStringOptions(),
  }) : assert(options != null);

  final RecurrenceRuleToStringOptions options;

  @override
  String convert(RecurrenceRule input) {
    final output = StringBuffer('RRULE:')
      ..write('FREQ=${_convertFrequency(input.frequency)}');

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
            .map((e) => '${e.occurrence ?? ''}${weekDayToString(e.day)}'),
      )
      ..writeList('BYMONTHDAY', input.byMonthDays)
      ..writeList('BYYEARDAY', input.byYearDays)
      ..writeList('BYWEEKNO', input.byWeeks)
      ..writeList('BYMONTH', input.byMonths)
      ..writeList('BYSETPOS', input.bySetPositions)
      ..writeSingle('WKST', weekDayToString(input.weekStart));

    return output.toString();
  }

  String _convertFrequency(RecurrenceFrequency input) {
    switch (input) {
      case RecurrenceFrequency.secondly:
        return 'SECONDLY';
      case RecurrenceFrequency.minutely:
        return 'MINUTELY';
      case RecurrenceFrequency.hourly:
        return 'HOURLY';
      case RecurrenceFrequency.daily:
        return 'DAILY';
      case RecurrenceFrequency.weekly:
        return 'WEEKLY';
      case RecurrenceFrequency.monthly:
        return 'MONTHLY';
      case RecurrenceFrequency.yearly:
        return 'YEARLY';
    }
    assert(false);
    return null;
  }
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
