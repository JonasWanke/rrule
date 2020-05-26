🔁 Recurrence rule parsing & calculation as defined in the iCalendar RFC

![Build, Test & Lint](https://github.com/JonasWanke/rrule/workflows/Build,%20Test%20&%20Lint/badge.svg) [![Coverage](https://codecov.io/gh/JonasWanke/rrule/branch/master/graph/badge.svg)](https://codecov.io/gh/JonasWanke/rrule)

## Thanks

The recurrence calculation code of `RecurrencRule`s is mostly a partial port of [<kbd>rrule.js</kbd>], though with a lot of modifications to use [<kbd>time_machine</kbd>] and not having to do date/time calculations manually. You can find the license of [<kbd>rrule.js</kbd>] in the file `LICENSE-rrule.js.txt`.


[<kbd>time_machine</kbd>]: https://pub.dev/packages/time_machine
[<kbd>rrule.js</kbd>]: https://github.com/jakubroztocil/rrule
