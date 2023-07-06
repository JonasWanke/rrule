import '../by_week_day_entry.dart';
import '../codecs/string/ical.dart';
import '../frequency.dart';
import '../recurrence_rule.dart';
import '../utils.dart';
import 'date_set.dart';
import 'date_set_filtering.dart';
import 'frequency_interval.dart';
import 'set_positions_list.dart';
import 'time_set.dart';

/// The actual calculation of recurring instances of [rrule].
///
/// Inspired by https://github.com/jakubroztocil/rrule/blob/df660bf5973cf4ec993738c2cca0f4cec1f9c6e6/src/iter/index.ts.
Iterable<DateTime> getRecurrenceRuleInstances(
  RecurrenceRule rrule, {
  required DateTime start,
  DateTime? after,
  bool includeAfter = false,
  DateTime? before,
  bool includeBefore = false,
}) sync* {
  assert(start.isValidRruleDateTime);
  assert(after.isValidRruleDateTime);
  assert(before.isValidRruleDateTime);
  if (after != null) assert(after >= start);
  if (before != null) assert(before >= start);

  rrule = _prepare(rrule, start);

  var count = rrule.count;

  var currentStart = start;
  var timeSet = makeTimeSet(rrule, start.timeOfDay);

  // ignore: literal_only_boolean_expressions
  while (true) {
    final dateSet = makeDateSet(rrule, currentStart.atStartOfDay);
    final isFiltered = removeFilteredDates(rrule, dateSet);

    Iterable<DateTime> results;
    if (rrule.hasBySetPositions) {
      results = buildSetPositionsList(rrule, dateSet, timeSet).where((dt) => start <= dt);
    } else {
      results = dateSet.includedDates.expand((date) {
        return timeSet.map((time) => date.add(time));
      });
    }

    for (final result in results) {
      if (rrule.until != null && result > rrule.until!) return;
      if (before != null) {
        if (!includeBefore && result >= before) return;
        if (includeBefore && result > before) return;
      }

      if (result < start) continue;

      var isInRange = true;
      if (after != null) {
        if (!includeAfter && result <= after) isInRange = false;
        if (includeAfter && result < after) isInRange = false;
      }

      if (isInRange) yield result;

      if (count != null) {
        count--;
        if (count <= 0) return;
      }
    }

    currentStart = addFrequencyAndInterval(
      rrule,
      currentStart,
      wereDatesFiltered: isFiltered,
    );
    if (currentStart.year > iCalMaxYear) return;

    if (rrule.frequency > Frequency.daily) {
      timeSet = createTimeSet(rrule, currentStart.timeOfDay);
    }
  }
}

RecurrenceRule _prepare(RecurrenceRule rrule, DateTime start) {
  assert(start.isValidRruleDateTime);

  final byDatesEmpty =
      rrule.byWeekDays.isEmpty && rrule.byMonthDays.isEmpty && rrule.byYearDays.isEmpty && rrule.byWeeks.isEmpty;

  return RecurrenceRule(
    frequency: rrule.frequency,
    until: rrule.until,
    count: rrule.count,
    interval: rrule.interval,
    bySeconds: rrule.bySeconds.isEmpty && rrule.frequency < Frequency.secondly ? [start.second] : rrule.bySeconds,
    byMinutes: rrule.byMinutes.isEmpty && rrule.frequency < Frequency.minutely ? [start.minute] : rrule.byMinutes,
    byHours: rrule.byHours.isEmpty && rrule.frequency < Frequency.hourly ? [start.hour] : rrule.byHours,
    byWeekDays:
        byDatesEmpty && rrule.frequency == Frequency.weekly ? {ByWeekDayEntry(start.weekday)} : rrule.byWeekDays,
    byMonthDays: byDatesEmpty && (rrule.frequency == Frequency.monthly || rrule.frequency == Frequency.yearly)
        ? {start.day}
        : rrule.byMonthDays,
    byYearDays: rrule.byYearDays,
    byWeeks: rrule.byWeeks,
    byMonths:
        byDatesEmpty && rrule.frequency == Frequency.yearly && rrule.byMonths.isEmpty ? {start.month} : rrule.byMonths,
    bySetPositions: rrule.bySetPositions,
    weekStart: rrule.weekStart,
  );
}
