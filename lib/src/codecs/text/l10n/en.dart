import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../../../frequency.dart';
import 'l10n.dart';

@immutable
class RruleL10nEn extends RruleL10n {
  const RruleL10nEn._();

  static Future<RruleL10nEn> create() async {
    // TODO(JonasWanke): Move `initializeDateFormatting(…)` call to the
    // library's user
    await initializeDateFormatting('en');
    return const RruleL10nEn._();
  }

  @override
  String get locale => 'en_US';

  @override
  String frequencyInterval(Frequency frequency, int interval) {
    String plurals({required String one, required String singular}) {
      return switch (interval) {
        1 => one,
        2 => 'Every other $singular',
        _ => 'Every $interval ${singular}s',
      };
    }

    return {
      Frequency.secondly: plurals(one: 'Secondly', singular: 'second'),
      Frequency.minutely: plurals(one: 'Minutely', singular: 'minute'),
      Frequency.hourly: plurals(one: 'Hourly', singular: 'hour'),
      Frequency.daily: plurals(one: 'Daily', singular: 'day'),
      Frequency.weekly: plurals(one: 'Weekly', singular: 'week'),
      Frequency.monthly: plurals(one: 'Monthly', singular: 'month'),
      Frequency.yearly: plurals(one: 'Annually', singular: 'year'),
    }[frequency]!;
  }

  @override
  String until(DateTime until, Frequency frequency) {
    final untilString =
        formatWithIntl(() => DateFormat.yMMMMEEEEd().add_jms().format(until));
    return ', until $untilString';
  }

  @override
  String count(int count) {
    return switch (count) {
      1 => ', once',
      2 => ', twice',
      _ => ', $count times',
    };
  }

  @override
  String onInstances(String instances) => 'on the $instances instance';

  @override
  String inMonths(String months, {InOnVariant variant = InOnVariant.simple}) =>
      '${_inVariant(variant)} $months';

  @override
  String inWeeks(String weeks, {InOnVariant variant = InOnVariant.simple}) =>
      '${_inVariant(variant)} the $weeks week of the year';

  String _inVariant(InOnVariant variant) {
    return switch (variant) {
      InOnVariant.simple => 'in',
      InOnVariant.also => 'that are also in',
      InOnVariant.instanceOf => 'of',
    };
  }

  @override
  String onDaysOfWeek(
    String days, {
    bool indicateFrequency = false,
    DaysOfWeekFrequency? frequency = DaysOfWeekFrequency.monthly,
    InOnVariant variant = InOnVariant.simple,
  }) {
    assert(variant != InOnVariant.also);

    final frequencyString =
        frequency == DaysOfWeekFrequency.monthly ? 'month' : 'year';
    final suffix = indicateFrequency ? ' of the $frequencyString' : '';
    return '${_onVariant(variant)} $days$suffix';
  }

  @override
  String? get weekdaysString => 'weekdays';
  @override
  String get everyXDaysOfWeekPrefix => 'every ';
  @override
  String nthDaysOfWeek(Iterable<int> occurrences, String daysOfWeek) {
    if (occurrences.isEmpty) return daysOfWeek;

    final ordinals = list(
      occurrences.map(ordinal).toList(),
      ListCombination.conjunctiveShort,
    );
    return 'the $ordinals $daysOfWeek';
  }

  @override
  String onDaysOfMonth(
    String days, {
    DaysOfVariant daysOfVariant = DaysOfVariant.dayAndFrequency,
    InOnVariant variant = InOnVariant.simple,
  }) {
    final suffix = {
      DaysOfVariant.simple: '',
      DaysOfVariant.day: ' day',
      DaysOfVariant.dayAndFrequency: ' day of the month',
    }[daysOfVariant];
    return '${_onVariant(variant)} the $days$suffix';
  }

  @override
  String onDaysOfYear(
    String days, {
    InOnVariant variant = InOnVariant.simple,
  }) =>
      '${_onVariant(variant)} the $days day of the year';

  String _onVariant(InOnVariant variant) {
    return switch (variant) {
      InOnVariant.simple => 'on',
      InOnVariant.also => 'that are also',
      InOnVariant.instanceOf => 'of',
    };
  }

  @override
  String list(List<String> items, ListCombination combination) {
    final (two, end) = switch (combination) {
      ListCombination.conjunctiveShort => (' & ', ' & '),
      ListCombination.conjunctiveLong => (' and ', ', and '),
      ListCombination.disjunctive => (' or ', ', or '),
    };
    return RruleL10n.defaultList(items, two: two, end: end);
  }

  @override
  String ordinal(int number) {
    assert(number != 0);
    if (number == -1) return 'last';

    final n = number.abs();
    String string;
    if (n % 10 == 1 && n % 100 != 11) {
      string = '${n}st';
    } else if (n % 10 == 2 && n % 100 != 12) {
      string = '${n}nd';
    } else if (n % 10 == 3 && n % 100 != 13) {
      string = '${n}rd';
    } else {
      string = '${n}th';
    }

    return number < 0 ? '$string-to-last' : string;
  }
}
