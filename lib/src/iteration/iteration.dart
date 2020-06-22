import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import '../by_week_day_entry.dart';
import '../codecs/string/ical.dart';
import '../frequency.dart';
import '../recurrence_rule.dart';
import 'date_set.dart';
import 'date_set_filtering.dart';
import 'frequency_interval.dart';
import 'set_positions_list.dart';
import 'time_set.dart';

/// The actual calculation of recurring instances of [rrule].
///
/// Inspired by https://github.com/jakubroztocil/rrule/blob/df660bf5973cf4ec993738c2cca0f4cec1f9c6e6/src/iter/index.ts.
Iterable<LocalDateTime> getRecurrenceRuleInstances(
  RecurrenceRule rrule, {
  @required LocalDateTime start,
}) sync* {
  assert(start != null);

  // ignore: parameter_assignments
  rrule = _prepare(rrule, start);

  var count = rrule.count;

  var currentStart = start;
  var timeSet = makeTimeSet(rrule, start.clockTime);

  // ignore: literal_only_boolean_expressions
  while (true) {
    final dateSet = makeDateSet(rrule, currentStart.calendarDate);
    final isFiltered = removeFilteredDates(rrule, dateSet);

    Iterable<LocalDateTime> results;
    if (rrule.hasBySetPositions) {
      results = buildSetPositionsList(rrule, dateSet, timeSet)
          .where((dt) => start <= dt);
    } else {
      results = dateSet.includedDates.expand((date) {
        return timeSet.map((time) => date.at(time));
      });
    }

    for (final result in results) {
      if (rrule.until != null && result > rrule.until) {
        return;
      }
      if (result < start) {
        continue;
      }

      yield result;
      if (count != null) {
        count--;
        if (count <= 0) {
          return;
        }
      }
    }

    currentStart = addFrequencyAndInterval(
      rrule,
      currentStart,
      wereDatesFiltered: isFiltered,
    );
    if (currentStart.year > iCalMaxYear) {
      return;
    }

    if (rrule.frequency > Frequency.daily) {
      timeSet = createTimeSet(rrule, currentStart.clockTime);
    }
  }
}

RecurrenceRule _prepare(RecurrenceRule rrule, LocalDateTime start) {
  final byDatesEmpty = rrule.byWeekDays.isEmpty &&
      rrule.byMonthDays.isEmpty &&
      rrule.byYearDays.isEmpty &&
      rrule.byWeeks.isEmpty;

  return RecurrenceRule(
    frequency: rrule.frequency,
    until: rrule.until,
    count: rrule.count,
    interval: rrule.interval,
    bySeconds: rrule.bySeconds.isEmpty && rrule.frequency < Frequency.secondly
        ? {start.secondOfMinute}
        : rrule.bySeconds,
    byMinutes: rrule.byMinutes.isEmpty && rrule.frequency < Frequency.minutely
        ? {start.minuteOfHour}
        : rrule.byMinutes,
    byHours: rrule.byHours.isEmpty && rrule.frequency < Frequency.hourly
        ? {start.hourOfDay}
        : rrule.byHours,
    byWeekDays: byDatesEmpty && rrule.frequency == Frequency.weekly
        ? {ByWeekDayEntry(start.dayOfWeek)}
        : rrule.byWeekDays,
    byMonthDays: byDatesEmpty &&
            (rrule.frequency == Frequency.monthly ||
                rrule.frequency == Frequency.yearly)
        ? {start.dayOfMonth}
        : rrule.byMonthDays,
    byYearDays: rrule.byYearDays,
    byWeeks: rrule.byWeeks,
    byMonths: byDatesEmpty &&
            rrule.frequency == Frequency.yearly &&
            rrule.byMonths.isEmpty
        ? {start.monthOfYear}
        : rrule.byMonths,
    bySetPositions: rrule.bySetPositions,
    weekStart: rrule.weekStart,
  );
}
