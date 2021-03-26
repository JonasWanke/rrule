import 'dart:convert';

import 'package:meta/meta.dart';

import '../../by_week_day_entry.dart';
import '../../frequency.dart';
import '../../recurrence_rule.dart';
import '../../utils.dart';
import 'ical.dart';
import 'string.dart';

@immutable
class RecurrenceRuleFromStringOptions {
  /// Strict rules according to the iCalendar standard.
  const RecurrenceRuleFromStringOptions({
    this.duplicatePartBehavior = RecurrenceRuleDuplicatePartBehavior.exception,
  });

  const RecurrenceRuleFromStringOptions.lenient({
    RecurrenceRuleDuplicatePartBehavior duplicatePartBehavior =
        RecurrenceRuleDuplicatePartBehavior.mergePreferLast,
  }) : this(duplicatePartBehavior: duplicatePartBehavior);

  final RecurrenceRuleDuplicatePartBehavior duplicatePartBehavior;
}

enum RecurrenceRuleDuplicatePartBehavior {
  exception,
  takeFirst,
  takeLast,

  /// - list parts (like `BYHOUR`): all values are concatenated
  /// - single parts: last value overwrites others
  mergePreferLast,
}

@immutable
class RecurrenceRuleFromStringDecoder
    extends Converter<String, RecurrenceRule> {
  const RecurrenceRuleFromStringDecoder({
    this.options = const RecurrenceRuleFromStringOptions(),
  });

  static const _byWeekDayEntryDecoder = ByWeekDayEntryFromStringDecoder();

  final RecurrenceRuleFromStringOptions options;

  @override
  RecurrenceRule convert(String input) {
    final property = ICalPropertyStringCodec().decode(input);
    if (property.name.toUpperCase() != 'RRULE') {
      throw FormatException(
          'Content line is not an RRULE but a ${property.name}!');
    }

    Frequency? frequency;
    _UntilOrCount? untilOrCount;
    int? interval;
    Set<int>? bySeconds;
    Set<int>? byMinutes;
    Set<int>? byHours;
    Set<ByWeekDayEntry>? byWeekDays;
    Set<int>? byMonthDays;
    Set<int>? byYearDays;
    Set<int>? byWeeks;
    Set<int>? byMonths;
    Set<int>? bySetPositions;
    int? weekStart;
    for (final part in property.value.split(';')) {
      if (part.isEmpty) {
        // This means the value is empty.
        continue;
      }

      final nameEndIndex = part.indexOf('=');
      final name = part.substring(0, nameEndIndex).toUpperCase();
      final value = part.substring(nameEndIndex + 1);

      switch (name) {
        case recurRulePartFreq:
          frequency = _parseSimplePart(
            name,
            value,
            oldValue: frequency,
            parse: () => _frequencyFromString(value),
          );
          break;
        case recurRulePartUntil:
          untilOrCount = _parseSimplePart(
            name,
            value,
            oldValue: untilOrCount,
            parse: () {
              // Remove the optional "Z" suffix indicating a time in UTC as we
              // ignore time zones.
              final normalizedValue = value.endsWith('Z')
                  ? value.substring(0, value.length - 1)
                  : value;
              final match = normalizedValue.length == 8
                  ? DateTime.tryParse(normalizedValue)
                  : normalizedValue.length == 15
                      ? DateTime.tryParse(normalizedValue)
                      : null;
              if (match == null) {
                throw FormatException('Cannot parse date or date-time');
              }
              return _UntilOrCount(until: match.copyWith(isUtc: true));
            },
          );
          break;
        case recurRulePartCount:
          untilOrCount = _parseSimplePart(
            name,
            value,
            oldValue: untilOrCount,
            parse: () => _UntilOrCount(count: int.parse(value)),
          );
          break;
        case recurRulePartInterval:
          interval = _parseSimplePart(
            name,
            value,
            oldValue: interval,
            parse: () => int.parse(value),
          );
          break;
        case recurRulePartBySecond:
          bySeconds = _parseIntSetPart(
            name,
            value,
            oldValue: bySeconds,
            min: 0,
            // We currently don't support leap seconds.
            max: Duration.secondsPerMinute - 1,
            allowNegative: false,
          );
          break;
        case recurRulePartByMinute:
          byMinutes = _parseIntSetPart(
            name,
            value,
            oldValue: byMinutes,
            min: 0,
            max: Duration.minutesPerHour - 1,
            allowNegative: false,
          );
          break;
        case recurRulePartByHour:
          byHours = _parseIntSetPart(
            name,
            value,
            oldValue: byHours,
            min: 0,
            max: Duration.hoursPerDay - 1,
            allowNegative: false,
          );
          break;
        case recurRulePartByDay:
          byWeekDays = _parseSetPart(
            name,
            value,
            oldValue: byWeekDays,
            parse: _byWeekDayEntryDecoder.convert,
          );
          break;
        case recurRulePartByMonthDay:
          byMonthDays = _parseIntSetPart(
            name,
            value,
            oldValue: byMonthDays,
            min: 1,
            max: 31,
          );
          break;
        case recurRulePartByYearDay:
          byYearDays = _parseIntSetPart(
            name,
            value,
            oldValue: byYearDays,
            min: 1,
            max: 366,
          );
          break;
        case recurRulePartByWeekNo:
          byWeeks = _parseIntSetPart(
            name,
            value,
            oldValue: byWeeks,
            min: 1,
            max: 53,
          );
          break;
        case recurRulePartByMonth:
          byMonths = _parseIntSetPart(
            name,
            value,
            oldValue: byMonths,
            min: 1,
            max: 12,
            allowNegative: false,
          );
          break;
        case recurRulePartBySetPos:
          bySetPositions = _parseIntSetPart(
            name,
            value,
            oldValue: bySetPositions,
            min: 1,
            max: 366,
          );
          break;
        case recurRulePartWkSt:
          weekStart = _parseSimplePart(
            name,
            value,
            oldValue: weekStart,
            parse: () => _weekDayFromString(value),
          );
          if (weekStart != null && weekStart != DateTime.monday) {
            throw FormatException(
              'Unsupported value for RRULE part $name: "$value" (Only MO is supported.)',
            );
          }
          break;
      }
    }

    if (frequency == null) {
      throw FormatException('Frequency was not provided in RRULE');
    }

    return RecurrenceRule(
      frequency: frequency,
      until: untilOrCount?.until,
      count: untilOrCount?.count,
      interval: interval,
      bySeconds: bySeconds ?? {},
      byMinutes: byMinutes ?? {},
      byHours: byHours ?? {},
      byWeekDays: byWeekDays ?? {},
      byMonthDays: byMonthDays ?? {},
      byYearDays: byYearDays ?? {},
      byWeeks: byWeeks ?? {},
      byMonths: byMonths ?? {},
      bySetPositions: bySetPositions ?? {},
    );
  }

  T _parseSimplePart<T>(
    String name,
    String value, {
    required T oldValue,
    required T Function() parse,
  }) {
    _checkDuplicatePart(name, oldValue);

    T newValue;
    try {
      newValue = parse();
    } on FormatException catch (e) {
      throw FormatException(
        'Invalid value for RRULE part $name: "$value" (Exception: $e)',
      );
    }

    if (oldValue != null) {
      switch (options.duplicatePartBehavior) {
        case RecurrenceRuleDuplicatePartBehavior.exception:
          // Already handled above.
          assert(false);
          break;
        case RecurrenceRuleDuplicatePartBehavior.takeFirst:
          newValue = oldValue;
          break;
        case RecurrenceRuleDuplicatePartBehavior.takeLast:
          // We already prefer the new value.
          break;
        case RecurrenceRuleDuplicatePartBehavior.mergePreferLast:
          // handled in _parseSetPart.
          break;
      }
    }
    return newValue;
  }

  Set<int> _parseIntSetPart(
    String name,
    String value, {
    required Set<int>? oldValue,
    required int min,
    required int max,
    bool allowNegative = true,
  }) {
    return _parseSetPart(
      name,
      value,
      oldValue: oldValue,
      parse: (e) {
        final parsed = int.parse(e);
        final valueToCheck = allowNegative ? parsed.abs() : parsed;
        if (min > valueToCheck || valueToCheck > max) {
          throw FormatException(
              'Value must be in range ${allowNegative ? '±' : ''}$min–$max');
        }
        return parsed;
      },
    );
  }

  Set<T> _parseSetPart<T>(
    String name,
    String value, {
    required Set<T>? oldValue,
    required T Function(String value) parse,
  }) {
    _checkDuplicatePart(name, oldValue);

    var newValue = <T>{};
    try {
      for (final entry in value.split(',')) {
        newValue.add(parse(entry));
      }
    } on FormatException catch (e) {
      throw FormatException(
          'Invalid entry in RRULE part $name: "$value" (Exception: $e)');
    }

    if (oldValue != null) {
      switch (options.duplicatePartBehavior) {
        case RecurrenceRuleDuplicatePartBehavior.exception:
          // Already handled above.
          assert(false);
          break;
        case RecurrenceRuleDuplicatePartBehavior.takeFirst:
          newValue = oldValue;
          break;
        case RecurrenceRuleDuplicatePartBehavior.takeLast:
          // We already prefer the new value.
          break;
        case RecurrenceRuleDuplicatePartBehavior.mergePreferLast:
          newValue.addAll(oldValue);
          break;
      }
    }
    return newValue;
  }

  void _checkDuplicatePart(String name, Object? oldValue) {
    if (oldValue != null &&
        options.duplicatePartBehavior ==
            RecurrenceRuleDuplicatePartBehavior.exception) {
      if (name == recurRulePartUntil || name == recurRulePartCount) {
        throw FormatException('Duplicate part while parsing RRULE: $name '
            '(Only one of `UNTIL` and `COUNT` may be set.)');
      }

      throw FormatException('Duplicate part while parsing RRULE: $name');
    }
  }
}

Frequency? _frequencyFromString(String input) => recurFreqValues[input];
int? _weekDayFromString(String day) => recurWeekDayValues[day];

/// Helper class to reuse the logic of
/// [RecurrenceRuleFromStringDecoder._parseSimplePart] for
/// [RecurrenceRule.until] and [RecurrenceRule.count] where only one of them may
/// be set.
@immutable
class _UntilOrCount {
  _UntilOrCount({this.until, this.count})
      : assert(until.isValidRruleDateTime),
        assert((until == null) != (count == null));

  final DateTime? until;
  final int? count;
}

@immutable
class ByWeekDayEntryFromStringDecoder
    extends Converter<String, ByWeekDayEntry> {
  const ByWeekDayEntryFromStringDecoder();

  @override
  ByWeekDayEntry convert(String input) {
    final match =
        RegExp('(?:(\\+|-)?([0-9]{1,2}))?([A-Za-z]{2})\$').matchAsPrefix(input);
    if (match == null) {
      throw FormatException('Cannot parse $input');
    }

    int? occurrence;
    final numberMatch = match.group(2);
    if (numberMatch != null) {
      occurrence = int.parse(numberMatch);
      if (1 > occurrence || occurrence > 53) {
        throw FormatException('Value must be in range ±1–53');
      }

      if (match.group(1) == '-') occurrence = -occurrence;
    }

    final dayMatch = match.group(3);
    final weekDay = _weekDayFromString(dayMatch!);
    if (weekDay == null) {
      throw FormatException(
        'Invalid day of week: "$dayMatch"; allowed values are '
        '${recurWeekDayValues.keys.join(',')}.',
      );
    }

    return ByWeekDayEntry(weekDay, occurrence);
  }
}
