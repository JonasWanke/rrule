import 'dart:collection';

import 'package:basics/basics.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import 'by_week_day_entry.dart';
import 'codecs/string/decoder.dart';
import 'codecs/string/string.dart';
import 'codecs/text/encoder.dart';
import 'codecs/text/l10n/l10n.dart';
import 'frequency.dart';
import 'iteration/iteration.dart';
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
        assert(
          [Frequency.monthly, Frequency.yearly].contains(frequency) ||
              byWeekDays.noneHasOccurrence,
          'The BYDAY rule part MUST NOT be specified with a numeric value when '
          'the FREQ rule part is not set to MONTHLY or YEARLY.',
        ),
        assert(
          frequency != Frequency.yearly ||
              byWeeks.isEmpty ||
              byWeekDays.noneHasOccurrence,
          '[…] the BYDAY rule part MUST NOT be specified with a numeric value '
          'with the FREQ rule part set to YEARLY when the BYWEEKNO rule part '
          'is specified',
        ),
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
        assert(
          bySetPositions.isEmpty ||
              [
                ...[bySeconds, byMinutes, byHours],
                ...[byWeekDays, byMonthDays, byYearDays],
                ...[byWeeks, byMonths],
              ].any((by) => by.isNotEmpty),
          '[BYSETPOS] MUST only be used in conjunction with another BYxxx rule '
          'part.',
        ),
        bySetPositions = SplayTreeSet.of(bySetPositions);

  factory RecurrenceRule.fromString(
    String input, {
    RecurrenceRuleFromStringOptions options =
        const RecurrenceRuleFromStringOptions(),
  }) {
    assert(options != null);

    return RecurrenceRuleStringCodec(fromStringOptions: options).decode(input);
  }

  /// Corresponds to the `FREQ` property.
  final Frequency frequency;

  /// (Inclusive)
  ///
  /// Corresponds to the `UNTIL` property.
  final LocalDateTime until;

  /// Corresponds to the `COUNT` property.
  final int count;

  /// Corresponds to the `INTERVAL` property.
  final int interval;

  /// Returns [interval] or `1` if that is not set.
  int get actualInterval => interval ?? 1;

  /// Corresponds to the `BYSECOND` property.
  final Set<int> bySeconds;
  bool get hasBySeconds => bySeconds.isNotEmpty;

  /// Corresponds to the `BYMINUTE` property.
  final Set<int> byMinutes;
  bool get hasByMinutes => byMinutes.isNotEmpty;

  /// Corresponds to the `BYHOUR` property.
  final Set<int> byHours;
  bool get hasByHours => byHours.isNotEmpty;

  /// Corresponds to the `BYDAY` property.
  final Set<ByWeekDayEntry> byWeekDays;
  bool get hasByWeekDays => byWeekDays.isNotEmpty;

  /// Corresponds to the `BYMONTHDAY` property.
  final Set<int> byMonthDays;
  bool get hasByMonthDays => byMonthDays.isNotEmpty;

  /// Corresponds to the `BYYEARDAY` property.
  final Set<int> byYearDays;
  bool get hasByYearDays => byYearDays.isNotEmpty;

  /// Corresponds to the `BYWEEKNO` property.
  final Set<int> byWeeks;
  bool get hasByWeeks => byWeeks.isNotEmpty;

  /// Corresponds to the `BYMONTH` property.
  final Set<int> byMonths;
  bool get hasByMonths => byMonths.isNotEmpty;

  /// Corresponds to the `BYSETPOS` property.
  final Set<int> bySetPositions;
  bool get hasBySetPositions => bySetPositions.isNotEmpty;

  /// Corresponds to the `WKST` property.
  ///
  /// See also:
  /// - [actualWeekStart], for the resolved value if this is not set.
  final DayOfWeek weekStart;

  /// Returns [weekStart] or [DayOfWeek.monday] if that is not set.
  DayOfWeek get actualWeekStart => weekStart ?? DayOfWeek.monday;

  /// The [WeekYearRule] starting at [actualWeekStart].
  ///
  /// Otherwise, it's the same as [WeekYearRules.iso].
  WeekYearRule get weekYearRule =>
      WeekYearRules.forMinDaysInFirstWeek(4, actualWeekStart);

  Iterable<LocalDateTime> getInstances({
    @required LocalDateTime start,
  }) {
    assert(start != null);
    return getRecurrenceRuleInstances(this, start: start);
  }

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

  /// Converts this rule to a machine-readable, RFC-5545-compliant string.
  @override
  String toString() => RecurrenceRuleStringCodec().encode(this);

  /// Converts this rule to a human-readable string.
  ///
  /// This may only be called on rules that are fully convertable to text.
  String toText({@required RruleL10n l10n}) {
    assert(l10n != null);
    assert(
      canFullyConvertToText,
      "This recurrence rule can't fully be converted to text. See "
      '[RecurrenceRule.canFullyConvertToText] for more information.',
    );

    return RecurrenceRuleToTextEncoder(l10n).convert(this);
  }

  /// Whether this rule can be converted to a human-readable string.
  ///
  /// - Unsupported attributes: [bySeconds], [byMinutes], [byHours]
  /// - Unsupported frequencies (if any by-parts are specified):
  ///   [Frequency.secondly], [Frequency.hourly], [Frequency.daily]
  bool get canFullyConvertToText {
    if (hasBySeconds || hasByMinutes || hasByHours) {
      return false;
    } else if (frequency <= Frequency.daily) {
      return true;
    } else if (hasBySetPositions ||
        hasBySeconds ||
        hasByMinutes ||
        hasByHours ||
        hasByWeekDays ||
        hasByMonthDays ||
        hasByYearDays ||
        hasByWeeks ||
        hasByMonths) {
      return false;
    }
    return true;
  }
}

/// Validates the `seconds` rule.
bool _debugCheckIsValidSecond(int number) {
  // We currently don't support leap seconds.
  assert(0 <= number && number < TimeConstants.secondsPerMinute);
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
