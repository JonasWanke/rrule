import 'package:basics/basics.dart';
import 'package:time_machine/time_machine.dart';

import '../frequency.dart';
import '../recurrence_rule.dart';
import '../utils.dart';
import 'date_set.dart';

/// Removes dates that are filtered out by any of the following in place:
/// - [RecurrenceRule.byWeekDays]
/// - [RecurrenceRule.byMonthDays]
/// - [RecurrenceRule.byYearDays]
/// - [RecurrenceRule.byWeeks]
/// - [RecurrenceRule.byMonths]
bool removeFilteredDates(RecurrenceRule rrule, DateSet dateSet) {
  var isFiltered = false;
  for (final i in dateSet.start.to(dateSet.end)) {
    final date = dateSet.firstDayOfYear.addDays(i);
    final isCurrentFiltered = _isFiltered(rrule, date);

    dateSet.isIncluded[i] = !isCurrentFiltered;
    isFiltered |= isCurrentFiltered;
  }
  return isFiltered;
}

/// Whether [date] is filtered by any of the following:
/// - [RecurrenceRule.byWeekDays]
/// - [RecurrenceRule.byMonthDays]
/// - [RecurrenceRule.byYearDays]
/// - [RecurrenceRule.byWeeks]
/// - [RecurrenceRule.byMonths]
bool _isFiltered(RecurrenceRule rrule, LocalDate date) {
  return _isFilteredByMonths(rrule, date) ||
      _isFilteredByWeeks(rrule, date) ||
      _isFilteredByWeekDays(rrule, date) ||
      _isFilteredByMonthDays(rrule, date) ||
      _isFilteredByYearDays(rrule, date);
}

bool _isFilteredByMonths(RecurrenceRule rrule, LocalDate date) =>
    !rrule.byMonths.isEmptyOrContains(date.monthOfYear);

bool _isFilteredByWeeks(RecurrenceRule rrule, LocalDate date) {
  if (rrule.byWeeks.isEmpty) {
    return false;
  }

  final weekOfYear = rrule.weekYearRule.getWeekOfWeekYear(date);
  final weekYear = rrule.weekYearRule.getWeekYear(date);
  final weeksInYear =
      rrule.weekYearRule.getWeeksInWeekYear(weekYear, date.calendar);
  final negativeWeekOfYear = weekOfYear - weeksInYear;
  if (rrule.byWeeks.isNotEmpty &&
      !rrule.byWeeks.contains(weekOfYear) &&
      !rrule.byWeeks.contains(negativeWeekOfYear)) {
    return true;
  }
  return _isFilteredByWeekDays(rrule, date);
}

bool _isFilteredByWeekDays(RecurrenceRule rrule, LocalDate date) {
  if (rrule.byWeekDays.isEmpty) {
    return false;
  }

  final dayOfWeek = date.dayOfWeek;
  final relevantByWeekDays = rrule.byWeekDays.where((e) => e.day == dayOfWeek);
  final genericByWeekDays =
      relevantByWeekDays.where((e) => e.occurrence == null);
  if (genericByWeekDays.isNotEmpty) {
    // MO, TU, etc. match
    return false;
  }

  // +3TU, -51TH, etc. match
  final specificByWeekDays = relevantByWeekDays
      .where((e) => e.occurrence != null)
      .map((e) => e.occurrence);
  if (specificByWeekDays.isEmpty) {
    return true;
  }

  if (rrule.frequency == RecurrenceFrequency.yearly && rrule.byMonths.isEmpty) {
    assert(
      rrule.byWeeks.isEmpty,
      '"[…], the BYDAY rule part MUST NOT be specified with a numeric '
      'value with the FREQ rule part set to YEARLY when the BYWEEKNO rule part '
      'is specified." '
      '— https://tools.ietf.org/html/rfc5545#section-3.3.10',
    );

    var current =
        LocalDate(date.year, 1, 1).adjust(DateAdjusters.nextOrSame(dayOfWeek));
    var occurrence = 1;
    while (current != date) {
      current = current + Period(weeks: 1);
      occurrence++;
    }

    var totalOccurrences = occurrence - 1;
    while (current.year == date.year) {
      current = current + Period(weeks: 1);
      totalOccurrences++;
    }
    final negativeOccurrence = occurrence - 1 - totalOccurrences;

    if (!specificByWeekDays.contains(occurrence) &&
        !specificByWeekDays.contains(negativeOccurrence)) {
      return true;
    }
  } else if (rrule.frequency == RecurrenceFrequency.monthly) {
    var current = date
        .adjust(DateAdjusters.startOfMonth)
        .adjust(DateAdjusters.nextOrSame(dayOfWeek));
    var occurrence = 1;
    while (current != date) {
      current = current + Period(weeks: 1);
      occurrence++;
    }

    var totalOccurrences = occurrence - 1;
    while (current.monthOfYear == date.monthOfYear) {
      current = current + Period(weeks: 1);
      totalOccurrences++;
    }
    final negativeOccurrence = occurrence - 1 - totalOccurrences;

    if (!specificByWeekDays.contains(occurrence) &&
        !specificByWeekDays.contains(negativeOccurrence)) {
      return true;
    }
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

bool _isFilteredByMonthDays(RecurrenceRule rrule, LocalDate date) {
  if (rrule.byMonthDays.isEmpty) {
    return false;
  }

  final dayOfMonth = date.dayOfMonth;
  final daysInMonth = date.calendar.getDaysInMonth(date.year, date.monthOfYear);
  final negativeDayOfMonth = dayOfMonth - 1 - daysInMonth;
  return !rrule.byMonthDays.contains(dayOfMonth) &&
      !rrule.byMonthDays.contains(negativeDayOfMonth);
}

bool _isFilteredByYearDays(RecurrenceRule rrule, LocalDate date) {
  if (rrule.byYearDays.isEmpty) {
    return false;
  }

  final dayOfYear = date.dayOfYear;
  final daysInYear = date.calendar.getDaysInYear(date.year);
  final negativeDayOfYear = dayOfYear - 1 - daysInYear;
  return !rrule.byYearDays.contains(dayOfYear) &&
      !rrule.byYearDays.contains(negativeDayOfYear);
}
