import '../frequency.dart';
import '../recurrence_rule.dart';
import '../utils.dart';

/// Values in the result are unique, but we need them ordered.
Iterable<Duration> makeTimeSet(RecurrenceRule rrule, Duration start) {
  assert(start.isValidRruleTimeOfDay);

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

Iterable<Duration> createTimeSet(RecurrenceRule rrule, Duration start) {
  assert(start.isValidRruleTimeOfDay);

  if (rrule.frequency == Frequency.hourly) {
    return _buildHourTimeSet(rrule, start);
  } else if (rrule.frequency == Frequency.minutely) {
    return _buildMinuteTimeSet(rrule, start);
  } else if (rrule.frequency == Frequency.secondly) {
    return _buildSecondTimeSet(start);
  }
  throw ArgumentError('Invalid frequency: ${rrule.frequency}.');
}

// Even if a byHour/byMinute/bySecond option is not specified (empty),
// [_prepare] in `iteration.dart` will add an option corresponding to the start
// value.
Iterable<Duration> _buildDayTimeSet(RecurrenceRule rrule, Duration base) sync* {
  assert(base.isValidRruleTimeOfDay);

  for (final hour in rrule.byHours) {
    yield* _buildHourTimeSet(rrule, base.copyWith(hourOfDay: hour));
  }
}

Iterable<Duration> _buildHourTimeSet(
  RecurrenceRule rrule,
  Duration base,
) sync* {
  assert(base.isValidRruleTimeOfDay);

  for (final minute in rrule.byMinutes) {
    yield* _buildMinuteTimeSet(rrule, base.copyWith(minuteOfHour: minute));
  }
}

Iterable<Duration> _buildMinuteTimeSet(
  RecurrenceRule rrule,
  Duration base,
) sync* {
  assert(base.isValidRruleTimeOfDay);

  for (final second in rrule.bySeconds) {
    yield* _buildSecondTimeSet(base.copyWith(secondOfMinute: second));
  }
}

Iterable<Duration> _buildSecondTimeSet(Duration base) {
  assert(base.isValidRruleTimeOfDay);

  return [base];
}
