🔁 Recurrence rule parsing & calculation as defined in the iCalendar RFC

![Build, Test & Lint](https://github.com/JonasWanke/rrule/workflows/Build,%20Test%20&%20Lint/badge.svg)
[![Coverage](https://codecov.io/gh/JonasWanke/rrule/branch/main/graph/badge.svg)](https://codecov.io/gh/JonasWanke/rrule)

## How to use this package

> **Note:** This package uses [<kbd>time_machine</kbd>] for handling date and time. See [its README](https://pub.dev/packages/time_machine#flutter-specific-notes) for how to initialize it on Flutter or the web.

Create a [`RecurrenceRule`]:

```dart
// Every two weeks on Tuesday and Thursday, but only in December.
final rrule = RecurrenceRule(
  frequency: Frequency.weekly,
  interval: 2,
  byWeekDays: {
    ByWeekDayEntry(DayOfWeek.tuesday),
    ByWeekDayEntry(DayOfWeek.thursday),
  },
  byMonths: {12},
  weekStart: DayOfWeek.sunday,
);
```

And get its recurrences by evaluating it from a start date:

```dart
final Iterable<LocalDateTime> instances = rrule.getInstances(
  start: LocalDateTime.now(),
);
```

To limit returned instances (besides using `RecurrenceRule.until` or `RecurrenceRule.count`), you can use Dart's default `Iterable` functions:

```dart
final firstThreeInstances = instances.take(3);

final onlyThisYear = instances.takeWhile(
  (instance) => instance.year == LocalDate.today().year,
);

final startingNextYear = instances.where(
  (instance) => instance.year > LocalDate.today().year,
);
```

> **Note:** Convenience methods or parameters will be added soon to make these limitations easier.

## Machine-readable String conversion

You can convert between [`RecurrenceRule`]s and [iCalendar/RFC 5545][RFC 5545]-compliant `String`s by using [`RecurrenceRuleStringCodec`] or the following convenience methods:

```dart
final string = 'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH;BYMONTH=12;WKST=SU';
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
    'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH;BYMONTH=12;WKST=SU');

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

## Limitations

* leap seconds are not supported (limitation of the [<kbd>time_machine</kbd>] package)
* only years 0–9999 in the Common Era are supported (limitation of the iCalendar RFC, but if you have a use case, this should be easy to extend)

## Thanks

The recurrence calculation code of `RecurrencRule`s is mostly a partial port of [<kbd>rrule.js</kbd>], though with a lot of modifications to use [<kbd>time_machine</kbd>] and not having to do date/time calculations manually. You can find the license of [<kbd>rrule.js</kbd>] in the file `LICENSE-rrule.js.txt`.

[<kbd>time_machine</kbd>]: https://pub.dev/packages/time_machine
[<kbd>rrule.js</kbd>]: https://github.com/jakubroztocil/rrule
[RFC 5545]: https://tools.ietf.org/html/rfc5545
[`RecurrenceRule`]: https://pub.dev/documentation/rrule/latest/rrule/RecurrenceRule-class.html
[`RecurrenceRule.canFullyConvertToText`]: https://pub.dev/documentation/rrule/latest/rrule/RecurrenceRule/canFullyConvertToText.html
[`RecurrenceRule.toText()`]: https://pub.dev/documentation/rrule/latest/rrule/RecurrenceRule/toText.html
[`RecurrenceRuleStringCodec`]: https://pub.dev/documentation/rrule/latest/rrule/RecurrenceRuleStringCodec-class.html
