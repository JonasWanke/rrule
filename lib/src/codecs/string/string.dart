import 'dart:convert';

import 'package:meta/meta.dart';

import '../../by_week_day_entry.dart';
import '../../frequency.dart';
import '../../recurrence_rule.dart';
import 'decoder.dart';
import 'encoder.dart';

/// A [Codec] for converting [RecurrenceRule]s from and to
/// [RFC 5545](https://tools.ietf.org/html/rfc5545#section-3.8.5.3) compliant
/// strings.
@immutable
class RecurrenceRuleStringCodec extends Codec<RecurrenceRule, String> {
  const RecurrenceRuleStringCodec({
    this.toStringOptions = const RecurrenceRuleToStringOptions(),
    this.fromStringOptions = const RecurrenceRuleFromStringOptions(),
  });

  final RecurrenceRuleToStringOptions toStringOptions;
  final RecurrenceRuleFromStringOptions fromStringOptions;

  @override
  Converter<RecurrenceRule, String> get encoder =>
      RecurrenceRuleToStringEncoder(options: toStringOptions);

  @override
  Converter<String, RecurrenceRule> get decoder =>
      RecurrenceRuleFromStringDecoder(options: fromStringOptions);
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

const recurFreqSecondly = 'SECONDLY';
const recurFreqMinutely = 'MINUTELY';
const recurFreqHourly = 'HOURLY';
const recurFreqDaily = 'DAILY';
const recurFreqWeekly = 'WEEKLY';
const recurFreqMonthly = 'MONTHLY';
const recurFreqYearly = 'YEARLY';
const recurFreqValues = {
  recurFreqSecondly: Frequency.secondly,
  recurFreqMinutely: Frequency.minutely,
  recurFreqHourly: Frequency.hourly,
  recurFreqDaily: Frequency.daily,
  recurFreqWeekly: Frequency.weekly,
  recurFreqMonthly: Frequency.monthly,
  recurFreqYearly: Frequency.yearly,
};

const recurWeekDayValues = {
  'MO': DateTime.monday,
  'TU': DateTime.tuesday,
  'WE': DateTime.wednesday,
  'TH': DateTime.thursday,
  'FR': DateTime.friday,
  'SA': DateTime.saturday,
  'SU': DateTime.sunday,
};
