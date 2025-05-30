import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../../../frequency.dart';
import 'l10n.dart';

@immutable
class RruleL10nPtBr extends RruleL10n {
  const RruleL10nPtBr._();

  static Future<RruleL10nPtBr> create() async {
    // TODO(JonasWanke): Move `initializeDateFormatting(…)` call to the
    // library's user
    await initializeDateFormatting('pt_BR');
    return const RruleL10nPtBr._();
  }

  @override
  String get locale => 'pt_BR';

  @override
  String frequencyInterval(Frequency frequency, int interval) {
    String plurals({required String one, required String singular}) {
      if (frequency == Frequency.monthly) {
        return switch (interval) {
          1 => one,
          _ => 'A cada $interval meses',
        };
      }

      return switch (interval) {
        1 => one,
        _ => 'A cada $interval ${singular}s',
      };
    }

    return {
      Frequency.secondly: plurals(one: 'A cada segundo', singular: 'segundo'),
      Frequency.minutely: plurals(one: 'A cada minuto', singular: 'minuto'),
      Frequency.hourly: plurals(one: 'A cada hora', singular: 'hora'),
      Frequency.daily: plurals(one: 'Todos os dias', singular: 'dia'),
      Frequency.weekly: plurals(one: 'Semanal:', singular: 'semana'),
      Frequency.monthly: plurals(one: 'Mensal', singular: 'mês'),
      Frequency.yearly: plurals(one: 'Anual:', singular: 'ano'),
    }[frequency]!;
  }

  @override
  String until(DateTime until, Frequency frequency, {DateFormat? dateFormat}) {
    final untilString = formatWithIntl(() => 
      dateFormat?.format(until) ?? DateFormat('d MMM y', 'pt_BR').format(until)
    );
    return ' até $untilString';
  }

  @override
  String count(int count) {
    return switch (count) {
      1 => ', uma vez',
      2 => ', duas vezes',
      _ => ' $count vezes',
    };
  }

  @override
  String onInstances(String instances) => 'na $instances ocorrência';

  @override
  String inMonths(String months, {InOnVariant variant = InOnVariant.simple}) =>
      '${_inVariant(variant)} $months';

  @override
  String inWeeks(String weeks, {InOnVariant variant = InOnVariant.simple}) =>
      '${_inVariant(variant)} $weeks semana do ano';

  String _inVariant(InOnVariant variant) {
    return switch (variant) {
      InOnVariant.simple => 'em',
      InOnVariant.also => 'que também estão em',
      InOnVariant.instanceOf => 'de',
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

    final frequencyString = frequency == DaysOfWeekFrequency.monthly ? 'mês' : 'ano';
    final suffix = indicateFrequency ? ' do $frequencyString' : '';

    // Workaround: replace "toda sábado" with "todo sábado" and "toda domingo" with "todo domingo"
    final modifiedDays = days
        .replaceAll('toda sábado', 'todo sábado')
        .replaceAll('toda domingo', 'todo domingo');

    return '${_onVariant(variant, Frequency.weekly)} $modifiedDays$suffix';
  }

  @override
  String? get weekdaysString => 'dias úteis';

  @override
  String get everyXDaysOfWeekPrefix => 'toda ';

  @override
  String nthDaysOfWeek(Iterable<int> occurrences, String daysOfWeek) {
    if (occurrences.isEmpty) return daysOfWeek;

    final ordinals = list(
      occurrences.map(ordinal).toList(),
      ListCombination.conjunctiveShort,
    );

    // Workaround: replace the feminine form "última" with the masculine "último" 
    // when the first day of the week is Saturday or Sunday
    final firstDay = daysOfWeek.split(',')[0].trim();
    final modifiedOrdinals = (firstDay == 'sábado' || firstDay == 'domingo') 
        ? ordinals.replaceAll('última', 'último') 
        : ordinals;

    return '$modifiedOrdinals $daysOfWeek';
  }

  @override
  String onDaysOfMonth(
    String days, {
    DaysOfVariant daysOfVariant = DaysOfVariant.dayAndFrequency,
    InOnVariant variant = InOnVariant.simple,
  }) {
    final suffix = {
      DaysOfVariant.simple: ' dia',
      DaysOfVariant.day: ' dia',
      DaysOfVariant.dayAndFrequency: ' dia do mês',
    }[daysOfVariant];

    // Workaround: replace the feminine form "última" with the masculine "último" 
    // when referring to the last day of the month.
    final modifiedDays = days.endsWith('última') ? days.replaceAll('última', 'último') : days;
    return '${_onVariant(variant, Frequency.monthly)} $modifiedDays$suffix';
  }

  @override
  String onDaysOfYear(
    String days, {
    InOnVariant variant = InOnVariant.simple,
  }) {
    // Workaround: replace the feminine form "última" with the masculine "último" 
    // when referring to the last day of the year.
    final modifiedDays = days.endsWith('última') ? days.replaceAll('última', 'último') : days;
    return '${_onVariant(variant, Frequency.yearly)} $modifiedDays dia do ano';
  }

  String _onVariant(InOnVariant variant, Frequency frequency) {
    return switch (variant) {
      InOnVariant.simple => frequency == Frequency.monthly ? 'no' : 'cada',
      InOnVariant.also => 'que também são',
      InOnVariant.instanceOf => 'de',
    };
  }

  @override
  String list(List<String> items, ListCombination combination) {
    final (two, end) = switch (combination) {
      ListCombination.conjunctiveShort => (' e ', ' e '),
      ListCombination.conjunctiveLong => (' e ', ', e '),
      ListCombination.disjunctive => (' ou ', ', ou '),
    };
    return RruleL10n.defaultList(items, two: two, end: end);
  }

  @override
  String ordinal(int number) {
    assert(number != 0);
    if (number == -1) return 'última';

    final n = number.abs();
    String string;
    if (n % 10 == 1 && n % 100 != 11) {
      string = '${n}º';
    } else if (n % 10 == 2 && n % 100 != 12) {
      string = '${n}º';
    } else if (n % 10 == 3 && n % 100 != 13) {
      string = '${n}º';
    } else {
      string = '${n}º';
    }
    return number < 0 ? '${n}º última' : string;
  }
}
