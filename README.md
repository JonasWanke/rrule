🔁 Recurrence rule parsing & calculation as defined in the iCalendar RFC

![Build, Test & Lint](https://github.com/JonasWanke/rrule/workflows/Build,%20Test%20&%20Lint/badge.svg)
[![Coverage](https://codecov.io/gh/JonasWanke/rrule/branch/main/graph/badge.svg)](https://codecov.io/gh/JonasWanke/rrule)

## How to use this package

Create a [`RecurrenceRule`]:

```dart
// Every two weeks on Tuesday and Thursday, but only in December.
final rrule = RecurrenceRule(
  frequency: Frequency.weekly,
  interval: 2,
  byWeekDays: {
    ByWeekDayEntry(DateTime.tuesday),
    ByWeekDayEntry(DateTime.thursday),
  },
  byMonths: {12},
);
```

And get its recurrences by evaluating it from a start date:

```dart
final Iterable<DateTime> instances = rrule.getInstances(
  start: DateTime.now().copyWith(isUtc: true),
);
```

> ⚠️ <kbd>rrule</kbd> doesn't care about any time-zone-related stuff.
> All supplied `DateTime`s must have `isUtc` set to `true` (because UTC doesn't have complications like summer and winter time), but the actual time zone is then ignored, e.g., when generating human-readable text.
>
> If you have a `DateTime` instance in the local time zone, you can use <kbd>rrule</kbd>'s helper `dateTime.copyWith(isUtc: true)` which keeps the date and time but sets `isUtc` to true.
> To convert the generated instances back to your local time zone, you can use `dateTime.copyWith(isUtc: false)`.

To limit returned instances (besides using `RecurrenceRule.until` or `RecurrenceRule.count`), you can use Dart's default `Iterable` functions:

```dart
final firstThreeInstances = instances.take(3);

final onlyThisYear = instances.takeWhile(
  (instance) => instance.year == DateTime.now().year,
);

final startingNextYear = instances.where(
  (instance) => instance.year > DateTime.now().year,
);
```

## Machine-readable String conversion

You can convert between [`RecurrenceRule`]s and [iCalendar/RFC 5545][RFC 5545]-compliant `String`s by using [`RecurrenceRuleStringCodec`] or the following convenience methods:

```dart
final string = 'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH;BYMONTH=12';
final rrule = RecurrenceRule.fromString(string);

assert(rrule.toString() == string); // true
```

<sup>(Same RRULE as the first one)</sup>

## Human-readable Text conversion

You can convert a [`RecurrenceRule`] to a human-readable `String`s by using [`RecurrenceRule.toText()`]:

```dart
// First, load the localizations (currently, only English is supported):
final l10n = await RruleL10nEn.create();

final rrule = RecurrenceRule.fromString(
  'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH;BYMONTH=12',
);

final text = 'Every other week in December on Tuesday & Thursday';
assert(rrule.toText(l10n: l10n) == string); // true
```

<sup>(Same RRULE as the first one)</sup>

A few more examples:

* `RRULE:INTERVAL=4;FREQ=HOURLY`: Every 4 hours
* `RRULE:FREQ=DAILY;BYSETPOS=1,-2;BYMONTH=1,12;BYMONTHDAY=1,-1`: Daily in January & December on the 1st & 2nd-to-last instance of the 1st & last day of the month
* `RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR`: Weekly on weekdays
* `RRULE:INTERVAL=2;FREQ=WEEKLY`: Every other week
* `RRULE:FREQ=MONTHLY;BYDAY=-3TU`: Monthly on the 3rd-to-last Tuesday
* `RRULE:FREQ=YEARLY;BYDAY=+13FR`: Annually on the 13th Friday of the year
* `RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,WE`: Annually on the 1st & 2nd-to-last instance of every Monday & Wednesday that are also the 1st or last day of the month, that are also the 1st or last day of the year, that are also in the 1st or last week of the year, and that are also in January or December

While this already supports really complex RRULEs, some of them are not (yet) supported. See [`RecurrenceRule.canFullyConvertToText`] for more information.

## JSON conversion

You can convert between [`RecurrenceRule`]s and [jCal/RFC 7265][RFC 7265]-compliant JSON using the following convenience methods:

```dart
final json = <String, dynamic>{
  'freq': 'WEEKLY',
  'interval': 2,
  'byday': ['TU', 'TH'],
  'bymonth': [12],
};
final rrule = RecurrenceRule.fromJson(json);

expect(rrule.toJson(), json);
```

<sup>(Same RRULE as the first one)</sup>

## Limitations

* custom week starts are not supported (`WKST` in the specification) – Monday is the only valid value (encoded as `MO`)
* leap seconds are not supported (limitation of Dart's `DateTime`)
* only years 0–9999 in the Common Era are supported (limitation of the iCalendar RFC, but if you have a use case, this should be easy to extend)

## Thanks

The recurrence calculation code of `RecurrencRule`s is mostly a partial port of [<kbd>rrule.js</kbd>], though with a lot of modifications to use Dart's `DateTime` and not having to do date/time calculations manually. You can find the license of [<kbd>rrule.js</kbd>] in the file `LICENSE-rrule.js.txt`.

[<kbd>rrule.js</kbd>]: https://github.com/jakubroztocil/rrule
[RFC 5545]: https://datatracker.ietf.org/doc/html/rfc5545
[RFC 7265]: https://datatracker.ietf.org/doc/html/rfc7265
[`RecurrenceRule`]: https://pub.dev/documentation/rrule/latest/rrule/RecurrenceRule-class.html
[`RecurrenceRule.canFullyConvertToText`]: https://pub.dev/documentation/rrule/latest/rrule/RecurrenceRule/canFullyConvertToText.html
[`RecurrenceRule.toText()`]: https://pub.dev/documentation/rrule/latest/rrule/RecurrenceRule/toText.html
[`RecurrenceRuleStringCodec`]: https://pub.dev/documentation/rrule/latest/rrule/RecurrenceRuleStringCodec-class.html
