import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../../../frequency.dart';
import 'l10n.dart';

@immutable
class RruleL10nNl extends RruleL10n {
  const RruleL10nNl._();


  static Future<RruleL10nNl> create() async {
    await initializeDateFormatting('nl');
    return const RruleL10nNl._();
  }

  @override
  String get locale => 'nl';

  @override
  String frequencyInterval(Frequency frequency, int interval) {
    String plurals({required String one, required String singular}) {
      return switch (interval) {
        1 => one,
        2 => 'Om de twee $singular',
        _ => 'Om de $interval ${singular}s',
      };
    }

    return {
      Frequency.secondly: plurals(one: 'Secondelijks', singular: 'seconde'),
      Frequency.minutely: plurals(one: 'Minuutlijks', singular: 'minuut'),
      Frequency.hourly: plurals(one: 'Uurlijks', singular: 'uur'),
      Frequency.daily: plurals(one: 'Dagelijks', singular: 'dag'),
      Frequency.weekly: plurals(one: 'Wekelijks', singular: 'week'),
      Frequency.monthly: plurals(one: 'Maandelijks', singular: 'maand'),
      Frequency.yearly: plurals(one: 'Jaarlijks', singular: 'jaar'),
    }[frequency]!;
  }

  @override
  String until(DateTime until, Frequency frequency) {
    final untilString = formatWithIntl(
      () => DateFormat('EEEE d MMMM yyyy \'om\' H:i \'uur\'', 'nl').format(until),
    );
    return ', tot $untilString';
  }

  @override
  String count(int count) {
    return switch (count) {
      1 => ', één keer',
      2 => ', twee keer',
      _ => ', $count keer',
    };
  }

  @override
  String onInstances(String instances) => 'op de $instances';

  @override
  String inMonths(String months, {InOnVariant variant = InOnVariant.simple}) =>
      '${_inVariant(variant)} $months';

  @override
  String inWeeks(String weeks, {InOnVariant variant = InOnVariant.simple}) =>
      '${_inVariant(variant)} week $weeks';

  String _inVariant(InOnVariant variant) {
    return switch (variant) {
      InOnVariant.simple => 'in',
      InOnVariant.also => 'die ook in',
      InOnVariant.instanceOf => 'van',
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
        frequency == DaysOfWeekFrequency.monthly ? 'maand' : 'jaar';
    final suffix = indicateFrequency ? ' van de $frequencyString' : '';
    return '${_onVariant(variant)} $days$suffix';
  }

  @override
  String? get weekdaysString => 'weekdagen';
  @override
  String get everyXDaysOfWeekPrefix => 'elke ';
  @override
  String nthDaysOfWeek(Iterable<int> occurrences, String daysOfWeek) {
    if (occurrences.isEmpty) return daysOfWeek;

    final ordinals = list(
      occurrences.map(ordinal).toList(),
      ListCombination.conjunctiveShort,
    );
    return 'de $ordinals $daysOfWeek';
  }

  @override
  String onDaysOfMonth(
    String days, {
    DaysOfVariant daysOfVariant = DaysOfVariant.dayAndFrequency,
    InOnVariant variant = InOnVariant.simple,
  }) {
    final suffix = {
      DaysOfVariant.simple: '',
      DaysOfVariant.day: ' dag',
      DaysOfVariant.dayAndFrequency: ' dag van de maand',
    }[daysOfVariant];
    return '${_onVariant(variant)} de $days$suffix';
  }

  @override
  String onDaysOfYear(
    String days, {
    InOnVariant variant = InOnVariant.simple,
  }) =>
      '${_onVariant(variant)} de $days dag van het jaar';

  String _onVariant(InOnVariant variant) {
    return switch (variant) {
      InOnVariant.simple => 'op',
      InOnVariant.also => 'die ook op',
      InOnVariant.instanceOf => 'van',
    };
  }

  @override
  String list(List<String> items, ListCombination combination) {
    final (two, end) = switch (combination) {
      ListCombination.conjunctiveShort => (' & ', ' & '),
      ListCombination.conjunctiveLong => (' en ', ', en '),
      ListCombination.disjunctive => (' of ', ', of '),
    };
    return RruleL10n.defaultList(items, two: two, end: end);
  }

  @override
  String ordinal(int number) {
    assert(number != 0);
    if (number == -1) return 'laatste';

    final n = number.abs();
    String string;
    if (n % 10 == 1 && n % 100 != 11) {
      string = '${n}ste';
    } else if (n % 10 == 2 && n % 100 != 12) {
      string = '${n}de';
    } else if (n % 10 == 3 && n % 100 != 13) {
      string = '${n}de';
    } else {
      string = '${n}de';
    }

    return number < 0 ? '$string tot laatste' : string;
  }
}
