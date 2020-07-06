import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import '../../../frequency.dart';
import '../../../recurrence_rule.dart';
import 'en.dart';

export 'en.dart';

/// Contains localized strings used by [RecurrenceRule.toText].
///
/// Currently, only English is supported. You can get an instance via
/// [RruleL10nEn.create].
@immutable
abstract class RruleL10n {
  const RruleL10n(this.culture) : assert(culture != null);

  final Culture culture;

  String frequencyInterval(Frequency frequency, int interval);
  String until(LocalDateTime until);
  String count(int count);
  String range(String start, String end) => '$start – $end';

  String onInstances(String instances);

  String inMonths(String months, {InOnVariant variant = InOnVariant.simple});
  String month(int month) => LocalDate(1, month, 1).toString('MMMM', culture);

  String inWeeks(String weeks, {InOnVariant variant = InOnVariant.simple});

  Set<DayOfWeek> get weekdays => {
        DayOfWeek.monday,
        DayOfWeek.tuesday,
        DayOfWeek.wednesday,
        DayOfWeek.thursday,
        DayOfWeek.friday,
      };
  String onDaysOfWeek(
    String days, {
    bool indicateFrequency = false,
    DaysOfWeekFrequency frequency = DaysOfWeekFrequency.monthly,
    InOnVariant variant = InOnVariant.simple,
  });
  String get weekdaysString;
  String get everyXDaysOfWeekPrefix;
  String dayOfWeek(DayOfWeek dayOfWeek) {
    return LocalDate.minIsoValue
        .adjust(DateAdjusters.nextOrSame(dayOfWeek))
        .toString('dddd', culture);
  }

  String nthDaysOfWeek(Iterable<int> occurrences, String daysOfWeek);

  String onDaysOfMonth(
    String days, {
    DaysOfVariant daysOfVariant = DaysOfVariant.dayAndFrequency,
    InOnVariant variant = InOnVariant.simple,
  });

  String onDaysOfYear(String days, {InOnVariant variant = InOnVariant.simple});

  String list(List<String> items, ListCombination combination);

  /// Generates a formatted list from items similar to the
  /// [Unicode-Proposal](http://cldr.unicode.org/development/development-process/design-proposals/list-formatting).
  static String defaultList(
    List<String> items, {
    @required String two,
    String start = ', ',
    String middle = ', ',
    @required String end,
  }) {
    assert(items != null);
    assert(two != null);
    assert(start != null);
    assert(middle != null);
    assert(end != null);

    switch (items.length) {
      case 0:
        assert(false);
        return null;
      case 1:
        return items.first;
      case 2:
        return '${items.first}$two${items[1]}';
      default:
        final output = StringBuffer(items.first);
        output..write(start)..write(items[1]);

        for (final entry in items.sublist(2, items.length - 1)) {
          output..write(middle)..write(entry);
        }

        output..write(end)..write(items.last);
        return output.toString();
    }
  }

  String ordinal(int number);
}

enum InOnVariant { simple, also, instanceOf }

enum DaysOfWeekFrequency { monthly, yearly }

enum DaysOfVariant { simple, day, dayAndFrequency }

enum ListCombination { conjunctiveShort, conjunctiveLong, disjunctive }
