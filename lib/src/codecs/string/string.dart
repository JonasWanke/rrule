import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

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

/// Name of the `RRULE` property as defined in [RFC 5545 Section 3.8.5.3](https://tools.ietf.org/html/rfc5545#section-3.8.5.3).
const rruleName = 'RRULE';

/// Names of `Recurrence Rule` parts as defined in [RFC 5545 Section 3.3.10](https://tools.ietf.org/html/rfc5545#section-3.3.10).
const recurRulePartFreq = 'FREQ';
const recurRulePartUntil = 'UNTIL';
const recurRulePartCount = 'COUNT';
const recurRulePartInterval = 'INTERVAL';
const recurRulePartBySecond = 'BYSECOND';
const recurRulePartByMinute = 'BYMINUTE';
const recurRulePartByHour = 'BYHOUR';
const recurRulePartByDay = 'BYDAY';
const recurRulePartByMonthDay = 'BYMONTHDAY';
const recurRulePartByYearDay = 'BYYEARDAY';
const recurRulePartByWeekNo = 'BYWEEKNO';
const recurRulePartByMonth = 'BYMONTH';
const recurRulePartBySetPos = 'BYSETPOS';
const recurRulePartWkSt = 'WKST';

const recurFreqValues = {
  'SECONDLY': RecurrenceFrequency.secondly,
  'MINUTELY': RecurrenceFrequency.minutely,
  'HOURLY': RecurrenceFrequency.hourly,
  'DAILY': RecurrenceFrequency.daily,
  'WEEKLY': RecurrenceFrequency.weekly,
  'MONTHLY': RecurrenceFrequency.monthly,
  'YEARLY': RecurrenceFrequency.yearly,
};

const recurWeekDayValues = {
  'MO': DayOfWeek.monday,
  'TU': DayOfWeek.tuesday,
  'WE': DayOfWeek.wednesday,
  'TH': DayOfWeek.thursday,
  'FR': DayOfWeek.friday,
  'SA': DayOfWeek.saturday,
  'SU': DayOfWeek.sunday,
};
