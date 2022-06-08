import 'dart:math' as math;

import 'package:time/time.dart';

export 'utils/week.dart';

/// Combines the [Object.hashCode] values of an arbitrary number of objects
/// from an [Iterable] into one value. This function will return the same
/// value if given `null` as if given an empty list.
// Borrowed from dart:ui.
int hashList(Iterable<Object?>? arguments) {
  var result = 0;
  if (arguments != null) {
    for (final argument in arguments) {
      var hash = result;
      hash = 0x1fffffff & (hash + argument.hashCode);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      result = hash ^ (hash >> 6);
    }
  }
  result = 0x1fffffff & (result + ((0x03ffffff & result) << 3));
  result = result ^ (result >> 11);
  return 0x1fffffff & (result + ((0x00003fff & result) << 15));
}

extension DateTimeRrule on DateTime {
  static DateTime create({
    required int year,
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    bool isUtc = true,
  }) {
    if (isUtc) {
      return DateTime.utc(year, month, day, hour, minute, second, millisecond);
    }
    return DateTime(year, month, day, hour, minute, second, millisecond);
  }

  static DateTime date(int year, [int month = 1, int day = 1]) {
    final date = DateTime.utc(year, month, day);
    assert(date.isValidRruleDate);
    return date;
  }

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    bool? isUtc,
  }) {
    return DateTimeRrule.create(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      millisecond: millisecond ?? this.millisecond,
      isUtc: isUtc ?? this.isUtc,
    );
  }

  bool operator <(DateTime other) => isBefore(other);
  bool operator <=(DateTime other) =>
      isBefore(other) || isAtSameMomentAs(other);
  bool operator >(DateTime other) => isAfter(other);
  bool operator >=(DateTime other) => isAfter(other) || isAtSameMomentAs(other);

  Duration get timeOfDay => difference(atStartOfDay);

  DateTime get atStartOfDay =>
      copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
  bool get isAtStartOfDay => this == atStartOfDay;
  DateTime get atEndOfDay =>
      copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);
  bool get isAtEndOfDay => this == atEndOfDay;

  static DateTime today() {
    final date = DateTime.now().toUtc().atStartOfDay;
    assert(date.isValidRruleDate);
    return date;
  }

  bool get isToday => atStartOfDay == DateTimeRrule.today();

  DateTime plusYearsAndMonths({int years = 0, int months = 0}) {
    final targetYear = year + years + (month + months) ~/ 12;
    final targetMonth = (month + months) % 12;
    final startOfTargetMonth = DateTimeRrule.date(targetYear, targetMonth);
    return copyWith(
      year: targetYear,
      month: targetMonth,
      // Quietly force the day of month to the nearest sane value.
      day: math.min(day, startOfTargetMonth.daysInMonth),
    );
  }

  DateTime plusYears(int years) => plusYearsAndMonths(years: years);
  DateTime plusMonths(int months) => plusYearsAndMonths(months: months);

  DateTime nextOrSame(int dayOfWeek) {
    assert(dayOfWeek.isValidRruleDayOfWeek);

    return add(((dayOfWeek - weekday) % DateTime.daysPerWeek).days);
  }
}

extension NullableDateTimeRrule on DateTime? {
  bool get isValidRruleDateTime => this == null || this!.isUtc;
  bool get isValidRruleDate =>
      isValidRruleDateTime && (this == null || this!.isAtStartOfDay);
}

extension DurationRrule on Duration {
  Duration copyWith({int? hourOfDay, int? minuteOfHour, int? secondOfMinute}) {
    return Duration(
      hours: hourOfDay ?? this.hourOfDay,
      minutes: minuteOfHour ?? this.minuteOfHour,
      seconds: secondOfMinute ?? this.secondOfMinute,
    );
  }

  int get hourOfDay => inHours;
  int get minuteOfHour => inMinutes % Duration.minutesPerHour;
  int get secondOfMinute => inSeconds % Duration.secondsPerMinute;
}

extension NullableDurationRrule on Duration? {
  bool get isValidRruleTimeOfDay =>
      this == null || (0.days <= this! && this! <= 1.days);
}

extension IntRange on int {
  // Copied from supercharged_dart

  /// Creates an [Iterable<int>] that contains all values from current integer
  /// until (including) the value [n].
  ///
  /// Example:
  /// ```dart
  /// 0.rangeTo(5); // [0, 1, 2, 3, 4, 5]
  /// 3.rangeTo(1); // [3, 2, 1]
  /// ```
  Iterable<int> rangeTo(int n) {
    final count = (n - this).abs() + 1;
    final direction = (n - this).sign;
    var i = this - direction;
    return Iterable.generate(count, (index) {
      return i += direction;
    });
  }

  /// Creates an [Iterable<int>] that contains all values from current integer
  /// until (excluding) the value [n].
  ///
  /// Example:
  /// ```dart
  /// 0.until(5); // [0, 1, 2, 3, 4]
  /// 3.until(1); // [3, 2]
  /// ```
  Iterable<int> until(int n) {
    if (this < n) {
      return rangeTo(n - 1);
    } else if (this > n) {
      return rangeTo(n + 1);
    } else {
      return Iterable.empty();
    }
  }
}

extension NullableIntRrule on int? {
  bool get isValidRruleDayOfWeek =>
      this == null || (DateTime.monday <= this! && this! <= DateTime.sunday);
}

extension IterableRrule<T> on Iterable<T> {
  bool isEmptyOrContains(T item) => isEmpty || contains(item);
}
