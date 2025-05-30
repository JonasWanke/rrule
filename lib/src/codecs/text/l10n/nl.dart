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
    String plurals({required String one, required String plural}) {
      return switch (interval) {
        1 => one,
        2 => 'Om de twee $plural',
        _ => 'Om de $interval $plural',
      };
    }

    return {
      Frequency.secondly: plurals(one: 'Elke seconde', plural: 'seconden'),
      Frequency.minutely: plurals(one: 'Elke minuut', plural: 'minuten'),
      Frequency.hourly: plurals(one: 'Elk uur', plural: 'uren'),
      Frequency.daily: plurals(one: 'Dagelijks', plural: 'dagen'),
      Frequency.weekly: plurals(one: 'Wekelijks', plural: 'weken'),
      Frequency.monthly: plurals(one: 'Maandelijks', plural: 'maanden'),
      Frequency.yearly: plurals(one: 'Jaarlijks', plural: 'jaar'),
    }[frequency]!;
  }

  @override
  String until(DateTime until, Frequency frequency, {DateFormat? dateFormat}) {
    final untilString = formatWithIntl(() => 
      dateFormat?.format(until) ?? DateFormat("EEEE d MMMM yyyy 'om' H:mm 'uur'", 'nl').format(until)
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
  String inMonths(String months, {InOnVariant variant = InOnVariant.simple}) {
    final suffix = variant == InOnVariant.also ? ' vallen' : '';
    return '${_inVariant(variant)} $months$suffix';
  }

  @override
  String inWeeks(String weeks, {InOnVariant variant = InOnVariant.simple}) {
    final suffix = variant == InOnVariant.also ? ' vallen' : '';
    return '${_inVariant(variant)} de $weeks week$suffix';
  }

  String _inVariant(InOnVariant variant) {
    return switch (variant) {
      InOnVariant.simple => 'in',
      InOnVariant.also => 'die tevens in',
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
        frequency == DaysOfWeekFrequency.monthly ? 'de maand' : 'het jaar';
    final suffix = indicateFrequency ? ' van $frequencyString' : '';
    return '${_onVariant(variant)} $days$suffix';
  }

  @override
  String? get weekdaysString => 'weekdagen';
  @override
  String get everyXDaysOfWeekPrefix => 'elke ';
  @override
  String everyXDaysOfWeekPrefixForDay(int day) => 'elke ';
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
    final suffix2 = variant == InOnVariant.also ? ' zijn' : '';
    return '${_onVariant(variant)} de $days$suffix$suffix2';
  }

  @override
  String onDaysOfYear(
    String days, {
    InOnVariant variant = InOnVariant.simple,
  }) {
    final suffix = variant == InOnVariant.also ? ' zijn' : '';
    return '${_onVariant(variant)} de $days dag van het jaar$suffix';
  }

  String _onVariant(InOnVariant variant) {
    return switch (variant) {
      InOnVariant.simple => 'op',
      InOnVariant.also => 'die tevens',
      InOnVariant.instanceOf => 'van',
    };
  }

  @override
  String list(List<String> items, ListCombination combination) {
    final two = combination == ListCombination.disjunctive ? ' of ' : ' en ';
    final end = combination == ListCombination.conjunctiveLong ? ', en ' : two;
    return RruleL10n.defaultList(items, two: two, end: end);
  }

  @override
  String ordinal(int number) {
    assert(number != 0);

    const special = {1: 'eerste', -1: 'laatste', -2: 'voorlaatste'};
    final result = special[number];
    if (result != null) return result;

    final n = number.abs();
    final remain = n % 100;
    final string =
        (remain <= 1 || remain == 8 || remain >= 20) ? '${n}ste' : '${n}de';

    return number < 0 ? '$n-na-laatste' : string;
  }
}
