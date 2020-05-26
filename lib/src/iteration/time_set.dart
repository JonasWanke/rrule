import 'package:time_machine/time_machine.dart';

import '../frequency.dart';
import '../recurrence_rule.dart';
import '../utils.dart';

/// Values in the result are unique, but we need them ordered and indexable.
List<LocalTime> makeTimeSet(RecurrenceRule rrule, LocalTime start) {
  if (rrule.frequency <= RecurrenceFrequency.daily) {
    return _buildTimeSet(rrule, start);
  }

  if ((rrule.frequency >= RecurrenceFrequency.hourly &&
          !rrule.byHours.isEmptyOrContains(start.hourOfDay)) ||
      (rrule.frequency >= RecurrenceFrequency.minutely &&
          !rrule.byMinutes.isEmptyOrContains(start.minuteOfHour)) ||
      (rrule.frequency >= RecurrenceFrequency.secondly &&
          !rrule.bySeconds.isEmptyOrContains(start.secondOfMinute))) {
    return [];
  }

  return createTimeSet(rrule, start);
}

List<LocalTime> _buildTimeSet(RecurrenceRule rrule, LocalTime start) {
  return [
    for (final hour in rrule.byHours)
      for (final minute in rrule.byMinutes)
        for (final second in rrule.bySeconds)
          start.copyWith(hour: hour, minute: minute, second: second)
  ];
}

List<LocalTime> createTimeSet(RecurrenceRule rrule, LocalTime start) {
  if (rrule.frequency == RecurrenceFrequency.hourly) {
    return _buildHourTimeSet(rrule, start);
  } else if (rrule.frequency == RecurrenceFrequency.minutely) {
    return _buildMinuteTimeSet(rrule, start);
  } else if (rrule.frequency == RecurrenceFrequency.secondly) {
    return _buildSecondTimeSet(start);
  }

  assert(false);
  return null;
}

List<LocalTime> _buildHourTimeSet(RecurrenceRule rrule, LocalTime base) {
  return [
    for (final minute in rrule.byMinutes)
      ..._buildMinuteTimeSet(rrule, base.copyWith(minute: minute)),
  ];
}

List<LocalTime> _buildMinuteTimeSet(RecurrenceRule rrule, LocalTime base) {
  return [
    for (final second in rrule.bySeconds)
      ..._buildSecondTimeSet(base.copyWith(second: second)),
  ];
}

List<LocalTime> _buildSecondTimeSet(LocalTime base) => [base];
