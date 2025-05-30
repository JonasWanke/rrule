import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import 'by_week_day_entry.dart';
import 'cache.dart';
import 'codecs/json/decoder.dart';
import 'codecs/json/encoder.dart';
import 'codecs/string/decoder.dart';
import 'codecs/string/encoder.dart';
import 'codecs/text/encoder.dart';
import 'codecs/text/l10n/l10n.dart';
import 'frequency.dart';
import 'iteration/iteration.dart';
import 'utils.dart';

/// Specified in [RFC 5545 Section 3.8.5.3: Recurrence Rule](https://tools.ietf.org/html/rfc5545#section-3.8.5.3).
@immutable
class RecurrenceRule {
  RecurrenceRule({
    required this.frequency,
    this.until,
    this.count,
    this.interval,
    this.bySeconds = const [],
    this.byMinutes = const [],
    this.byHours = const [],
    this.byWeekDays = const [],
    this.byMonthDays = const [],
    this.byYearDays = const [],
    this.byWeeks = const [],
    this.byMonths = const [],
    this.bySetPositions = const [],
    this.weekStart,
    this.shouldCacheResults = false,
  })  : assert(count == null || count >= 1),
        assert(until.isValidRruleDateTime),
        assert(
          until == null || count == null,
          'The UNTIL or COUNT rule parts are OPTIONAL, but they MUST NOT occur '
          'in the same RecurrenceRule.',
        ),
        assert(interval == null || interval >= 1),
        assert(bySeconds.every(_debugCheckIsValidSecond)),
        assert(byMinutes.every(_debugCheckIsValidMinute)),
        assert(byHours.every(_debugCheckIsValidHour)),
        assert(
          [Frequency.monthly, Frequency.yearly].contains(frequency) ||
              byWeekDays.noneHasOccurrence,
          '"The BYDAY rule part MUST NOT be specified with a numeric value '
          'when the FREQ rule part is not set to MONTHLY or YEARLY." '
          '— https://tools.ietf.org/html/rfc5545#section-3.3.10',
        ),
        assert(
          frequency != Frequency.yearly ||
              byWeeks.isEmpty ||
              byWeekDays.noneHasOccurrence,
          '[…] the BYDAY rule part MUST NOT be specified with a numeric value '
          'with the FREQ rule part set to YEARLY when the BYWEEKNO rule part '
          'is specified.',
        ),
        assert(byMonthDays.every(_debugCheckIsValidMonthDayEntry)),
        assert(
          !(frequency == Frequency.weekly && byMonthDays.isNotEmpty),
          'The BYMONTHDAY rule part MUST NOT be specified when the FREQ rule '
          'part is set to WEEKLY.',
        ),
        assert(byYearDays.every(_debugCheckIsValidDayOfYear)),
        assert(
          !([Frequency.daily, Frequency.weekly, Frequency.monthly]
                  .contains(frequency) &&
              byYearDays.isNotEmpty),
          'The BYYEARDAY rule part MUST NOT be specified when the FREQ rule '
          'part is set to DAILY, WEEKLY, or MONTHLY.',
        ),
        assert(byWeeks.every(debugCheckIsValidWeekNumber)),
        assert(
          !(frequency != Frequency.yearly && byWeeks.isNotEmpty),
          '[The BYWEEKNO] rule part MUST NOT be used when the FREQ rule part '
          'is set to anything other than YEARLY.',
        ),
        assert(byMonths.every(_debugCheckIsValidMonthEntry)),
        assert(bySetPositions.every(_debugCheckIsValidDayOfYear)),
        assert(
          bySetPositions.isEmpty ||
              [
                // This comment is to keep the formatting of the lines below.
                bySeconds, byMinutes, byHours,
                byWeekDays, byMonthDays, byYearDays,
                byWeeks, byMonths,
              ].any((by) => by.isNotEmpty),
          '[BYSETPOS] MUST only be used in conjunction with another BYxxx rule '
          'part.',
        ),
        assert(weekStart == null || weekStart == DateTime.monday);

  factory RecurrenceRule.fromString(
    String input, {
    RecurrenceRuleFromStringOptions options =
        const RecurrenceRuleFromStringOptions(),
  }) =>
      RecurrenceRuleFromStringDecoder(options: options).convert(input);

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) =>
      const RecurrenceRuleFromJsonDecoder().convert(json);

  /// Corresponds to the `FREQ` property.
  final Frequency frequency;

  /// (Inclusive)
  ///
  /// Corresponds to the `UNTIL` property.
  final DateTime? until;

  /// Corresponds to the `COUNT` property.
  final int? count;

  /// Corresponds to the `INTERVAL` property.
  final int? interval;

  /// Returns [interval] or `1` if that is not set.
  int get actualInterval => interval ?? 1;

  /// Corresponds to the `BYSECOND` property.
  final List<int> bySeconds;
  bool get hasBySeconds => bySeconds.isNotEmpty;

  /// Corresponds to the `BYMINUTE` property.
  final List<int> byMinutes;
  bool get hasByMinutes => byMinutes.isNotEmpty;

  /// Corresponds to the `BYHOUR` property.
  final List<int> byHours;
  bool get hasByHours => byHours.isNotEmpty;

  /// Corresponds to the `BYDAY` property.
  final List<ByWeekDayEntry> byWeekDays;
  bool get hasByWeekDays => byWeekDays.isNotEmpty;

  /// Corresponds to the `BYMONTHDAY` property.
  final List<int> byMonthDays;
  bool get hasByMonthDays => byMonthDays.isNotEmpty;

  /// Corresponds to the `BYYEARDAY` property.
  final List<int> byYearDays;
  bool get hasByYearDays => byYearDays.isNotEmpty;

  /// Corresponds to the `BYWEEKNO` property.
  final List<int> byWeeks;
  bool get hasByWeeks => byWeeks.isNotEmpty;

  /// Corresponds to the `BYMONTH` property.
  final List<int> byMonths;
  bool get hasByMonths => byMonths.isNotEmpty;

  /// Corresponds to the `BYSETPOS` property.
  final List<int> bySetPositions;
  bool get hasBySetPositions => bySetPositions.isNotEmpty;

  /// Corresponds to the `WKST` property.
  ///
  /// Only [DateTime.monday] is currently supported!
  ///
  /// See also:
  /// - [actualWeekStart], for the resolved value if this is not set.
  final int? weekStart;

  /// Returns [weekStart] or [DateTime.monday] if that is not set.
  int get actualWeekStart => weekStart ?? DateTime.monday;

  final bool shouldCacheResults;

  final Cache _cache = Cache();

  @visibleForTesting
  Cache get cache => _cache;

  Iterable<DateTime> getInstances({
    required DateTime start,
    DateTime? after,
    bool includeAfter = false,
    DateTime? before,
    bool includeBefore = false,
  }) {
    assert(start.isValidRruleDateTime);
    assert(after.isValidRruleDateTime);
    assert(before.isValidRruleDateTime);

    return getRecurrenceRuleInstances(
      this,
      start: start,
      after: after,
      includeAfter: includeAfter,
      before: before,
      includeBefore: includeBefore,
    );
  }

  List<DateTime> getAllInstances({
    required DateTime start,
    DateTime? after,
    bool includeAfter = false,
    DateTime? before,
    bool includeBefore = false,
  }) {
    assert(start.isValidRruleDateTime);
    assert(after.isValidRruleDateTime);
    assert(before.isValidRruleDateTime);

    final key = CacheKey(
      start: start,
      after: after,
      includeAfter: includeAfter,
      before: before,
      includeBefore: includeBefore,
    );

    final fromCache = _cache.get(key);
    if (fromCache != null) return fromCache;

    final results = getInstances(
      start: start,
      after: after,
      includeAfter: includeAfter,
      before: before,
      includeBefore: includeBefore,
    ).toList(growable: false);

    if (shouldCacheResults) {
      _cache.add(key, results);
    }

    return results;
  }

  @override
  int get hashCode {
    return Object.hash(
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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    const equality = DeepCollectionEquality();
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
        equality.equals(other.bySetPositions, bySetPositions);
  }

  RecurrenceRule copyWith({
    Frequency? frequency,
    DateTime? until,
    bool clearUntil = false,
    int? count,
    bool clearCount = false,
    int? interval,
    bool clearInterval = false,
    List<int>? bySeconds,
    List<int>? byMinutes,
    List<int>? byHours,
    List<ByWeekDayEntry>? byWeekDays,
    List<int>? byMonthDays,
    List<int>? byYearDays,
    List<int>? byWeeks,
    List<int>? byMonths,
    List<int>? bySetPositions,
  }) {
    assert(until.isValidRruleDateTime);
    assert(
      !(clearUntil && until != null),
      'A new value for `until` must not be specified when `clearUntil` is set.',
    );
    assert(
      !(clearCount && count != null),
      'A new value for `count` must not be specified when `clearCount` is set.',
    );
    assert(
      !(clearInterval && interval != null),
      'A new value for `interval` must not be specified when `clearInterval` '
      'is set.',
    );

    return RecurrenceRule(
      frequency: frequency ?? this.frequency,
      until: clearUntil ? null : until ?? this.until,
      count: clearCount ? null : count ?? this.count,
      interval: clearInterval ? null : interval ?? this.interval,
      bySeconds: bySeconds ?? this.bySeconds,
      byMinutes: byMinutes ?? this.byMinutes,
      byHours: byHours ?? this.byHours,
      byWeekDays: byWeekDays ?? this.byWeekDays,
      byMonthDays: byMonthDays ?? this.byMonthDays,
      byYearDays: byYearDays ?? this.byYearDays,
      byWeeks: byWeeks ?? this.byWeeks,
      byMonths: byMonths ?? this.byMonths,
      bySetPositions: bySetPositions ?? this.bySetPositions,
    );
  }

  /// Converts this rule to a machine-readable, RFC-5545-compliant string.
  @override
  String toString({
    RecurrenceRuleToStringOptions options =
        const RecurrenceRuleToStringOptions(),
  }) =>
      RecurrenceRuleToStringEncoder(options: options).convert(this);

  /// Converts this rule to a human-readable string.
  ///
  /// This may only be called on rules that are fully convertable to text.
  String toText({required RruleL10n l10n, DateFormat? untilDateFormat}) {
    assert(
      canFullyConvertToText,
      "This recurrence rule can't fully be converted to text. See "
      '[RecurrenceRule.canFullyConvertToText] for more information.',
    );

    return RecurrenceRuleToTextEncoder(l10n, untilDateFormat: untilDateFormat).convert(this);
  }

  /// Converts this rule to a machine-readable, RFC-7265-compliant string.
  Map<String, dynamic> toJson({
    RecurrenceRuleToJsonOptions options = const RecurrenceRuleToJsonOptions(),
  }) =>
      RecurrenceRuleToJsonEncoder(options: options).convert(this);

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
///
/// We currently don't support leap seconds.
bool _debugCheckIsValidSecond(int number) {
  assert(0 <= number && number < Duration.secondsPerMinute);
  return true;
}

/// Validates the `minutes` rule.
bool _debugCheckIsValidMinute(int number) {
  assert(0 <= number && number < Duration.minutesPerHour);
  return true;
}

/// Validates the `hour` rule.
bool _debugCheckIsValidHour(int number) {
  assert(0 <= number && number < Duration.hoursPerDay);
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
