import 'package:time/time.dart';

import '../frequency.dart';
import '../recurrence_rule.dart';
import '../utils.dart';
import 'date_set.dart';

/// Removes dates that are filtered out by any of the following in place:
///
/// * [RecurrenceRule.byWeekDays]
/// * [RecurrenceRule.byMonthDays]
/// * [RecurrenceRule.byYearDays]
/// * [RecurrenceRule.byWeeks]
/// * [RecurrenceRule.byMonths]
bool removeFilteredDates(RecurrenceRule rrule, DateSet dateSet) {
  var isFiltered = false;
  for (final i in dateSet.start.until(dateSet.end)) {
    final date = dateSet.firstDayOfYear.add(i.days);
    final isCurrentFiltered = _isFiltered(rrule, date);

    dateSet.isIncluded[i] = !isCurrentFiltered;
    isFiltered |= isCurrentFiltered;
  }
  return isFiltered;
}

/// Whether [date] is filtered by any of the following:
///
/// * [RecurrenceRule.byWeekDays]
/// * [RecurrenceRule.byMonthDays]
/// * [RecurrenceRule.byYearDays]
/// * [RecurrenceRule.byWeeks]
/// * [RecurrenceRule.byMonths]
bool _isFiltered(RecurrenceRule rrule, DateTime date) {
  assert(date.isValidRruleDate);

  return _isFilteredByMonths(rrule, date) ||
      _isFilteredByWeeks(rrule, date) ||
      _isFilteredByWeekDays(rrule, date) ||
      _isFilteredByMonthDays(rrule, date) ||
      _isFilteredByYearDays(rrule, date);
}

bool _isFilteredByMonths(RecurrenceRule rrule, DateTime date) {
  assert(date.isValidRruleDate);

  return !rrule.byMonths.isEmptyOrContains(date.month);
}

bool _isFilteredByWeeks(RecurrenceRule rrule, DateTime date) {
  assert(date.isValidRruleDate);

  if (rrule.byWeeks.isEmpty) return false;

  final weekInfo = date.weekInfo;
  final weeksInYear = WeekInfo.weeksInYear(weekInfo.weekBasedYear);
  final negativeWeekOfYear = weekInfo.weekOfYear - weeksInYear;
  if (rrule.hasByWeeks &&
      !rrule.byWeeks.contains(weekInfo.weekOfYear) &&
      !rrule.byWeeks.contains(negativeWeekOfYear)) {
    return true;
  }
  return _isFilteredByWeekDays(rrule, date);
}

bool _isFilteredByWeekDays(RecurrenceRule rrule, DateTime date) {
  assert(date.isValidRruleDate);

  if (rrule.byWeekDays.isEmpty) return false;

  final dayOfWeek = date.weekday;
  final relevantByWeekDays = rrule.byWeekDays.where((e) => e.day == dayOfWeek);

  // MO, TU, etc. match
  final genericByWeekDays = relevantByWeekDays.where((e) => e.hasNoOccurrence);
  if (genericByWeekDays.isNotEmpty) return false;

  // +3TU, -51TH, etc. match
  final specificByWeekDays = relevantByWeekDays
      .where((e) => e.hasOccurrence)
      .map((e) => e.occurrence!)
      .toSet();
  if (specificByWeekDays.isEmpty) return true;

  if (rrule.frequency == Frequency.yearly) {
    assert(
      rrule.byWeeks.isEmpty,
      '"[…], the BYDAY rule part MUST NOT be specified with a numeric '
      'value with the FREQ rule part set to YEARLY when the BYWEEKNO rule part '
      'is specified." '
      '— https://tools.ietf.org/html/rfc5545#section-3.3.10',
    );

    if (rrule.byMonths.isEmpty) {
      return _doesOccurrenceMatch(
        specificByWeekDays,
        date.firstDayOfYear,
        date.lastDayOfYear,
        date,
      );
    } else {
      return _doesOccurrenceMatch(
        specificByWeekDays,
        date.firstDayOfMonth,
        date.lastDayOfMonth,
        date,
      );
    }
  } else if (rrule.frequency == Frequency.monthly) {
    return _doesOccurrenceMatch(
      specificByWeekDays,
      date.firstDayOfMonth,
      date.lastDayOfMonth,
      date,
    );
  } else {
    assert(
      false,
      '"The BYDAY rule part MUST NOT be specified with a numeric value when '
      'the FREQ rule part is not set to MONTHLY or YEARLY." '
      '— https://tools.ietf.org/html/rfc5545#section-3.3.10',
    );
  }

  return false;
}

bool _doesOccurrenceMatch(
  Set<int> occurrences,
  DateTime firstDateWithinPeriod,
  DateTime lastDateWithinPeriod,
  DateTime date,
) {
  assert(firstDateWithinPeriod <= date);
  assert(lastDateWithinPeriod >= date);

  var current = firstDateWithinPeriod.nextOrSame(date.weekday);
  var occurrence = 1;
  while (current < date) {
    current = current + 1.weeks;
    occurrence++;
  }
  assert(current == date);

  var totalOccurrences = occurrence - 1;
  while (current <= lastDateWithinPeriod) {
    current = current + 1.weeks;
    totalOccurrences++;
  }
  final negativeOccurrence = occurrence - 1 - totalOccurrences;

  if (!occurrences.contains(occurrence) &&
      !occurrences.contains(negativeOccurrence)) {
    return true;
  }
  return false;
}

bool _isFilteredByMonthDays(RecurrenceRule rrule, DateTime date) {
  assert(date.isValidRruleDate);

  if (rrule.byMonthDays.isEmpty) return false;

  final negativeDayOfMonth = date.day - 1 - date.daysInMonth;
  return !rrule.byMonthDays.contains(date.day) &&
      !rrule.byMonthDays.contains(negativeDayOfMonth);
}

bool _isFilteredByYearDays(RecurrenceRule rrule, DateTime date) {
  assert(date.isValidRruleDate);

  if (rrule.byYearDays.isEmpty) return false;

  final negativeDayOfYear = date.dayOfYear - 1 - date.daysInYear;
  return !rrule.byYearDays.contains(date.dayOfYear) &&
      !rrule.byYearDays.contains(negativeDayOfYear);
}
