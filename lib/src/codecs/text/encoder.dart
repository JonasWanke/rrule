import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../../by_week_day_entry.dart';
import '../../frequency.dart';
import '../../recurrence_rule.dart';
import '../../utils.dart';
import 'l10n/l10n.dart';

@immutable
class RecurrenceRuleToTextEncoder extends Converter<RecurrenceRule, String> {
  const RecurrenceRuleToTextEncoder(this.l10n, {this.untilDateFormat});

  final RruleL10n l10n;
  final DateFormat? untilDateFormat;

  @override
  String convert(RecurrenceRule input) {
    input = _normalize(input);

    final frequencyIntervalString =
        l10n.frequencyInterval(input.frequency, input.actualInterval);
    final output = StringBuffer(frequencyIntervalString);

    if (input.frequency > Frequency.daily) {
      assert(
        !input.hasBySetPositions &&
            !input.hasBySeconds &&
            !input.hasByMinutes &&
            !input.hasByHours &&
            !input.hasByWeekDays &&
            !input.hasByMonthDays &&
            !input.hasByYearDays &&
            !input.hasByWeeks &&
            !input.hasByMonths,
        'Frequencies > daily with any `by`-parts are not supported yet in '
        'toText().',
      );
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
      output.write(l10n.until(input.until!, input.frequency, dateFormat: untilDateFormat));
    } else if (input.count != null) {
      output.write(l10n.count(input.count!));
    }

    return output.toString();
  }

  RecurrenceRule _normalize(RecurrenceRule input) {
    // Incomplete!
    input = input.copyWith(clearInterval: input.interval == 1);

    if (input.frequency == Frequency.monthly) {
      final byEveryWeekDay = [
        for (final weekDay in DateTime.monday.rangeTo(DateTime.sunday))
          ByWeekDayEntry(weekDay),
      ];
      if (!input.hasBySeconds &&
          !input.hasByMinutes &&
          !input.hasByHours &&
          const DeepCollectionEquality.unordered()
              .equals(input.byWeekDays, byEveryWeekDay) &&
          !input.hasByMonthDays &&
          !input.hasByYearDays &&
          !input.hasByWeeks &&
          !input.hasByMonths &&
          input.hasBySetPositions) {
        input = input.copyWith(
          byWeekDays: [],
          byMonthDays: input.bySetPositions,
          bySetPositions: [],
        );
      }
    }
    return input;
  }

  void _convertDaily(RecurrenceRule input, StringBuffer output) {
    assert(input.byWeekDays.noneHasOccurrence);

    output
      // [in January – March, August & September]
      ..add(_formatByMonths(input))
      // [on the 1st & 2nd-to-last instance]
      ..add(_formatBySetPositions(input))
      // [byWeekDays]:
      //   [on (Monday, Wednesday – Friday & Sunday | weekdays [& Sunday])]
      // [byMonthDays]:
      //   [on the 1st and last day of the month]
      // byWeekDays, byMonthDays:
      //   on (Monday, Wednesday – Friday & Sunday | weekdays [& Sunday])
      //   that are also the 1st & 3rd-to-last – last day of the month
      ..add(
        _formatByWeekDays(
          input,
          variant: input.hasBySetPositions
              ? InOnVariant.instanceOf
              : InOnVariant.simple,
        ),
      )
      ..add(
        _formatByMonthDays(
          input,
          variant: input.hasByWeekDays
              ? InOnVariant.also
              : input.hasBySetPositions
                  ? InOnVariant.instanceOf
                  : InOnVariant.simple,
          combination: input.hasByWeekDays
              ? ListCombination.disjunctive
              : ListCombination.conjunctiveShort,
        ),
      );
  }

  void _convertWeekly(RecurrenceRule input, StringBuffer output) {
    assert(input.byWeekDays.noneHasOccurrence);
    output
      // [in January – March, August & September]
      ..add(_formatByMonths(input))
      // [on the 1st & 2nd-to-last instance]
      ..add(_formatBySetPositions(input))
      // [byWeekDays]:
      //   [on (Monday, Wednesday – Friday & Sunday | a weekday [& Sunday])]
      ..add(
        _formatByWeekDays(
          input,
          variant: input.hasBySetPositions
              ? InOnVariant.instanceOf
              : InOnVariant.simple,
        ),
      );
  }

  void _convertMonthly(RecurrenceRule input, StringBuffer output) {
    output
      // [in January – March, August & September]
      ..add(_formatByMonths(input))
      // [on the 1st & 2nd-to-last instance]
      ..add(_formatBySetPositions(input))
      // [byWeekDays]:
      //   [on (Monday, Wednesday – Friday & Sunday | weekdays [& Sunday])]
      // [byMonthDays]:
      //   [on the 1st and last day of the month]
      // byWeekDays, byMonthDays:
      //   on (Monday, Wednesday – Friday & Sunday | weekdays [& Sunday])
      //   that are also the 1st or 3rd-to-last – last day of the month
      ..add(
        _formatByWeekDays(
          input,
          frequency: DaysOfWeekFrequency.monthly,
          indicateFrequency: false,
          variant: input.hasBySetPositions
              ? InOnVariant.instanceOf
              : InOnVariant.simple,
        ),
      )
      ..add(
        _formatByMonthDays(
          input,
          daysOfVariant: input.byWeekDays.anyHasOccurrence
              ? DaysOfVariant.dayAndFrequency
              : input.byMonthDays.any((d) => d < 0)
                  ? DaysOfVariant.day
                  : DaysOfVariant.simple,
          variant: input.hasByWeekDays
              ? InOnVariant.also
              : input.hasBySetPositions
                  ? InOnVariant.instanceOf
                  : InOnVariant.simple,
          combination: input.hasByWeekDays
              ? ListCombination.disjunctive
              : ListCombination.conjunctiveShort,
        ),
      );
  }

  void _convertYearly(RecurrenceRule input, StringBuffer output) {
    output.add(_formatBySetPositions(input));

    // Order of remaining by-attributes:
    // byWeekDays, byMonthDays, byYearDays, byWeeks, byMonths

    final firstVariant =
        input.hasBySetPositions ? InOnVariant.instanceOf : InOnVariant.simple;

    final startWithByWeekDays = input.hasByWeekDays;
    if (startWithByWeekDays) {
      final frequency = input.hasByYearDays || input.hasByMonthDays
          ? DaysOfWeekFrequency.yearly
          : input.hasByMonths
              ? DaysOfWeekFrequency.monthly
              : DaysOfWeekFrequency.yearly;
      output.add(
        _formatByWeekDays(
          input,
          frequency: frequency,
          variant: firstVariant,
        ),
      );
    }

    final startWithByMonthDays = input.hasByMonthDays && !startWithByWeekDays;
    if (startWithByMonthDays) {
      output.add(_formatByMonthDays(input, variant: firstVariant));
    }

    final startWithByYearDays =
        input.hasByYearDays && !startWithByWeekDays && !startWithByMonthDays;
    if (startWithByYearDays) {
      output.add(_formatByYearDays(input, variant: firstVariant));
    }

    final startWithByWeeks = input.hasByWeeks &&
        !startWithByWeekDays &&
        !startWithByMonthDays &&
        !startWithByYearDays;
    if (startWithByWeeks) {
      output.add(_formatByWeeks(input, variant: firstVariant));
    }

    final startWithByMonths = input.hasByMonths &&
        !startWithByWeekDays &&
        !startWithByMonthDays &&
        !startWithByYearDays &&
        !startWithByWeeks;
    if (startWithByMonths) {
      output.add(_formatByMonths(input, variant: firstVariant));
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
      output.add(_formatByWeeks(input));
    }
    if (appendByMonthsDirectly) {
      assert(!appendByWeeksDirectly);
      output.add(_formatByMonths(input));
    }

    final limits = [
      if (!startWithByMonthDays)
        _formatByMonthDays(
          input,
          variant: InOnVariant.also,
          combination: ListCombination.disjunctive,
        ),
      if (!startWithByYearDays)
        _formatByYearDays(
          input,
          variant: InOnVariant.also,
          combination: ListCombination.disjunctive,
        ),
      if (!startWithByWeeks && !appendByWeeksDirectly)
        _formatByWeeks(
          input,
          variant: InOnVariant.also,
          combination: ListCombination.disjunctive,
        ),
      if (!startWithByMonths && !appendByMonthsDirectly)
        _formatByMonths(
          input,
          variant: InOnVariant.also,
          combination: ListCombination.disjunctive,
        ),
    ].nonNulls.toList();
    if (limits.isNotEmpty) {
      output.add(l10n.list(limits, ListCombination.conjunctiveLong));
    }
  }

  String? _formatBySetPositions(RecurrenceRule input) {
    if (input.bySetPositions.isEmpty) return null;

    return l10n.onInstances(input.bySetPositions.formattedForUser(l10n));
  }

  String? _formatByMonths(
    RecurrenceRule input, {
    InOnVariant variant = InOnVariant.simple,
    ListCombination combination = ListCombination.conjunctiveShort,
  }) {
    if (input.byMonths.isEmpty) return null;

    return l10n.inMonths(
      input.byMonths.formattedForUser(
        l10n,
        map: l10n.month,
        combination: combination,
      ),
      variant: variant,
    );
  }

  String? _formatByWeeks(
    RecurrenceRule input, {
    InOnVariant variant = InOnVariant.simple,
    ListCombination combination = ListCombination.conjunctiveShort,
  }) {
    if (input.byWeeks.isEmpty) return null;

    return l10n.inWeeks(
      input.byWeeks.formattedForUser(l10n, combination: combination),
      variant: variant,
    );
  }

  String? _formatByYearDays(
    RecurrenceRule input, {
    InOnVariant variant = InOnVariant.simple,
    ListCombination combination = ListCombination.conjunctiveShort,
  }) {
    if (input.byYearDays.isEmpty) return null;

    return l10n.onDaysOfYear(
      input.byYearDays.formattedForUser(l10n, combination: combination),
      variant: variant,
    );
  }

  String? _formatByMonthDays(
    RecurrenceRule input, {
    DaysOfVariant daysOfVariant = DaysOfVariant.dayAndFrequency,
    InOnVariant variant = InOnVariant.simple,
    ListCombination combination = ListCombination.conjunctiveShort,
  }) {
    if (input.byMonthDays.isEmpty) return null;

    return l10n.onDaysOfMonth(
      input.byMonthDays.formattedForUser(l10n, combination: combination),
      daysOfVariant: daysOfVariant,
      variant: variant,
    );
  }

  String? _formatByWeekDays(
    RecurrenceRule input, {
    DaysOfWeekFrequency? frequency,
    bool? indicateFrequency,
    InOnVariant variant = InOnVariant.simple,
  }) {
    if (input.byWeekDays.isEmpty) return null;

    var addEveryPrefix = frequency != null;
    if (frequency == DaysOfWeekFrequency.yearly &&
        input.byWeekDays.noneHasOccurrence &&
        !input.hasByMonthDays &&
        !input.hasByYearDays &&
        input.byWeeks.length == 1 &&
        !input.hasByMonths) {
      addEveryPrefix = false;
    }

    return l10n.onDaysOfWeek(
      input.byWeekDays.formattedForUser(
        l10n,
        addEveryPrefix: addEveryPrefix,
        weekStart: input.actualWeekStart,
      ),
      indicateFrequency: indicateFrequency ?? input.byWeekDays.anyHasOccurrence,
      frequency: frequency,
      variant: variant,
    );
  }
}

extension on StringBuffer {
  void add(Object? obj) {
    if (obj == null) return;

    write(' ');
    write(obj);
  }
}

typedef _ItemToString<T> = String Function(T item);

extension<T> on Iterable<T> {
  /// Creates a list with all items sorted by their key like
  /// `0, 1, 2, 3, …, -3, -2, -1`.
  List<T> sortedForUserGeneral({required int Function(T item) key}) {
    final nonNegative = where((e) => key(e) >= 0).sortedBy<num>(key);
    final negative = where((e) => key(e) < 0).sortedBy<num>(key);
    return nonNegative + negative;
  }
}

extension on Iterable<int> {
  String formattedForUser(
    RruleL10n l10n, {
    _ItemToString<int>? map,
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
        l10n,
        raw,
        startIndex,
        i,
        map ?? l10n.ordinal,
      );
    }

    return l10n.list(mapped, combination);
  }

  List<int> sortedForUser() => sortedForUserGeneral(key: (e) => e);
}

extension on Iterable<ByWeekDayEntry> {
  String occurrenceFreeFormattedForUser(
    RruleL10n l10n, {
    required bool addEveryPrefix,
    required int weekStart,
  }) {
    assert(noneHasOccurrence);
    assert(isNotEmpty);
    assert(weekStart.isValidRruleDayOfWeek);

    // With [addEveryPrefix]:
    //   every Monday
    //   weekdays & every Sunday
    //   weekdays, every Saturday & Sunday

    final raw = map((e) => e.day)
        .sortedBy<num>((it) => (it - DateTime.monday) % DateTime.daysPerWeek);

    final mapped = <String>[];

    late final containsAllWeekdays = l10n.weekdays.every(raw.contains);
    if (l10n.weekdaysString != null && containsAllWeekdays) {
      mapped.add(l10n.weekdaysString!);
      raw.removeWhere((d) => l10n.weekdays.contains(d));
    }

    var addedEveryPrefix = false;
    for (var i = 0; i < raw.length; i++) {
      final startIndex = i;
      final startValue = raw[startIndex];

      var current = startValue;
      while (raw.length > i + 1 &&
          raw[i + 1] == (current + 1) % DateTime.daysPerWeek) {
        i++;
        current = raw[i];
      }

      mapped._addIndividualOrCombined<int>(
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

    return l10n.list(mapped, ListCombination.conjunctiveShort);
  }

  String formattedForUser(
    RruleL10n l10n, {
    required bool addEveryPrefix,
    required int weekStart,
  }) {
    assert(isNotEmpty);
    assert(weekStart.isValidRruleDayOfWeek);

    final grouped = groupBy<ByWeekDayEntry, int?>(this, (e) => e.occurrence)
        .entries
        .sortedForUserGeneral(key: (it) => it.value.first.occurrence ?? 0);

    if (anyHasOccurrence && map((it) => it.day).toSet().length == 1) {
      // Simplify this special case:
      // All entries contain the same day of the week.

      return l10n.nthDaysOfWeek(
        grouped.map((it) => it.key!),
        l10n.dayOfWeek(first.day),
      );
    }

    final strings = grouped.map((entry) {
      final hasOccurrence = entry.key != null;
      final daysOfWeek = entry.value
          .map((it) => ByWeekDayEntry(it.day))
          .occurrenceFreeFormattedForUser(
            l10n,
            addEveryPrefix: addEveryPrefix && !hasOccurrence,
            weekStart: weekStart,
          );
      return hasOccurrence
          ? l10n.nthDaysOfWeek(hasOccurrence ? [entry.key!] : [], daysOfWeek)
          : daysOfWeek;
    }).toList();

    // If no inner (short) conjunction is used, we can simply use the short
    // variant instead of the long one.
    final atMostOneWeekDayPerOccurrence = every((entry) {
      return where((e) => e.occurrence == entry.occurrence).length == 1;
    });

    return l10n.list(
      strings,
      atMostOneWeekDayPerOccurrence
          ? ListCombination.conjunctiveShort
          : ListCombination.conjunctiveLong,
    );
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
      case 1:
        add(map(source[startIndex]));
        add(map(source[endIndex]));
      default:
        add(l10n.range(map(source[startIndex]), map(source[endIndex])));
    }
  }
}
