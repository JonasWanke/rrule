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
        _ => 'Alle $interval ${plural}',
      };
    }

    return {
      Frequency.secondly: plurals(one: 'Sekündlich', singular: 'Jede andere Sekunde', plural: 'Sekunden'),
      Frequency.minutely: plurals(one: 'Minütlich', singular: 'Jede andere Minute', plural: 'Minuten'),
      Frequency.hourly: plurals(one: 'Stündlich', singular: 'Jede andere Stunde', plural: 'Stunden'),
      Frequency.daily: plurals(one: 'Täglich', singular: 'Jeden anderen Tag', plural: 'Tage'),
      Frequency.weekly: plurals(one: 'Wöchentlich', singular: 'Jede andere Woche', plural: 'Wochen'),
      Frequency.monthly: plurals(one: 'Monatlich', singular: 'Jeden anderen Monat', plural: 'Monate'),
      Frequency.yearly: plurals(one: 'Jährlich', singular: 'Jedes andere Jahr', plural: 'Jahre'),
    }[frequency]!;
  }

  @override
  String until(DateTime until, Frequency frequency) {
    final untilString =
        formatWithIntl(() => DateFormat.yMMMMEEEEd().add_jms().format(until));
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
  String onInstances(String instances) => 'an der $instances Instanz';

  @override
  String inMonths(String months, {InOnVariant variant = InOnVariant.simple}) =>
      '${_inVariant(variant)} $months';

  @override
  String inWeeks(String weeks, {InOnVariant variant = InOnVariant.simple}) =>
      '${_inVariant(variant)} der $weeks Woche des Jahres';

  String _inVariant(InOnVariant variant) {
    return switch (variant) {
      InOnVariant.simple => 'in',
      InOnVariant.also => 'auch in',
      InOnVariant.instanceOf => 'von',
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
        frequency == DaysOfWeekFrequency.monthly ? 'Monat' : 'Jahr';
    final suffix = indicateFrequency ? ' von dem $frequencyString' : '';
    return '${_onVariant(variant)} $days$suffix';
  }

  @override
  String? get weekdaysString => 'Wochentage';
  @override
  String get everyXDaysOfWeekPrefix => 'jedem ';
  @override
  String nthDaysOfWeek(Iterable<int> occurrences, String daysOfWeek) {
    if (occurrences.isEmpty) return daysOfWeek;

    final ordinals = list(
      occurrences.map(ordinal).toList(),
      ListCombination.conjunctiveShort,
    );
    return 'dem $ordinals $daysOfWeek';
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
    return '${_onVariant(variant)} dem $days$suffix';
  }

  @override
  String onDaysOfYear(
    String days, {
    InOnVariant variant = InOnVariant.simple,
  }) =>
      '${_onVariant(variant)} dem $days Tag des Jahres';

  String _onVariant(InOnVariant variant) {
    return switch (variant) {
      InOnVariant.simple => 'an',
      InOnVariant.also => 'sowie auch',
      InOnVariant.instanceOf => 'von',
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
    if (number == -1) return 'letzten';

    final n = number.abs();
    String string;
    if (n == 1 ) {
      string = 'ersten';
    } else if (n == 2 ) {
      string = 'zweiten';
    } else if (n == 3 ) {
      string = 'vierten';
    } else {
      string = '${n}.';
    }

    return number < 0 ? '$string vorherigen' : string;
  }
}
