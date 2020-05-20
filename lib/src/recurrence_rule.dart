import 'package:basics/basics.dart';
import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

enum RecurrenceFrequency {
  secondly,
  minutely,
  hourly,
  daily,
  weekly,
  monthly,
  yearly,
}

/// Specified in [RFC 5545 Section 3.8.5.3: Recurrence Rule](https://tools.ietf.org/html/rfc5545#section-3.8.5.3).
@immutable
class RecurrenceRule {
  RecurrenceRule({
    @required this.frequency,
    this.until,
    this.count,
    this.interval,
    this.bySeconds = const {},
    this.byMinutes = const {},
    this.byHours = const {},
    this.byWeekDays = const {},
    this.byMonthDays = const {},
    this.byYearDays = const {},
    this.byWeeks = const {},
    this.byMonths = const {},
    this.bySetPositions = const {},
  })  : assert(frequency != null),
        assert(count == null || count >= 1),
        assert(until == null || count == null),
        assert(interval == null || interval >= 1),
        assert(bySeconds != null),
        assert(bySeconds.all(_debugCheckIsValidSecond)),
        assert(byMinutes != null),
        assert(byMinutes.all(_debugCheckIsValidMinute)),
        assert(byHours != null),
        assert(byHours.all(_debugCheckIsValidHour)),
        assert(byWeekDays != null),
        assert(byMonthDays != null),
        assert(byMonthDays.all(_debugCheckIsValidMonthDayEntry)),
        assert(byYearDays != null),
        assert(byYearDays.all(_debugCheckIsValidDayOfYear)),
        assert(byWeeks != null),
        assert(byWeeks.all(_debugCheckIsValidWeekNumber)),
        assert(byMonths != null),
        assert(byMonths.all(_debugCheckIsValidMonthEntry)),
        assert(bySetPositions != null),
        assert(bySetPositions.all(_debugCheckIsValidDayOfYear));

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
  final Set<DayOfWeek> byWeekDays;

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
}

/// Corresponds to a single entry in the `BYDAY` list of a [RecurrenceRule].
@immutable
class ByWeekDayEntry {
  ByWeekDayEntry(this.day, [this.occurrence])
      : assert(day != null),
        assert(occurrence == null || _debugCheckIsValidWeekNumber(occurrence));

  final DayOfWeek day;

  final int occurrence;
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
bool _debugCheckIsValidWeekNumber(int number) {
  assert(1 <= number.abs() && number.abs() <= 53);
  return true;
}

/// Validates the `yeardaynum` rule.
bool _debugCheckIsValidDayOfYear(int number) {
  assert(1 <= number.abs() && number.abs() <= 366);
  return true;
}
