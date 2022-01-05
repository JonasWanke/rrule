import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:time/time.dart';

import '../frequency.dart';
import '../recurrence_rule.dart';
import '../utils.dart';

@immutable
class DateSet {
  DateSet._({
    required this.isIncluded,
    required this.start,
    required this.end,
    required this.firstDayOfYear,
  })  : assert(start >= 0),
        assert(start <= end),
        assert(firstDayOfYear.isValidRruleDate);

  factory DateSet.create({
    required DateTime base,
    bool addExtraWeek = false,
    int start = 0,
    int? end,
  }) {
    assert(base.isValidRruleDate);

    var length = base.daysInYear;
    if (addExtraWeek) length += DateTime.daysPerWeek;

    final actualEnd = end ?? length;

    return DateSet._(
      isIncluded: List.generate(length, (i) => start <= i && i < actualEnd),
      start: start,
      end: actualEnd,
      firstDayOfYear: DateTimeRrule(base).copyWith(month: 1, day: 1),
    );
  }

  /// Each entry corresponds to whether the respective date of the year is
  /// potentially included in the result set.
  final List<bool> isIncluded;

  /// Inclusive index of the first `true` value.
  final int start;

  /// Exclusive index of the last `true` value.
  final int end;

  final DateTime firstDayOfYear;

  DateTime? operator [](int index) {
    if (!isIncluded[index]) return null;

    return firstDayOfYear.add(index.days);
  }

  Iterable<DateTime> get includedDates =>
      start.until(end).map((i) => this[i]).whereNotNull();
}

DateSet makeDateSet(RecurrenceRule rrule, DateTime base) {
  assert(base.isValidRruleDate);

  if (rrule.frequency == Frequency.yearly) {
    return _buildYearlyDateSet(base);
  } else if (rrule.frequency == Frequency.monthly) {
    return _buildMonthlyDateSet(base);
  } else if (rrule.frequency == Frequency.weekly) {
    return _buildWeeklyDateSet(base);
  } else {
    assert(rrule.frequency >= Frequency.daily);
    return _buildDailyDateSet(base);
  }
}

DateSet _buildYearlyDateSet(DateTime base) {
  assert(base.isValidRruleDate);

  return DateSet.create(base: base);
}

DateSet _buildMonthlyDateSet(DateTime base) {
  assert(base.isValidRruleDate);

  return DateSet.create(
    base: base,
    start: base.firstDayOfMonth.dayOfYear - 1,
    end: base.lastDayOfMonth.dayOfYear,
  );
}

DateSet _buildWeeklyDateSet(DateTime base) {
  assert(base.isValidRruleDate);

  // We need to handle cross-year weeks here.
  var i = base.dayOfYear - 1;
  final start = i;
  var current = base;
  for (final _ in 0.until(DateTime.daysPerWeek)) {
    i++;
    current = current.add(1.days);
    if (current.weekday == DateTime.monday) break;
  }
  return DateSet.create(base: base, addExtraWeek: true, start: start, end: i);
}

DateSet _buildDailyDateSet(DateTime base) {
  assert(base.isValidRruleDate);

  final dayOfYear = base.dayOfYear - 1;
  return DateSet.create(base: base, start: dayOfYear, end: dayOfYear + 1);
}
