import 'package:supercharged_dart/supercharged_dart.dart';

import '../frequency.dart';
import '../recurrence_rule.dart';
import '../utils.dart';

DateTime addFrequencyAndInterval(
  RecurrenceRule rrule,
  DateTime currentStart, {
  required bool wereDatesFiltered,
}) {
  assert(currentStart.isValidRruleDateTime);

  if (rrule.frequency == Frequency.yearly) {
    return currentStart._addYears(rrule.actualInterval);
  } else if (rrule.frequency == Frequency.monthly) {
    return currentStart._addMonths(rrule.actualInterval);
  } else if (rrule.frequency == Frequency.weekly) {
    return currentStart._addWeeks(rrule.actualInterval);
  } else if (rrule.frequency == Frequency.daily) {
    return currentStart._addDays(rrule.actualInterval);
  } else if (rrule.frequency == Frequency.hourly) {
    return currentStart._addHours(
      rrule.actualInterval,
      wereDatesFiltered,
      rrule.byHours,
    );
  } else if (rrule.frequency == Frequency.minutely) {
    return currentStart._addMinutes(
      rrule.actualInterval,
      wereDatesFiltered,
      rrule.byHours,
      rrule.byMinutes,
    );
  } else if (rrule.frequency == Frequency.secondly) {
    return currentStart._addSeconds(
      rrule.actualInterval,
      wereDatesFiltered,
      rrule.byHours,
      rrule.byMinutes,
      rrule.bySeconds,
    );
  }

  throw ArgumentError('Unknown frequency: ${rrule.frequency}.');
}

extension _FrequencyIntervalCalculation on DateTime {
  DateTime _addYears(int years) => plusYears(years);

  DateTime _addMonths(int months) => plusMonths(months);

  DateTime _addWeeks(int weeks) {
    final surplusDays = (weekday - DateTime.monday) % DateTime.daysPerWeek;
    return this + weeks.weeks - surplusDays.days;
  }

  DateTime _addDays(int days) => this + days.days;

  DateTime _addHours(int hours, bool wereDatesFiltered, Set<int> byHours) {
    var newValue = this;
    if (wereDatesFiltered) {
      // Jump to one iteration before next day.
      final timeToLastHour = Duration.hoursPerDay - 1 - newValue.hour;
      final hoursToLastIterationOfDay =
          (timeToLastHour / hours).floor() * hours;
      newValue += hoursToLastIterationOfDay.hours;
    }

    // ignore: literal_only_boolean_expressions
    while (true) {
      newValue += hours.hours;

      if (byHours.isEmpty || byHours.contains(newValue.hour)) break;
    }
    return newValue;
  }

  DateTime _addMinutes(
    int minutes,
    bool wereDatesFiltered,
    Set<int> byHours,
    Set<int> byMinutes,
  ) {
    var newValue = this;
    if (wereDatesFiltered) {
      // Jump to one iteration before next day.
      final timeToLastMinute = Duration.minutesPerDay -
          1 -
          newValue.hour * Duration.minutesPerHour -
          newValue.minute;
      final minutesToLastIterationOfDay =
          (timeToLastMinute / minutes).floor() * minutes;
      newValue += minutesToLastIterationOfDay.minutes;
    }

    // ignore: literal_only_boolean_expressions
    while (true) {
      final hours = minutes ~/ Duration.minutesPerHour;
      final minutesWithoutHours = minutes % Duration.minutesPerHour;
      if (hours > 0) {
        newValue = newValue._addHours(hours, wereDatesFiltered, byHours);
      }
      newValue += minutesWithoutHours.minutes;

      if ((byHours.isEmpty || byHours.contains(newValue.hour)) &&
          (byMinutes.isEmpty || byMinutes.contains(newValue.minute))) {
        break;
      }
    }
    return newValue;
  }

  DateTime _addSeconds(
    int seconds,
    bool wereDatesFiltered,
    Set<int> byHours,
    Set<int> byMinutes,
    Set<int> bySeconds,
  ) {
    var newValue = this;
    if (wereDatesFiltered) {
      // Jump to one iteration before next day.
      final timeToLastMinute = Duration.secondsPerDay -
          1 -
          newValue.hour * Duration.secondsPerHour -
          newValue.minute * Duration.secondsPerMinute -
          newValue.second;
      final secondsToLastIterationOfDay =
          (timeToLastMinute / seconds).floor() * seconds;
      newValue += secondsToLastIterationOfDay.seconds;
    }

    // ignore: literal_only_boolean_expressions
    while (true) {
      final minutes = seconds ~/ Duration.secondsPerMinute;
      final secondsWithoutMinutes = minutes % Duration.secondsPerMinute;
      if (minutes > 0) {
        newValue = newValue._addMinutes(
          minutes,
          wereDatesFiltered,
          byHours,
          byMinutes,
        );
      }
      newValue += secondsWithoutMinutes.seconds;

      if ((byHours.isEmpty || byHours.contains(newValue.hour)) &&
          (byMinutes.isEmpty || byMinutes.contains(newValue.minute)) &&
          (bySeconds.isEmpty || bySeconds.contains(newValue.second))) {
        break;
      }
    }
    return newValue;
  }
}
