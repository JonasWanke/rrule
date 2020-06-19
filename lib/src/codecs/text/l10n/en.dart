import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import '../../../frequency.dart';
import 'l10n.dart';

@immutable
class RruleL10nEn extends RruleL10n {
  const RruleL10nEn(Culture culture) : super(culture);

  static Future<RruleL10nEn> withDefaultCulture() async {
    return RruleL10nEn(await Cultures.getCulture('en'));
  }

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
  String inMonths(String months) => 'in $months';

  @override
  String onDaysOfWeek(String days) => 'on $days';
  @override
  String get weekdaysString => 'weekdays';
  @override
  String nthDaysOfWeek(int occurrence, String daysOfWeek) {
    if (occurrence == null) {
      return daysOfWeek;
    } else {
      return 'the ${ordinal(occurrence)} $daysOfWeek';
    }
  }

  @override
  String onDaysOfMonth(
    String days, {
    DaysOfVariant variant = DaysOfVariant.dayAndFrequency,
    bool useAlsoVariant = false,
  }) {
    final prefix = useAlsoVariant ? 'that are also the' : 'on the';
    final suffix = {
      DaysOfVariant.simple: '',
      DaysOfVariant.day: ' day',
      DaysOfVariant.dayAndFrequency: ' day of the month',
    }[variant];
    return '$prefix $days$suffix';
  }

  @override
  String onDaysOfYear(String days, {bool useAlsoVariant = false}) {
    final prefix = useAlsoVariant ? 'that are also the' : 'on the';
    return '$prefix $days day of the year';
  }

  String _plural(
    int count, {
    @required String one,
    @required String other,
  }) {
    assert(one != null);
    assert(other != null);

    return count == 1 ? one : other;
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
