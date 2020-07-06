import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import '../../../frequency.dart';
import 'l10n.dart';

@immutable
class RruleL10nEn extends RruleL10n {
  const RruleL10nEn._(Culture culture) : super(culture);

  static Future<RruleL10nEn> create() async =>
      RruleL10nEn._(await Cultures.getCulture('en'));

  @override
  String frequencyInterval(Frequency frequency, int interval) {
    String plurals({String one, String singular}) {
      switch (interval) {
        case 1:
          return one;
        case 2:
          return 'Every other $singular';
        default:
          return 'Every $interval ${singular}s';
      }
    }

    return {
      Frequency.secondly: plurals(one: 'Secondly', singular: 'second'),
      Frequency.minutely: plurals(one: 'Minutely', singular: 'minute'),
      Frequency.hourly: plurals(one: 'Hourly', singular: 'hour'),
      Frequency.daily: plurals(one: 'Daily', singular: 'day'),
      Frequency.weekly: plurals(one: 'Weekly', singular: 'week'),
      Frequency.monthly: plurals(one: 'Monthly', singular: 'month'),
      Frequency.yearly: plurals(one: 'Annually', singular: 'year'),
    }[frequency];
  }

  @override
  String until(LocalDateTime until) =>
      ', until ${until.toString('F', culture)}';

  @override
  String count(int count) {
    switch (count) {
      case 1:
        return ', once';
      case 2:
        return ', twice';
      default:
        return ', $count times';
    }
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
    switch (variant) {
      case InOnVariant.simple:
        return 'in';
      case InOnVariant.also:
        return 'that are also in';
      case InOnVariant.instanceOf:
        return 'of';
      default:
        assert(false);
        return null;
    }
  }

  @override
  String onDaysOfWeek(
    String days, {
    bool indicateFrequency = false,
    DaysOfWeekFrequency frequency = DaysOfWeekFrequency.monthly,
    InOnVariant variant = InOnVariant.simple,
  }) {
    assert(variant != InOnVariant.also);

    final frequencyString =
        frequency == DaysOfWeekFrequency.monthly ? 'month' : 'year';
    final suffix = indicateFrequency ? ' of the $frequencyString' : '';
    return '${_onVariant(variant)} $days$suffix';
  }

  @override
  String get weekdaysString => 'weekdays';
  @override
  String get everyXDaysOfWeekPrefix => 'every ';
  @override
  String nthDaysOfWeek(Iterable<int> occurrences, String daysOfWeek) {
    if (occurrences.isEmpty) {
      return daysOfWeek;
    } else {
      final ordinals = list(
          occurrences.map(ordinal).toList(), ListCombination.conjunctiveShort);
      return 'the $ordinals $daysOfWeek';
    }
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
    switch (variant) {
      case InOnVariant.simple:
        return 'on';
      case InOnVariant.also:
        return 'that are also';
      case InOnVariant.instanceOf:
        return 'of';
      default:
        assert(false);
        return null;
    }
  }

  @override
  String list(List<String> items, ListCombination combination) {
    assert(items != null);
    assert(combination != null);

    return RruleL10n.defaultList(
      items,
      two: {
        ListCombination.conjunctiveShort: ' & ',
        ListCombination.conjunctiveLong: ' and ',
        ListCombination.disjunctive: ' or ',
      }[combination],
      end: {
        ListCombination.conjunctiveShort: ' & ',
        ListCombination.conjunctiveLong: ', and ',
        ListCombination.disjunctive: ', or ',
      }[combination],
    );
  }

  @override
  String ordinal(int number) {
    assert(number != 0);
    if (number == -1) {
      return 'last';
    }

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
