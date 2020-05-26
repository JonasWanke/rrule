import 'package:time_machine/time_machine.dart';

import '../frequency.dart';
import '../recurrence_rule.dart';
import '../utils.dart';

/// Values in the result are unique, but we need them ordered.
Iterable<LocalTime> makeTimeSet(RecurrenceRule rrule, LocalTime start) {
  if (rrule.frequency <= Frequency.daily) {
    return _buildDayTimeSet(rrule, start);
  }

  if ((rrule.frequency >= Frequency.hourly &&
          !rrule.byHours.isEmptyOrContains(start.hourOfDay)) ||
      (rrule.frequency >= Frequency.minutely &&
          !rrule.byMinutes.isEmptyOrContains(start.minuteOfHour)) ||
      (rrule.frequency >= Frequency.secondly &&
          !rrule.bySeconds.isEmptyOrContains(start.secondOfMinute))) {
    return [];
  }

  return createTimeSet(rrule, start);
}

Iterable<LocalTime> createTimeSet(RecurrenceRule rrule, LocalTime start) {
  if (rrule.frequency == Frequency.hourly) {
    return _buildHourTimeSet(rrule, start);
  } else if (rrule.frequency == Frequency.minutely) {
    return _buildMinuteTimeSet(rrule, start);
  } else if (rrule.frequency == Frequency.secondly) {
    return _buildSecondTimeSet(start);
  }

  assert(false);
  return null;
}

// Even if a byHour/byMinute/bySecond option is not specified (empty),
// [_prepare] in `iteration.dart` will add an option corresponding to the start
// value.
Iterable<LocalTime> _buildDayTimeSet(
  RecurrenceRule rrule,
  LocalTime base,
) sync* {
  for (final hour in rrule.byHours) {
    yield* _buildHourTimeSet(rrule, base.copyWith(hour: hour));
  }
}

Iterable<LocalTime> _buildHourTimeSet(
  RecurrenceRule rrule,
  LocalTime base,
) sync* {
  for (final minute in rrule.byMinutes) {
    yield* _buildMinuteTimeSet(rrule, base.copyWith(minute: minute));
  }
}

Iterable<LocalTime> _buildMinuteTimeSet(
  RecurrenceRule rrule,
  LocalTime base,
) sync* {
  for (final second in rrule.bySeconds) {
    yield* _buildSecondTimeSet(base.copyWith(second: second));
  }
}

Iterable<LocalTime> _buildSecondTimeSet(LocalTime base) => [base];
