import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../../../frequency.dart';
import 'l10n.dart';

@immutable
class RruleL10nDe extends RruleL10n {
  const RruleL10nDe._();

  static Future<RruleL10nDe> create() async {
    // TODO(JonasWanke): Move `initializeDateFormatting(…)` call to the
    // library's user
    await initializeDateFormatting('de');
    return const RruleL10nDe._();
  }

  @override
  String get locale => 'de_DE';

  @override
  String frequencyInterval(Frequency frequency, int interval) {
    String plurals({required String one, required String singular, required String plural}) {
      return switch (interval) {
        1 => one,
        2 => singular,
        _ => 'Alle $interval $plural',
      };
    }

    return {
      Frequency.secondly: plurals(one: 'Sekündlich', singular: 'Jede zweite Sekunde', plural: 'Sekunden'),
      Frequency.minutely: plurals(one: 'Minütlich', singular: 'Jede zweite Minute', plural: 'Minuten'),
      Frequency.hourly: plurals(one: 'Stündlich', singular: 'Jede zweite Stunde', plural: 'Stunden'),
      Frequency.daily: plurals(one: 'Täglich', singular: 'Jeden zweiten Tag', plural: 'Tage'),
      Frequency.weekly: plurals(one: 'Wöchentlich', singular: 'Jede zweite Woche', plural: 'Wochen'),
      Frequency.monthly: plurals(one: 'Monatlich', singular: 'Jeden zweiten Monat', plural: 'Monate'),
      Frequency.yearly: plurals(one: 'Jährlich', singular: 'Jedes zweite Jahr', plural: 'Jahre'),
    }[frequency]!;
  }

  @override
  String until(DateTime until, Frequency frequency) {
    final untilString = formatWithIntl(() => DateFormat.yMMMMEEEEd().add_jms().format(until));
    return ', bis $untilString';
  }

  @override
  String count(int count) {
    return switch (count) {
      1 => ', ein Mal',
      2 => ', zwei Mal',
      _ => ', $count Mal',
    };
  }

  @override
  String onInstances(String instances) => 'am $instances';

  @override
  String inMonths(String months, {InOnVariant variant = InOnVariant.simple}) => '${_inMonthVariant(variant)} $months';

  @override
  String inWeeks(String weeks, {InOnVariant variant = InOnVariant.simple}) =>
      '${_inVariant(variant)} der $weeks Woche des Jahres';

  String _inVariant(InOnVariant variant) {
    return switch (variant) {
      InOnVariant.simple => 'in',
      InOnVariant.also => 'sowie in',
      InOnVariant.instanceOf => '',
    };
  }

  String _inMonthVariant(InOnVariant variant) {
    return switch (variant) {
      InOnVariant.simple => 'im',
      InOnVariant.also => 'sowie im',
      InOnVariant.instanceOf => '',
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

    // Montag -> Montags, Mittwoch -> Mittwochs, an Wochentagen -> an Wochentagen
    final daysWithSuffix = frequency == null && variant != InOnVariant.instanceOf ? days.replaceAll(RegExp(r'tag\b'), 'tags').replaceAll('Mittwoch', 'Mittwochs') : days;
    final frequencyString = frequency == DaysOfWeekFrequency.monthly ? 'Monats' : 'Jahres';
    final suffix = indicateFrequency ? ' des $frequencyString' : '';
    final prefix = (frequency != null && !days.startsWith('jeden') ? _onFrequencyVariant : _onVariant)(variant);
    return '${prefix.isNotEmpty ? '$prefix ' : ''}$daysWithSuffix$suffix';
  }

  @override
  String? get weekdaysString => 'an Wochentagen';

  @override
  String get everyXDaysOfWeekPrefix => 'jeden ';

  @override
  String nthDaysOfWeek(Iterable<int> occurrences, String daysOfWeek) {
    if (occurrences.isEmpty) return daysOfWeek;

    final ordinals = list(occurrences.map(ordinal).toList(), ListCombination.conjunctiveShort);
    return '$ordinals $daysOfWeek';
  }

  @override
  String onDaysOfMonth(
      String days, {
        DaysOfVariant daysOfVariant = DaysOfVariant.dayAndFrequency,
        InOnVariant variant = InOnVariant.simple,
      }) {
    final suffix = {
      DaysOfVariant.simple: '',
      DaysOfVariant.day: ' Tag',
      DaysOfVariant.dayAndFrequency: ' Tag des Monats',
    }[daysOfVariant];
    return '${_onFrequencyVariant(variant)} $days$suffix';
  }

  @override
  String onDaysOfYear(String days, {InOnVariant variant = InOnVariant.simple}) =>
      '${_onFrequencyVariant(variant)} $days Tag des Jahres';

  String _onVariant(InOnVariant variant) {
    return switch (variant) {
      InOnVariant.simple => '',
      InOnVariant.also => 'sowie',
      InOnVariant.instanceOf => '',
    };
  }

  String _onFrequencyVariant(InOnVariant variant) {
    return switch (variant) {
      InOnVariant.simple => 'am',
      InOnVariant.also => 'sowie am',
      InOnVariant.instanceOf => '',
    };
  }

  @override
  String list(List<String> items, ListCombination combination) {
    final (two, end) = switch (combination) {
      ListCombination.conjunctiveShort => (' & ', ' & '),
      ListCombination.conjunctiveLong => (' und ', ', und '),
      ListCombination.disjunctive => (' oder ', ', oder '),
    };
    return RruleL10n.defaultList(items, two: two, end: end);
  }

  @override
  String ordinal(int number) {
    assert(number != 0);

    final n = number.abs();
    if (n == 1) {
      return number > 0 ? 'ersten' : 'letzten';
    } else if (n == 2) {
      return number > 0 ? 'zweiten' : 'vorletzten';
    } else {
      return number > 0 ? '$n.' : '$n.-letzten';
    }
  }
}
