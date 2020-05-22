import 'dart:collection';

import 'package:basics/basics.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import 'by_week_day_entry.dart';
import 'codecs/string/decoder.dart';
import 'codecs/string/string.dart';
import 'frequency.dart';
import 'recurrence_rule_iteration.dart';
import 'utils.dart';

/// Specified in [RFC 5545 Section 3.8.5.3: Recurrence Rule](https://tools.ietf.org/html/rfc5545#section-3.8.5.3).
@immutable
class RecurrenceRule {
  RecurrenceRule({
    @required this.frequency,
    this.until,
    this.count,
    this.interval,
    Set<int> bySeconds = const {},
    Set<int> byMinutes = const {},
    Set<int> byHours = const {},
    Set<ByWeekDayEntry> byWeekDays = const {},
    Set<int> byMonthDays = const {},
    Set<int> byYearDays = const {},
    Set<int> byWeeks = const {},
    Set<int> byMonths = const {},
    Set<int> bySetPositions = const {},
    this.weekStart,
  })  : assert(frequency != null),
        assert(count == null || count >= 1),
        assert(until == null || count == null),
        assert(interval == null || interval >= 1),
        assert(bySeconds != null),
        assert(bySeconds.all(_debugCheckIsValidSecond)),
        bySeconds = SplayTreeSet.of(bySeconds),
        assert(byMinutes != null),
        assert(byMinutes.all(_debugCheckIsValidMinute)),
        byMinutes = SplayTreeSet.of(byMinutes),
        assert(byHours != null),
        assert(byHours.all(_debugCheckIsValidHour)),
        byHours = SplayTreeSet.of(byHours),
        assert(byWeekDays != null),
        byWeekDays = SplayTreeSet.of(byWeekDays),
        assert(byMonthDays != null),
        assert(byMonthDays.all(_debugCheckIsValidMonthDayEntry)),
        byMonthDays = SplayTreeSet.of(byMonthDays),
        assert(byYearDays != null),
        assert(byYearDays.all(_debugCheckIsValidDayOfYear)),
        byYearDays = SplayTreeSet.of(byYearDays),
        assert(byWeeks != null),
        assert(byWeeks.all(debugCheckIsValidWeekNumber)),
        byWeeks = SplayTreeSet.of(byWeeks),
        assert(byMonths != null),
        assert(byMonths.all(_debugCheckIsValidMonthEntry)),
        byMonths = SplayTreeSet.of(byMonths),
        assert(bySetPositions != null),
        assert(bySetPositions.all(_debugCheckIsValidDayOfYear)),
        bySetPositions = SplayTreeSet.of(bySetPositions);

  factory RecurrenceRule.parseString(
    String input, {
    RecurrenceRuleFromStringOptions options =
        const RecurrenceRuleFromStringOptions(),
  }) {
    assert(options != null);

    return RecurrenceRuleStringCodec(fromStringOptions: options).decode(input);
  }

  /// Corresponds to the `FREQ` property.
  final RecurrenceFrequency frequency;

  /// (Inclusive)
  ///
  /// Corresponds to the `UNTIL` property.
  final LocalDateTime until;

  /// Corresponds to the `COUNT` property.
  final int count;

  /// Corresponds to the `INTERVAL` property.
  final int interval;

  /// Corresponds to the `BYSECOND` property.
  final Set<int> bySeconds;

  /// Corresponds to the `BYMINUTE` property.
  final Set<int> byMinutes;

  /// Corresponds to the `BYHOUR` property.
  final Set<int> byHours;

  /// Corresponds to the `BYDAY` property.
  final Set<ByWeekDayEntry> byWeekDays;

  /// Corresponds to the `BYMONTHDAY` property.
  final Set<int> byMonthDays;

  /// Corresponds to the `BYYEARDAY` property.
  final Set<int> byYearDays;

  /// Corresponds to the `BYWEEKNO` property.
  final Set<int> byWeeks;

  /// Corresponds to the `BYMONTH` property.
  final Set<int> byMonths;

  /// Corresponds to the `BYSETPOS` property.
  final Set<int> bySetPositions;

  /// Corresponds to the `WKST` property.
  final DayOfWeek weekStart;

  @override
  int get hashCode {
    return hashList([
      frequency,
      until,
      count,
      interval,
      bySeconds,
      byMinutes,
      byHours,
      byWeekDays,
      byMonthDays,
      byYearDays,
      byWeeks,
      byMonths,
      bySetPositions,
      weekStart,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final equality = DeepCollectionEquality();
    return other is RecurrenceRule &&
        other.frequency == frequency &&
        other.until == until &&
        other.count == count &&
        other.interval == interval &&
        equality.equals(other.bySeconds, bySeconds) &&
        equality.equals(other.byMinutes, byMinutes) &&
        equality.equals(other.byHours, byHours) &&
        equality.equals(other.byWeekDays, byWeekDays) &&
        equality.equals(other.byMonthDays, byMonthDays) &&
        equality.equals(other.byYearDays, byYearDays) &&
        equality.equals(other.byWeeks, byWeeks) &&
        equality.equals(other.byMonths, byMonths) &&
        equality.equals(other.bySetPositions, bySetPositions) &&
        other.weekStart == weekStart;
  }

  @override
  String toString() => RecurrenceRuleStringCodec().encode(this);
}

/// Validates the `seconds` rule.
bool _debugCheckIsValidSecond(int number) {
  // "<= 60" is intentional due to leap seconds.
  assert(0 <= number && number <= TimeConstants.secondsPerMinute);
  return true;
}

/// Validates the `minutes` rule.
bool _debugCheckIsValidMinute(int number) {
  assert(0 <= number && number < TimeConstants.minutesPerHour);
  return true;
}

/// Validates the `hour` rule.
bool _debugCheckIsValidHour(int number) {
  assert(0 <= number && number < TimeConstants.hoursPerDay);
  return true;
}

/// Validates the `monthdaynum` rule.
bool _debugCheckIsValidMonthDayEntry(int number) {
  assert(1 <= number.abs() && number.abs() <= 31);
  return true;
}

/// Validates the `monthnum` rule.
bool _debugCheckIsValidMonthEntry(int number) {
  assert(1 <= number && number <= 12);
  return true;
}

/// Validates the `weeknum` rule and the first part of the `weekdaynum` rule.
bool debugCheckIsValidWeekNumber(int number) {
  assert(1 <= number.abs() && number.abs() <= 53);
  return true;
}

/// Validates the `yeardaynum` rule.
bool _debugCheckIsValidDayOfYear(int number) {
  assert(1 <= number.abs() && number.abs() <= 366);
  return true;
}
