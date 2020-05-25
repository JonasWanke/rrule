import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import '../frequency.dart';
import '../recurrence_rule.dart';

LocalDateTime addFrequencyAndInterval(
  RecurrenceRule rrule,
  LocalDateTime currentStart, {
  @required bool wereDatesFiltered,
}) {
  if (rrule.frequency == RecurrenceFrequency.yearly) {
    return currentStart._addYears(rrule.actualInterval);
  } else if (rrule.frequency == RecurrenceFrequency.monthly) {
    return currentStart._addMonths(rrule.actualInterval);
  } else if (rrule.frequency == RecurrenceFrequency.weekly) {
    return currentStart._addWeeks(rrule.actualInterval, rrule.weekStart);
  } else if (rrule.frequency == RecurrenceFrequency.daily) {
    return currentStart._addDays(rrule.actualInterval);
  } else if (rrule.frequency == RecurrenceFrequency.hourly) {
    return currentStart._addHours(
      rrule.actualInterval,
      wereDatesFiltered,
      rrule.byHours,
    );
  } else if (rrule.frequency == RecurrenceFrequency.minutely) {
    return currentStart._addMinutes(
      rrule.actualInterval,
      wereDatesFiltered,
      rrule.byHours,
      rrule.byMinutes,
    );
  } else if (rrule.frequency == RecurrenceFrequency.secondly) {
    return currentStart._addSeconds(
      rrule.actualInterval,
      wereDatesFiltered,
      rrule.byHours,
      rrule.byMinutes,
      rrule.bySeconds,
    );
  }

  assert(false);
  return null;
}

extension _FrequencyIntervalCalculation on LocalDateTime {
  LocalDateTime _addYears(int years) => this + Period(years: years);

  LocalDateTime _addMonths(int months) => this + Period(months: months);

  LocalDateTime _addWeeks(int weeks, DayOfWeek weekStart) {
    return this +
        Period(
          weeks: weeks,
          days: (dayOfWeek.value - weekStart.value) % TimeConstants.daysPerWeek,
        );
  }

  LocalDateTime _addDays(int days) => this + Period(days: days);

  LocalDateTime _addHours(int hours, bool wereDatesFiltered, Set<int> byHours) {
    var newValue = this;
    if (wereDatesFiltered) {
      // Jump to one iteration before next day.
      final timeToLastHour = TimeConstants.hoursPerDay - 1 - newValue.hourOfDay;
      final hoursToLastIterationOfDay =
          (timeToLastHour / hours).floor() * hours;
      newValue += Period(hours: hoursToLastIterationOfDay);
    }

    // ignore: literal_only_boolean_expressions
    while (true) {
      newValue += Period(hours: hours);

      if (byHours.isEmpty || byHours.contains(newValue.hourOfDay)) {
        break;
      }
    }
    return newValue;
  }

  LocalDateTime _addMinutes(
    int minutes,
    bool wereDatesFiltered,
    Set<int> byHours,
    Set<int> byMinutes,
  ) {
    var newValue = this;
    if (wereDatesFiltered) {
      // Jump to one iteration before next day.
      final timeToLastMinute = TimeConstants.minutesPerDay -
          1 -
          newValue.hourOfDay * TimeConstants.minutesPerHour -
          newValue.minuteOfHour;
      final minutesToLastIterationOfDay =
          (timeToLastMinute / minutes).floor() * minutes;
      newValue += Period(minutes: minutesToLastIterationOfDay);
    }

    // ignore: literal_only_boolean_expressions
    while (true) {
      final hours = minutes ~/ TimeConstants.minutesPerHour;
      final minutesWithoutHours = minutes % TimeConstants.minutesPerHour;
      if (hours > 0) {
        newValue = newValue._addHours(hours, wereDatesFiltered, byHours);
      }
      newValue += Period(minutes: minutesWithoutHours);

      if ((byHours.isEmpty || byHours.contains(newValue.hourOfDay)) &&
          (byMinutes.isEmpty || byMinutes.contains(newValue.minuteOfHour))) {
        break;
      }
    }
    return newValue;
  }

  LocalDateTime _addSeconds(
    int seconds,
    bool wereDatesFiltered,
    Set<int> byHours,
    Set<int> byMinutes,
    Set<int> bySeconds,
  ) {
    var newValue = this;
    if (wereDatesFiltered) {
      // Jump to one iteration before next day.
      final timeToLastMinute = TimeConstants.secondsPerDay -
          1 -
          newValue.hourOfDay * TimeConstants.secondsPerHour -
          newValue.minuteOfHour * TimeConstants.secondsPerMinute -
          newValue.secondOfMinute;
      final secondsToLastIterationOfDay =
          (timeToLastMinute / seconds).floor() * seconds;
      newValue += Period(seconds: secondsToLastIterationOfDay);
    }

    // ignore: literal_only_boolean_expressions
    while (true) {
      final minutes = seconds ~/ TimeConstants.secondsPerMinute;
      final secondsWithoutMinutes = minutes % TimeConstants.secondsPerMinute;
      if (minutes > 0) {
        newValue = newValue._addMinutes(
          minutes,
          wereDatesFiltered,
          byHours,
          byMinutes,
        );
      }
      newValue += Period(seconds: secondsWithoutMinutes);

      if ((byHours.isEmpty || byHours.contains(newValue.hourOfDay)) &&
          (byMinutes.isEmpty || byMinutes.contains(newValue.minuteOfHour)) &&
          (bySeconds.isEmpty || bySeconds.contains(newValue.secondOfMinute))) {
        break;
      }
    }
    return newValue;
  }
}
