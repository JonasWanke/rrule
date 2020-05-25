import 'package:basics/basics.dart';
import 'package:time_machine/time_machine.dart';

import '../recurrence_rule.dart';
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
      _isFilteredByWeeksOrWeekDays(rrule, date) ||
      _isFilteredByMonthDays(rrule, date) ||
      _isFilteredByYearDays(rrule, date);
}

bool _isFilteredByMonths(RecurrenceRule rrule, LocalDate date) =>
    rrule.byMonths.contains(date.monthOfYear);
bool _isFilteredByWeeksOrWeekDays(RecurrenceRule rrule, LocalDate date) {
  // [RecurrenceRule.byWeeks]
  final weekOfYear = rrule.weekYearRule.getWeekOfWeekYear(date);
  if (rrule.byWeeks.contains(weekOfYear)) {
    return true;
  }
  final weekYear = rrule.weekYearRule.getWeekYear(date);
  final weeksInYear =
      rrule.weekYearRule.getWeeksInWeekYear(weekYear, date.calendar);
  final negativeWeekOfYear = weekOfYear - weeksInYear;
  if (rrule.byWeeks.contains(negativeWeekOfYear)) {
    return true;
  }

  // [RecurrenceRule.byWeekDays]
  final dayOfWeek = date.dayOfWeek;
  final relevantByWeekDays = rrule.byWeekDays.where((e) => e.day == dayOfWeek);
  final genericByWeekDays =
      relevantByWeekDays.where((e) => e.occurrence == null);
  if (genericByWeekDays.isNotEmpty) {
    return true;
  }
  final specificByWeekDays = relevantByWeekDays
      .where((e) => e.occurrence != null)
      .map((e) => e.occurrence);
  if (specificByWeekDays.contains(weekOfYear) ||
      specificByWeekDays.contains(negativeWeekOfYear)) {
    return true;
  }

  return false;
}

bool _isFilteredByMonthDays(RecurrenceRule rrule, LocalDate date) {
  final dayOfMonth = date.dayOfMonth;
  final daysInMonth = date.calendar.getDaysInMonth(date.year, date.monthOfYear);
  final negativeDayOfMonth = dayOfMonth - daysInMonth;
  return rrule.byMonthDays.contains(dayOfMonth) ||
      rrule.byMonthDays.contains(negativeDayOfMonth);
}

bool _isFilteredByYearDays(RecurrenceRule rrule, LocalDate date) {
  final dayOfYear = date.dayOfYear;
  final daysInYear = date.calendar.getDaysInYear(date.year);
  final negativeDayOfYear = dayOfYear - 1 - daysInYear;
  return rrule.byYearDays.contains(dayOfYear) ||
      rrule.byYearDays.contains(negativeDayOfYear);
}
