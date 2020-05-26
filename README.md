🔁 Recurrence rule parsing & calculation as defined in the iCalendar RFC

![Build, Test & Lint](https://github.com/JonasWanke/rrule/workflows/Build,%20Test%20&%20Lint/badge.svg) [![Coverage](https://codecov.io/gh/JonasWanke/rrule/branch/master/graph/badge.svg)](https://codecov.io/gh/JonasWanke/rrule)


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


## String conversion

You can convert between [`RecurrenceRule`]s and [iCalendar/RFC 5545][RFC 5545]-compliant `String`s by using [`RecurrenceRuleStringCodec`] or the following convenience methods:

```dart
final string = 'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH;BYMONTH=12;WKST=SU';
final rrule = RecurrenceRule.fromString()

assert(rrule.toString == string); // true
```
<sup>(Same rule as the first one)</sup>


## Limitations

- leap seconds are not supported (limitation of the [<kbd>time_machine</kbd>] package)
- only years 0–9999 in the Common Era are supported (limitation of the iCalendar RFC, but if you have a use case this should be easy to extend)


## Thanks

The recurrence calculation code of `RecurrencRule`s is mostly a partial port of [<kbd>rrule.js</kbd>], though with a lot of modifications to use [<kbd>time_machine</kbd>] and not having to do date/time calculations manually. You can find the license of [<kbd>rrule.js</kbd>] in the file `LICENSE-rrule.js.txt`.


[<kbd>time_machine</kbd>]: https://pub.dev/packages/time_machine
[<kbd>rrule.js</kbd>]: https://github.com/jakubroztocil/rrule
[RFC 5545]: https://tools.ietf.org/html/rfc5545
[`RecurrenceRule`]: https://pub.dev/documentation/rrule/latest/rrule/RecurrenceRule-class.html
[`RecurrenceRuleStringCodec`]: https://pub.dev/documentation/rrule/latest/rrule/RecurrenceRuleStringCodec-class.html
