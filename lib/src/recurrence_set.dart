import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import 'recurrence_rule.dart';

@immutable
class RecurrenceSet {
  const RecurrenceSet({
    this.recurrenceRules = const {},
    this.recurrenceDates = const {},
    this.exceptionDates = const {},
  })  : assert(recurrenceRules != null),
        assert(recurrenceDates != null),
        assert(exceptionDates != null);

  /// Corresponds to `RRULE` properties.
  final Set<RecurrenceRule> recurrenceRules;

  /// Corresponds to `RDATE` properties.
  final Set<LocalDateTime> recurrenceDates;

  /// These dates take precedence over generated dates from [recurrenceRules]
  /// and [recurrenceDates].
  ///
  /// Corresponds to `EXDATE` properties.
  ///
  /// Specified in [RFC 5545 Section 3.8.5.1: Exception Date-Times](https://tools.ietf.org/html/rfc5545#section-3.8.5.1).
  final Set<LocalDateTime> exceptionDates;
}
