import 'dart:math' as math;

import 'package:time/time.dart';

export 'utils/week.dart';

extension DateTimeRrule on DateTime {
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
    return InternalDateTimeRrule.create(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      millisecond: millisecond ?? this.millisecond,
      // Microseconds are not supported on web: https://github.com/dart-lang/sdk/issues/44876
      isUtc: isUtc ?? this.isUtc,
    );
  }
}

extension InternalDateTimeRrule on DateTime {
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
    final constructor = isUtc ? DateTime.utc : DateTime.new;
    return constructor(year, month, day, hour, minute, second, millisecond);
  }

  static DateTime date(int year, [int month = 1, int day = 1]) {
    final date = DateTime.utc(year, month, day);
    assert(date.isValidRruleDate);
    return date;
  }

  bool operator <(DateTime other) => isBefore(other);
  bool operator <=(DateTime other) =>
      isBefore(other) || isAtSameMomentAs(other);
  bool operator >(DateTime other) => isAfter(other);
  bool operator >=(DateTime other) => isAfter(other) || isAtSameMomentAs(other);

  Duration get timeOfDay => difference(atStartOfDay);

  DateTime get atStartOfDay => DateTimeRrule(this)
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
  bool get isAtStartOfDay => this == atStartOfDay;
  DateTime get atEndOfDay => DateTimeRrule(this)
      .copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);
  bool get isAtEndOfDay => this == atEndOfDay;

  static DateTime today() {
    final date = DateTime.now().toUtc().atStartOfDay;
    assert(date.isValidRruleDate);
    return date;
  }

  bool get isToday => atStartOfDay == InternalDateTimeRrule.today();

  DateTime plusYearsAndMonths({int years = 0, int months = 0}) {
    final targetYear = year + years + (month + months) ~/ 12;
    final targetMonth = (month + months) % 12;
    final startOfTargetMonth =
        InternalDateTimeRrule.date(targetYear, targetMonth);
    return DateTimeRrule(this).copyWith(
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
      microseconds: microsecondOfSecond,
    );
  }

  int get hourOfDay => inHours;
  int get minuteOfHour => inMinutes % Duration.minutesPerHour;
  int get secondOfMinute => inSeconds % Duration.secondsPerMinute;
  int get microsecondOfSecond =>
      inMicroseconds % Duration.microsecondsPerSecond;
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
      return const Iterable.empty();
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
