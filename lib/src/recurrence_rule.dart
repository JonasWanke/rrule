import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'by_week_day_entry.dart';
import 'cache.dart';
import 'codecs/string/decoder.dart';
import 'codecs/string/encoder.dart';
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
    required this.frequency,
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
        bySeconds = SplayTreeSet.of(bySeconds),
        assert(byMinutes.every(_debugCheckIsValidMinute)),
        byMinutes = SplayTreeSet.of(byMinutes),
        assert(byHours.every(_debugCheckIsValidHour)),
        byHours = SplayTreeSet.of(byHours),
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
        byWeekDays = SplayTreeSet.of(byWeekDays),
        assert(byMonthDays.every(_debugCheckIsValidMonthDayEntry)),
        assert(
          !(frequency == Frequency.weekly && byMonthDays.isNotEmpty),
          'The BYMONTHDAY rule part MUST NOT be specified when the FREQ rule '
          'part is set to WEEKLY.',
        ),
        byMonthDays = SplayTreeSet.of(byMonthDays),
        assert(byYearDays.every(_debugCheckIsValidDayOfYear)),
        assert(
          !([Frequency.daily, Frequency.weekly, Frequency.monthly]
                  .contains(frequency) &&
              byYearDays.isNotEmpty),
          'The BYYEARDAY rule part MUST NOT be specified when the FREQ rule '
          'part is set to DAILY, WEEKLY, or MONTHLY.',
        ),
        byYearDays = SplayTreeSet.of(byYearDays),
        assert(byWeeks.every(debugCheckIsValidWeekNumber)),
        assert(
          !(frequency != Frequency.yearly && byWeeks.isNotEmpty),
          '[The BYWEEKNO] rule part MUST NOT be used when the FREQ rule part '
          'is set to anything other than YEARLY.',
        ),
        byWeeks = SplayTreeSet.of(byWeeks),
        assert(byMonths.every(_debugCheckIsValidMonthEntry)),
        byMonths = SplayTreeSet.of(byMonths),
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
        bySetPositions = SplayTreeSet.of(bySetPositions),
        assert(weekStart == null || weekStart == DateTime.monday);

  factory RecurrenceRule.fromString(
    String input, {
    RecurrenceRuleFromStringOptions options =
        const RecurrenceRuleFromStringOptions(),
  }) {
    return RecurrenceRuleStringCodec(fromStringOptions: options).decode(input);
  }

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
    ]);
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
    Set<int>? bySeconds,
    Set<int>? byMinutes,
    Set<int>? byHours,
    Set<ByWeekDayEntry>? byWeekDays,
    Set<int>? byMonthDays,
    Set<int>? byYearDays,
    Set<int>? byWeeks,
    Set<int>? byMonths,
    Set<int>? bySetPositions,
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
  String toText({required RruleL10n l10n}) {
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

  factory RecurrenceRule.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('The json object is null');
    }
    Set<int> _listToSet(List<dynamic>? list) {
      if (list == null) {
        return {};
      } else {
        final finalList = list.cast<int>();
        return finalList.toSet();
      }
    }

    Set<ByWeekDayEntry> _listToWeekdayEntrySet(List<dynamic>? list) {
      if (list == null) {
        return {};
      } else {
        final finalList = list.cast<Map<String, int>>();
        final entries = <ByWeekDayEntry>{};
        for (final element in finalList) {
          entries.add(ByWeekDayEntry.fromJson(element));
        }
        return entries;
      }
    }

    final _until = json['until'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['until'] as int,
            isUtc: true);
    return RecurrenceRule(
      frequency: intToFrequency(json['frequency'] as int?) ?? Frequency.yearly,
      until: _until,
      count: json['count'] as int?,
      interval: json['interval'] as int?,
      bySeconds: _listToSet(json['bySeconds'] as List<dynamic>?),
      byMinutes: _listToSet(json['byMinutes'] as List<dynamic>?),
      byHours: _listToSet(json['byHours'] as List<dynamic>?),
      byWeekDays: _listToWeekdayEntrySet(json['byWeekDays'] as List<dynamic>?),
      byMonthDays: _listToSet(json['byMonthDays'] as List<dynamic>?),
      byYearDays: _listToSet(json['byYearDays'] as List<dynamic>?),
      byWeeks: _listToSet(json['byWeeks'] as List<dynamic>?),
      byMonths: _listToSet(json['byMonths'] as List<dynamic>?),
      bySetPositions: _listToSet(json['bySetPositions'] as List<dynamic>?),
      weekStart: json['weekStart'] as int? ?? DateTime.monday,
    );
  }

  // TODO(GoldenSoju): Set has to be changed to List in order for method channel to accept it. Check if that is the best way to solve it.
  // TODO(GoldenSoju): Until has to be changed to int/long. Check how to solve this the best way.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'frequency': frequencyToInt(frequency),
        'until': until?.millisecondsSinceEpoch,
        'count': count,
        'interval': interval,
        'bySeconds': bySeconds.toList(),
        'byMinutes': byMinutes.toList(),
        'byHours': byHours.toList(),
        'byWeekDays':
            byWeekDays.map((weekDayEntry) => weekDayEntry.toJson()).toList(),
        'byMonthDays': byMonthDays.toList(),
        'byYearDays': byYearDays.toList(),
        'byWeeks': byWeeks.toList(),
        'byMonths': byMonths.toList(),
        'bySetPositions': bySetPositions.toList(),
        'weekStart': actualWeekStart,
      }..removeWhere((key, dynamic value) {
          if (value is int?) {
            if (value == null) {
              return true;
            } else {
              return false;
            }
          } else if (value is List?) {
            if (value!.isEmpty) {
              return true;
            } else {
              return false;
            }
          } else {
            return false;
          }
        });
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
