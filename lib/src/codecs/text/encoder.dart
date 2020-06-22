import 'dart:convert';

import 'package:basics/basics.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import '../../by_week_day_entry.dart';
import '../../frequency.dart';
import '../../recurrence_rule.dart';
import 'l10n/l10n.dart';

@immutable
class RecurrenceRuleToTextEncoder extends Converter<RecurrenceRule, String> {
  const RecurrenceRuleToTextEncoder(this.l10n) : assert(l10n != null);

  final RruleL10n l10n;

  @override
  String convert(RecurrenceRule input) {
    final frequencyIntervalString =
        l10n.frequencyInterval(input.frequency, input.actualInterval);
    final output = StringBuffer(frequencyIntervalString);

    if (input.frequency > Frequency.daily) {
      // _convertSubDaily(input, output);
    } else {
      if (input.frequency == Frequency.daily) {
        _convertDaily(input, output);
      } else if (input.frequency == Frequency.weekly) {
        _convertWeekly(input, output);
      } else if (input.frequency == Frequency.monthly) {
        _convertMonthly(input, output);
      } else if (input.frequency == Frequency.yearly) {
        _convertYearly(input, output);
      } else {
        throw UnsupportedError('Unsupported frequency: ${input.frequency}');
      }
    }

    if (input.until != null) {
      output.write(l10n.until(input.until));
    } else if (input.count != null) {
      output.write(l10n.count(input.count));
    }

    return output.toString();
  }

  void _convertDaily(RecurrenceRule input, StringBuffer output) {
    // [in January – March, August & September]
    output.add(_formatByMonths(input));

    // [byWeekDays]:
    //   [on (Monday, Wednesday – Friday & Sunday | weekdays [& Sunday])]
    // [byMonthDays]:
    //   [on the 1st and last day of the month]
    // byWeekDays, byMonthDays:
    //   on (Monday, Wednesday – Friday & Sunday | weekdays [& Sunday])
    //   that are also the 1st & 3rd-to-last – last day of the month
    assert(input.byWeekDays.noneHasOccurrence);
    output
      ..add(_formatByWeekDays(input))
      ..add(_formatByMonthDays(
        input,
        useAlsoVariant: input.hasByWeekDays,
      ));
  }

  void _convertWeekly(RecurrenceRule input, StringBuffer output) {
    // [in January – March, August & September]
    output.add(_formatByMonths(input));

    // [byWeekDays]:
    //   [on (Monday, Wednesday – Friday & Sunday | a weekday [& Sunday])]
    assert(input.byWeekDays.noneHasOccurrence);
    output.add(_formatByWeekDays(input));
  }

  void _convertMonthly(RecurrenceRule input, StringBuffer output) {
    // [in January – March, August & September]
    output.add(_formatByMonths(input));

    // [byWeekDays]:
    //   [on (Monday, Wednesday – Friday & Sunday | weekdays [& Sunday])]
    // [byMonthDays]:
    //   [on the 1st and last day of the month]
    // byWeekDays, byMonthDays:
    //   on (Monday, Wednesday – Friday & Sunday | weekdays [& Sunday])
    //   that are also the 1st or 3rd-to-last – last day of the month
    output
      ..add(_formatByWeekDays(
        input,
        frequency: DaysOfWeekFrequency.monthly,
        indicateFrequency: false,
      ))
      ..add(_formatByMonthDays(
        input,
        variant: input.byWeekDays.anyHasOccurrence
            ? DaysOfVariant.dayAndFrequency
            : input.byMonthDays.any((d) => d < 0)
                ? DaysOfVariant.day
                : DaysOfVariant.simple,
        useAlsoVariant: input.hasByWeekDays,
        combination: input.hasByWeekDays
            ? ListCombination.disjunctive
            : ListCombination.conjunctiveShort,
      ));
  }

  void _convertYearly(RecurrenceRule input, StringBuffer output) {
    // Order of by-attributes: byWeekDays, byMonthDays, byYearDays, byWeeks, byMonths

    final startWithByWeekDays = input.hasByWeekDays;
    if (startWithByWeekDays) {
      final frequency = input.hasByYearDays || input.hasByMonthDays
          ? DaysOfWeekFrequency.yearly
          : input.hasByMonths
              ? DaysOfWeekFrequency.monthly
              : DaysOfWeekFrequency.yearly;
      output.add(_formatByWeekDays(input, frequency: frequency));
    }

    final startWithByMonthDays = input.hasByMonthDays && !startWithByWeekDays;
    if (startWithByMonthDays) {
      output.add(_formatByMonthDays(input));
    }

    final startWithByYearDays =
        input.hasByYearDays && !startWithByWeekDays && !startWithByMonthDays;
    if (startWithByYearDays) {
      output.add(_formatByYearDays(input));
    }

    final startWithByWeeks = input.hasByWeeks &&
        !startWithByWeekDays &&
        !startWithByMonthDays &&
        !startWithByYearDays;
    if (startWithByWeeks) {
      output.add(_formatByWeeks(input));
    }

    final startWithByMonths = input.hasByMonths &&
        !startWithByWeekDays &&
        !startWithByMonthDays &&
        !startWithByYearDays &&
        !startWithByWeeks;
    if (startWithByMonths) {
      output.add(_formatByMonths(input));
    }

    final daysOnlyByWeek =
        input.hasByWeekDays && !input.hasByMonthDays && !input.hasByYearDays;
    final daysOnlyByMonth =
        !input.hasByWeekDays && input.hasByMonthDays && !input.hasByYearDays;

    final appendByWeeksDirectly = daysOnlyByWeek && input.hasByWeeks;
    final appendByMonthsDirectly = (daysOnlyByWeek || daysOnlyByMonth) &&
        !input.hasByWeeks &&
        input.hasByMonths;

    if (appendByWeeksDirectly) {
      output.add(_formatByWeeks(
        input,
        combination: ListCombination.conjunctiveShort,
      ));
    }
    if (appendByMonthsDirectly) {
      assert(!appendByWeeksDirectly);
      output.add(_formatByMonths(
        input,
        combination: ListCombination.conjunctiveShort,
      ));
    }

    final limits = [
      if (!startWithByMonthDays)
        _formatByMonthDays(
          input,
          useAlsoVariant: true,
          combination: ListCombination.disjunctive,
        ),
      if (!startWithByYearDays)
        _formatByYearDays(
          input,
          useAlsoVariant: true,
          combination: ListCombination.disjunctive,
        ),
      if (!startWithByWeeks && !appendByWeeksDirectly)
        _formatByWeeks(
          input,
          useAlsoVariant: true,
          combination: ListCombination.disjunctive,
        ),
      if (!startWithByMonths && !appendByMonthsDirectly)
        _formatByMonths(
          input,
          useAlsoVariant: true,
          combination: ListCombination.disjunctive,
        ),
    ].where((l) => l != null).toList();
    if (limits.isNotEmpty) {
      output.add(l10n.list(limits, ListCombination.conjunctiveLong));
    }
  }

  String _formatByMonths(
    RecurrenceRule input, {
    bool useAlsoVariant = false,
    ListCombination combination = ListCombination.conjunctiveShort,
  }) {
    if (input.byMonths.isEmpty) {
      return null;
    }

    return l10n.inMonths(
      input.byMonths.formattedForUser(
        l10n,
        map: l10n.month,
        combination: combination,
      ),
      useAlsoVariant: useAlsoVariant,
    );
  }

  String _formatByWeeks(
    RecurrenceRule input, {
    bool useAlsoVariant = false,
    ListCombination combination = ListCombination.conjunctiveShort,
  }) {
    if (input.byWeeks.isEmpty) {
      return null;
    }

    return l10n.inWeeks(
      input.byWeeks.formattedForUser(l10n, combination: combination),
      useAlsoVariant: useAlsoVariant,
    );
  }

  String _formatByYearDays(
    RecurrenceRule input, {
    bool useAlsoVariant = false,
    ListCombination combination = ListCombination.conjunctiveShort,
  }) {
    if (input.byYearDays.isEmpty) {
      return null;
    }

    return l10n.onDaysOfYear(
      input.byYearDays.formattedForUser(l10n, combination: combination),
      useAlsoVariant: useAlsoVariant,
    );
  }

  String _formatByMonthDays(
    RecurrenceRule input, {
    DaysOfVariant variant = DaysOfVariant.dayAndFrequency,
    bool useAlsoVariant = false,
    ListCombination combination = ListCombination.conjunctiveShort,
  }) {
    if (input.byMonthDays.isEmpty) {
      return null;
    }

    return l10n.onDaysOfMonth(
      input.byMonthDays.formattedForUser(l10n, combination: combination),
      variant: variant,
      useAlsoVariant: useAlsoVariant,
    );
  }

  String _formatByWeekDays(
    RecurrenceRule input, {
    DaysOfWeekFrequency frequency,
    bool indicateFrequency,
  }) {
    if (input.byWeekDays.isEmpty) {
      return null;
    }

    return l10n.onDaysOfWeek(
      input.byWeekDays.formattedForUser(
        l10n,
        addEveryPrefix: frequency != null,
        weekStart: input.actualWeekStart,
      ),
      indicateFrequency: indicateFrequency ?? input.byWeekDays.anyHasOccurrence,
      frequency: frequency,
    );
  }
}

extension on StringBuffer {
  void add(Object obj) {
    if (obj == null) {
      return;
    }

    write(' ');
    write(obj);
  }
}

typedef _ItemToString<T> = String Function(T item);

extension<T> on Iterable<T> {
  /// Creates a list with all items sorted by their key like
  /// `0, 1, 2, 3, …, -3, -2, -1`.
  List<T> sortedForUserGeneral({@required int Function(T item) key}) {
    final nonNegative = where((e) => key(e) >= 0).toList()..sortBy(key);
    final negative = where((e) => key(e) < 0).toList()..sortBy(key);
    return nonNegative + negative;
  }
}

extension on Iterable<int> {
  String formattedForUser(
    RruleL10n l10n, {
    _ItemToString<int> map,
    ListCombination combination = ListCombination.conjunctiveShort,
  }) {
    assert(isNotEmpty);

    final raw = sortedForUser();
    final mapped = <String>[];
    for (var i = 0; i < raw.length; i++) {
      final startIndex = i;
      var current = raw[startIndex];
      while (raw.length > i + 1 && raw[i + 1] == current + 1) {
        i++;
        current = raw[i];
      }

      mapped._addIndividualOrCombined(
          l10n, raw, startIndex, i, map ?? l10n.ordinal);
    }

    return l10n.list(mapped, combination);
  }

  List<int> sortedForUser() => sortedForUserGeneral(key: (e) => e);
}

extension on Iterable<ByWeekDayEntry> {
  String occurrenceFreeFormattedForUser(
    RruleL10n l10n, {
    @required bool addEveryPrefix,
    @required DayOfWeek weekStart,
    ListCombination combination = ListCombination.conjunctiveShort,
  }) {
    assert(noneHasOccurrence);
    assert(isNotEmpty);

    // With [addEveryPrefix]:
    //   every Monday
    //   weekdays & every Sunday
    //   weekdays, every Saturday & Sunday

    final raw = map((e) => e.day).toList()
      ..sortBy((e) => (e.value - weekStart.value) % TimeConstants.daysPerWeek);

    final mapped = <String>[];

    final containsAllWeekdays = raw.containsAll(l10n.weekdays);
    if (containsAllWeekdays) {
      mapped.add(l10n.weekdaysString);
      raw.removeWhere((d) => l10n.weekdays.contains(d));
    }

    var addedEveryPrefix = false;
    for (var i = 0; i < raw.length; i++) {
      final startIndex = i;
      final startValue = raw[startIndex];

      var current = startValue;
      while (raw.length > i + 1 &&
          raw[i + 1].value == (current.value + 1) % TimeConstants.daysPerWeek) {
        i++;
        current = raw[i];
      }

      mapped._addIndividualOrCombined(
        l10n,
        raw,
        startIndex,
        i,
        (day) {
          var string = l10n.dayOfWeek(day);
          if (addEveryPrefix && !addedEveryPrefix && day == startValue) {
            string = '${l10n.everyXDaysOfWeekPrefix}$string';
            addedEveryPrefix = true;
          }
          return string;
        },
      );
    }

    return l10n.list(mapped, combination);
  }

  String formattedForUser(
    RruleL10n l10n, {
    @required bool addEveryPrefix,
    @required DayOfWeek weekStart,
  }) {
    assert(isNotEmpty);

    final grouped = groupBy<ByWeekDayEntry, int>(this, (e) => e.occurrence)
        .entries
        .sortedForUserGeneral(key: (e) => e.value.first.occurrence ?? 0);
    final strings = grouped.map((entry) {
      final hasOccurrence = entry.key != null;
      final daysOfWeek = entry.value
          .map((e) => ByWeekDayEntry(e.day))
          .occurrenceFreeFormattedForUser(
            l10n,
            addEveryPrefix: addEveryPrefix && !hasOccurrence,
            weekStart: weekStart,
            combination: ListCombination.conjunctiveShort,
          );
      return hasOccurrence
          ? l10n.nthDaysOfWeek(entry.key, daysOfWeek)
          : daysOfWeek;
    }).toList();
    return l10n.list(strings, ListCombination.conjunctiveLong);
  }
}

extension on List<String> {
  void _addIndividualOrCombined<T>(
    RruleL10n l10n,
    List<T> source,
    int startIndex,
    int endIndex,
    _ItemToString<T> map,
  ) {
    assert(startIndex <= endIndex);

    switch (endIndex - startIndex) {
      case 0:
        add(map(source[startIndex]));
        return;
      case 1:
        add(map(source[startIndex]));
        add(map(source[endIndex]));
        return;
      default:
        add(l10n.range(map(source[startIndex]), map(source[endIndex])));
        return;
    }
  }
}
