import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

import '../../recurrence_rule.dart';
import 'encoder.dart';

/// A [Codec] for converting [RecurrenceRule]s from and to
/// [RFC 5545](https://tools.ietf.org/html/rfc5545#section-3.8.5.3) compliant
/// strings.
@immutable
class RecurrenceRuleStringCodec extends Codec<RecurrenceRule, String> {
  const RecurrenceRuleStringCodec({
    this.toStringOptions = const RecurrenceRuleToStringOptions(),
  }) : assert(toStringOptions != null);

  final RecurrenceRuleToStringOptions toStringOptions;

  @override
  Converter<RecurrenceRule, String> get encoder =>
      RecurrenceRuleToStringEncoder(options: toStringOptions);

  @override
  // TODO: implement decoder
  Converter<String, RecurrenceRule> get decoder => throw UnimplementedError();
}

/// Pattern corresponding to the `DATE` rule specified in
/// [RFC 5545 Section 3.3.4: Date](https://tools.ietf.org/html/rfc5545#section-3.3.4).
final datePattern = LocalDatePattern.createWithInvariantCulture('yyyyMMdd');
@immutable
class ByWeekDayEntryStringCodec extends Codec<ByWeekDayEntry, String> {
  const ByWeekDayEntryStringCodec();

  @override
  Converter<ByWeekDayEntry, String> get encoder =>
      ByWeekDayEntryToStringEncoder();

  @override
  Converter<String, ByWeekDayEntry> get decoder =>
      ByWeekDayEntryFromStringDecoder();
}

/// Pattern corresponding to the `TIME` rule specified in
/// [RFC 5545 Section 3.3.12: Time](https://tools.ietf.org/html/rfc5545#section-3.3.12).
final timePattern = LocalTimePattern.createWithInvariantCulture('HHmmss');

/// Pattern corresponding to the `DATE-TIME` rule specified in
/// [RFC 5545 Section 3.3.5: Date-Time](https://tools.ietf.org/html/rfc5545#section-3.3.5).
final dateTimePattern = LocalDateTimePattern.createWithInvariantCulture(
    '${datePattern.patternText}"T"${timePattern.patternText}');

const frequencyStrings = {
  'SECONDLY': RecurrenceFrequency.secondly,
  'MINUTELY': RecurrenceFrequency.minutely,
  'HOURLY': RecurrenceFrequency.hourly,
  'DAILY': RecurrenceFrequency.daily,
  'WEEKLY': RecurrenceFrequency.weekly,
  'MONTHLY': RecurrenceFrequency.monthly,
  'YEARLY': RecurrenceFrequency.yearly,
};

const weekDayStrings = {
  'MO': DayOfWeek.monday,
  'TU': DayOfWeek.tuesday,
  'WE': DayOfWeek.wednesday,
  'TH': DayOfWeek.thursday,
  'FR': DayOfWeek.friday,
  'SA': DayOfWeek.saturday,
  'SU': DayOfWeek.sunday,
};
