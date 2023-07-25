import 'dart:convert';

import 'package:meta/meta.dart';

import '../../recurrence_rule.dart';
import '../string/decoder.dart';

@immutable
class RecurrenceRuleFromJsonDecoder
    extends Converter<Map<String, dynamic>, RecurrenceRule> {
  const RecurrenceRuleFromJsonDecoder();

  static const _byWeekDayEntryDecoder = ByWeekDayEntryFromStringDecoder();

  @override
  RecurrenceRule convert(Map<String, dynamic> input) {
    final rawUntil = input['until'] as String?;
    final rawCount = input['count'] as int?;
    if (rawUntil != null && rawCount != null) {
      throw const FormatException('Both `until` and `count` are specified.');
    }
    final rawWeekStart = input['wkst'] as String?;
    return RecurrenceRule(
      frequency: frequencyFromString(input['freq'] as String),
      until: rawUntil == null ? null : _parseDateTime(rawUntil),
      count: rawCount,
      interval: input['interval'] as int?,
      bySeconds: _parseIntList('bysecond', input['bysecond']),
      byMinutes: _parseIntList('byminute', input['byminute']),
      byHours: _parseIntList('byhour', input['byhour']),
      byWeekDays:
          _parseList('byday', input['byday'], _byWeekDayEntryDecoder.convert),
      byMonthDays: _parseIntList('bymonthday', input['bymonthday']),
      byYearDays: _parseIntList('byyearday', input['byyearday']),
      byWeeks: _parseIntList('byweekno', input['byweekno']),
      byMonths: _parseIntList('bymonth', input['bymonth']),
      bySetPositions: _parseIntList('bysetpos', input['bysetpos']),
      weekStart: rawWeekStart == null ? null : weekDayFromString(rawWeekStart),
    );
  }

  DateTime _parseDateTime(String string) {
    const year = r'(?<year>\d{4})';
    const month = r'(?<month>\d{2})';
    const day = r'(?<day>\d{2})';
    const hour = r'(?<hour>\d{2})';
    const minute = r'(?<minute>\d{2})';
    const second = r'(?<second>\d{2})';
    final regEx = RegExp(
      '^$year-$month-${day}T$hour:$minute:${second}Z?\$',
    );

    final match = regEx.firstMatch(string)!;
    return DateTime.utc(
      int.parse(match.namedGroup('year')!),
      int.parse(match.namedGroup('month')!),
      int.parse(match.namedGroup('day')!),
      int.parse(match.namedGroup('hour')!),
      int.parse(match.namedGroup('minute')!),
      int.parse(match.namedGroup('second')!),
    );
  }

  List<int> _parseIntList(String name, dynamic json) =>
      _parseList<int, int>(name, json, (it) => it);

  List<R> _parseList<T, R>(String name, dynamic json, R Function(T) parse) {
    if (json == null) {
      return const [];
    } else if (json is T) {
      return [parse(json)];
    } else if (json is List<T>) {
      return json.map(parse).toList();
    } else if (json is List) {
      try {
        return json.cast<T>().map(parse).toList();
      } catch (e, st) {
        throw FormatException('Invalid JSON in `$name`: $e\n\n$st');
      }
    } else {
      throw FormatException('Invalid JSON in `$name`.');
    }
  }
}
