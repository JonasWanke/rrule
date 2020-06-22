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
    _addByMonths(input, output);

    // [byWeekDays]:
    //   [on (Monday, Wednesday – Friday & Sunday | weekdays [& Sunday])]
    // [byMonthDays]:
    //   [on the 1st and last day of the month]
    // byWeekDays, byMonthDays:
    //   on (Monday, Wednesday – Friday & Sunday | weekdays [& Sunday])
    //   that are also the 1st & 3rd-to-last – last day of the month
    if (input.hasByWeekDays) {
      final daysString = input.byWeekDays
          .occurrenceFreeFormattedForUser(l10n, weekStart: input.weekStart);
      output.add(l10n.onDaysOfWeek(daysString));
    }

    output.add(_formatByMonthDays(
      input,
      useAlsoVariant: input.hasByWeekDays,
    ));
  }

  void _convertWeekly(RecurrenceRule input, StringBuffer output) {
    // [in January – March, August & September]
    _addByMonths(input, output);

    // [byWeekDays]:
    //   [on (Monday, Wednesday – Friday & Sunday | a weekday [& Sunday])]
    if (input.hasByWeekDays) {
      final daysString = input.byWeekDays.occurrenceFreeFormattedForUser(
        l10n,
        weekStart: input.actualWeekStart,
      );
      output.add(l10n.onDaysOfWeek(daysString));
    }
  }

  void _convertMonthly(RecurrenceRule input, StringBuffer output) {
    // [in January – March, August & September]
    _addByMonths(input, output);

    // [byWeekDays]:
    //   [on (Monday, Wednesday – Friday & Sunday | weekdays [& Sunday])]
    // [byMonthDays]:
    //   [on the 1st and last day of the month]
    // byWeekDays, byMonthDays:
    //   on (Monday, Wednesday – Friday & Sunday | weekdays [& Sunday])
    //   that are also the 1st or 3rd-to-last – last day of the month

    // Monthly on Monday – Wednesday, the 1st Thursday & Friday, the 2nd Thursday – Saturday, the 2nd-to-last Thursday, Friday & Sunday, and the last Thursday, Friday & Sunday that are also the 1st & 3rd-to-last – last day of the month
    if (input.hasByWeekDays) {
      final daysString = input.byWeekDays.formattedForUser(
        l10n,
        weekStart: input.actualWeekStart,
      );
      output.add(l10n.onDaysOfWeek(daysString));
    }

    output.add(_formatByMonthDays(
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

  void _addByMonths(RecurrenceRule input, StringBuffer output) {
    if (input.byMonths.isEmpty) {
      return;
    }

    final monthString = input.byMonths.formattedForUser(l10n, map: l10n.month);
    output.add(l10n.inMonths(monthString));
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

    final daysString =
        input.byMonthDays.formattedForUser(l10n, combination: combination);
    return l10n.onDaysOfMonth(
      daysString,
      variant: variant,
      useAlsoVariant: useAlsoVariant,
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
    @required DayOfWeek weekStart,
    ListCombination combination = ListCombination.conjunctiveShort,
  }) {
    assert(noneHasOccurrence);
    assert(isNotEmpty);

    final raw = map((e) => e.day).toList()
      ..sortBy((e) => (e.value - weekStart.value) % TimeConstants.daysPerWeek);

    final containsAllWeekdays = raw.containsAll(l10n.weekdays);
    var addedWeekdays = false;
    final mapped = <String>[];
    for (var i = 0; i < raw.length; i++) {
      final startIndex = i;
      final startValue = raw[startIndex];

      if (containsAllWeekdays && l10n.weekdays.contains(startValue)) {
        if (!addedWeekdays) {
          mapped.add(l10n.weekdaysString);
          addedWeekdays = true;
        }
        continue;
      }

      var current = startValue;
      while (raw.length > i + 1 &&
          raw[i + 1].value == (current.value + 1) % TimeConstants.daysPerWeek) {
        i++;
        current = raw[i];
      }

      mapped._addIndividualOrCombined(l10n, raw, startIndex, i, l10n.dayOfWeek);
    }

    return l10n.list(mapped, combination);
  }

  String formattedForUser(
    RruleL10n l10n, {
    @required DayOfWeek weekStart,
  }) {
    assert(isNotEmpty);

    final grouped = groupBy<ByWeekDayEntry, int>(this, (e) => e.occurrence)
        .entries
        .sortedForUserGeneral(key: (e) => e.value.first.occurrence ?? 0);
    final strings = grouped.map((entry) {
      final daysOfWeek = entry.value
          .map((e) => ByWeekDayEntry(e.day))
          .occurrenceFreeFormattedForUser(
            l10n,
            weekStart: weekStart,
            combination: ListCombination.conjunctiveShort,
          );
      return l10n.nthDaysOfWeek(entry.key, daysOfWeek);
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
