import 'package:basics/basics.dart';
import 'package:rrule/rrule.dart';
import 'package:test/test.dart';
import 'package:time_machine/time_machine.dart';

import 'utils.dart';

void main() {
  // This file tests all examples given in RFC 5545:
  // https://tools.ietf.org/html/rfc5545#section-3.8.5.3.
  testRecurring(
    'Daily for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: Frequency.daily,
      count: 10,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: 2.to(12).map((d) => LocalDate(1997, 9, d)),
  );
  testRecurring(
    'Daily until December 24, 1997',
    rrule: RecurrenceRule(
      frequency: Frequency.daily,
      until: LocalDate(1997, 12, 24).atMidnight(),
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...2.to(31).map((d) => LocalDate(1997, 9, d)),
      ...1.to(32).map((d) => LocalDate(1997, 10, d)),
      ...1.to(31).map((d) => LocalDate(1997, 11, d)),
      ...1.to(24).map((d) => LocalDate(1997, 12, d)),
    ],
  );
  testRecurring(
    'Every other day - forever',
    rrule: RecurrenceRule(
      frequency: Frequency.daily,
      interval: 2,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...2.to(31, by: 2).map((d) => LocalDate(1997, 9, d)),
      ...2.to(31, by: 2).map((d) => LocalDate(1997, 10, d)),
      ...1.to(30, by: 2).map((d) => LocalDate(1997, 11, d)),
      ...1.to(32, by: 2).map((d) => LocalDate(1997, 12, d)),
    ],
    isInfinite: true,
  );
  testRecurring(
    'Every 10 days, 5 occurrences',
    rrule: RecurrenceRule(
      frequency: Frequency.daily,
      count: 5,
      interval: 10,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...2.to(23, by: 10).map((d) => LocalDate(1997, 9, d)),
      ...2.to(13, by: 10).map((d) => LocalDate(1997, 10, d)),
    ],
  );
  group('Every day in January, for 3 years', () {
    final expected = 1998.to(2001).expand((y) {
      return 1.to(32).map((d) => LocalDate(y, 1, d));
    });
    testRecurring(
      'with frequency yearly',
      rrule: RecurrenceRule(
        frequency: Frequency.yearly,
        until: LocalDateTime(2000, 01, 31, 14, 0, 0),
        byWeekDays: {
          ByWeekDayEntry(DayOfWeek.sunday),
          ByWeekDayEntry(DayOfWeek.monday),
          ByWeekDayEntry(DayOfWeek.tuesday),
          ByWeekDayEntry(DayOfWeek.wednesday),
          ByWeekDayEntry(DayOfWeek.thursday),
          ByWeekDayEntry(DayOfWeek.friday),
          ByWeekDayEntry(DayOfWeek.saturday),
        },
        byMonths: {1},
      ),
      start: LocalDateTime(1998, 1, 1, 9, 0, 0),
      expectedDates: expected,
    );
    testRecurring(
      'with frequency daily',
      rrule: RecurrenceRule(
        frequency: Frequency.daily,
        until: LocalDateTime(2000, 01, 31, 14, 0, 0),
        byMonths: {1},
      ),
      start: LocalDateTime(1998, 1, 1, 9, 0, 0),
      expectedDates: expected,
    );
  });
  testRecurring(
    'Weekly for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: Frequency.weekly,
      count: 10,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...2.to(31, by: 7).map((d) => LocalDate(1997, 9, d)),
      ...7.to(29, by: 7).map((d) => LocalDate(1997, 10, d)),
      LocalDate(1997, 11, 4),
    ],
  );
  testRecurring(
    'Weekly until December 24, 1997',
    rrule: RecurrenceRule(
      frequency: Frequency.weekly,
      until: LocalDate(1997, 12, 24).atMidnight(),
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...2.to(31, by: 7).map((d) => LocalDate(1997, 9, d)),
      ...7.to(29, by: 7).map((d) => LocalDate(1997, 10, d)),
      ...4.to(26, by: 7).map((d) => LocalDate(1997, 11, d)),
      ...2.to(24, by: 7).map((d) => LocalDate(1997, 12, d)),
    ],
  );
  testRecurring(
    'Every other week - forever',
    rrule: RecurrenceRule(
      frequency: Frequency.weekly,
      interval: 2,
      weekStart: DayOfWeek.sunday,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...2.to(31, by: 14).map((d) => LocalDate(1997, 9, d)),
      ...14.to(29, by: 14).map((d) => LocalDate(1997, 10, d)),
      ...11.to(26, by: 14).map((d) => LocalDate(1997, 11, d)),
      ...9.to(24, by: 14).map((d) => LocalDate(1997, 12, d)),
      ...6.to(21, by: 14).map((d) => LocalDate(1998, 1, d)),
      ...3.to(18, by: 14).map((d) => LocalDate(1998, 2, d)),
    ],
    isInfinite: true,
  );
  group('Weekly on Tuesday and Thursday for five weeks', () {
    final expected = [
      ...[2, 4, 9, 11, 16, 18, 23, 25, 30].map((d) => LocalDate(1997, 09, d)),
      LocalDate(1997, 10, 2),
    ];
    testRecurring(
      'with until',
      rrule: RecurrenceRule(
        frequency: Frequency.weekly,
        until: LocalDate(1997, 10, 07).atMidnight(),
        weekStart: DayOfWeek.sunday,
        byWeekDays: {
          ByWeekDayEntry(DayOfWeek.tuesday),
          ByWeekDayEntry(DayOfWeek.thursday),
        },
      ),
      start: LocalDateTime(1997, 9, 2, 9, 0, 0),
      expectedDates: expected,
    );
    testRecurring(
      'with count',
      rrule: RecurrenceRule(
        frequency: Frequency.weekly,
        count: 10,
        byWeekDays: {
          ByWeekDayEntry(DayOfWeek.tuesday),
          ByWeekDayEntry(DayOfWeek.thursday),
        },
        weekStart: DayOfWeek.sunday,
      ),
      start: LocalDateTime(1997, 9, 2, 9, 0, 0),
      expectedDates: expected,
    );
  });
  testRecurring(
    'Every other week on Monday, Wednesday, and Friday until December 24, 1997',
    rrule: RecurrenceRule(
      frequency: Frequency.weekly,
      until: LocalDate(1997, 12, 24).atMidnight(),
      interval: 2,
      byWeekDays: {
        ByWeekDayEntry(DayOfWeek.monday),
        ByWeekDayEntry(DayOfWeek.wednesday),
        ByWeekDayEntry(DayOfWeek.friday),
      },
      weekStart: DayOfWeek.sunday,
    ),
    start: LocalDateTime(1997, 9, 1, 9, 0, 0),
    expectedDates: [
      ...[1, 3, 5, 15, 17, 19, 29].map((d) => LocalDate(1997, 9, d)),
      ...[1, 3, 13, 15, 17, 27, 29, 31].map((d) => LocalDate(1997, 10, d)),
      ...[10, 12, 14, 24, 26, 28].map((d) => LocalDate(1997, 11, d)),
      ...[8, 10, 12, 22].map((d) => LocalDate(1997, 12, d)),
    ],
  );
  testRecurring(
    'Every other week on Tuesday and Thursday, for 8 occurrences',
    rrule: RecurrenceRule(
      frequency: Frequency.weekly,
      count: 8,
      interval: 2,
      byWeekDays: {
        ByWeekDayEntry(DayOfWeek.tuesday),
        ByWeekDayEntry(DayOfWeek.thursday),
      },
      weekStart: DayOfWeek.sunday,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...[2, 4, 16, 18, 30].map((d) => LocalDate(1997, 9, d)),
      ...[2, 14, 16].map((d) => LocalDate(1997, 10, d)),
    ],
  );
  testRecurring(
    'Monthly on the first Friday for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      count: 10,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.friday, 1)},
    ),
    start: LocalDateTime(1997, 9, 5, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 9, 5),
      LocalDate(1997, 10, 3),
      LocalDate(1997, 11, 7),
      LocalDate(1997, 12, 5),
      LocalDate(1998, 1, 2),
      LocalDate(1998, 2, 6),
      LocalDate(1998, 3, 6),
      LocalDate(1998, 4, 3),
      LocalDate(1998, 5, 1),
      LocalDate(1998, 6, 5),
    ],
  );
  testRecurring(
    'Monthly on the first Friday until December 24, 1997',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      until: LocalDate(1997, 12, 24).atMidnight(),
      byWeekDays: {ByWeekDayEntry(DayOfWeek.friday, 1)},
    ),
    start: LocalDateTime(1997, 9, 5, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 9, 5),
      LocalDate(1997, 10, 3),
      LocalDate(1997, 11, 7),
      LocalDate(1997, 12, 5),
    ],
  );
  testRecurring(
    'Every other month on the first and last Sunday of the month for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      count: 10,
      interval: 2,
      byWeekDays: {
        ByWeekDayEntry(DayOfWeek.sunday, 1),
        ByWeekDayEntry(DayOfWeek.sunday, -1),
      },
    ),
    start: LocalDateTime(1997, 9, 7, 9, 0, 0),
    expectedDates: [
      ...[7, 28].map((d) => LocalDate(1997, 9, d)),
      ...[2, 30].map((d) => LocalDate(1997, 11, d)),
      ...[4, 25].map((d) => LocalDate(1998, 1, d)),
      ...[1, 29].map((d) => LocalDate(1998, 3, d)),
      ...[3, 31].map((d) => LocalDate(1998, 5, d)),
    ],
  );
  testRecurring(
    'Monthly on the second-to-last Monday of the month for 6 months',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      count: 6,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.monday, -2)},
    ),
    start: LocalDateTime(1997, 9, 22, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 9, 22),
      LocalDate(1997, 10, 20),
      LocalDate(1997, 11, 17),
      LocalDate(1997, 12, 22),
      LocalDate(1998, 1, 19),
      LocalDate(1998, 2, 16),
    ],
  );
  testRecurring(
    'Monthly on the third-to-the-last day of the month, forever',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      byMonthDays: {-3},
    ),
    start: LocalDateTime(1997, 9, 28, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 9, 28),
      LocalDate(1997, 10, 29),
      LocalDate(1997, 11, 28),
      LocalDate(1997, 12, 29),
      LocalDate(1998, 1, 29),
      LocalDate(1998, 2, 26),
    ],
    isInfinite: true,
  );
  testRecurring(
    'Monthly on the 2nd and 15th of the month for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      count: 10,
      byMonthDays: {2, 15},
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...[2, 15].map((d) => LocalDate(1997, 9, d)),
      ...[2, 15].map((d) => LocalDate(1997, 10, d)),
      ...[2, 15].map((d) => LocalDate(1997, 11, d)),
      ...[2, 15].map((d) => LocalDate(1997, 12, d)),
      ...[2, 15].map((d) => LocalDate(1998, 1, d)),
    ],
  );
  testRecurring(
    'Monthly on the first and last day of the month for 10 occurrences:',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      count: 10,
      byMonthDays: {1, -1},
    ),
    start: LocalDateTime(1997, 9, 30, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 9, 30),
      ...[1, 31].map((d) => LocalDate(1997, 10, d)),
      ...[1, 30].map((d) => LocalDate(1997, 11, d)),
      ...[1, 31].map((d) => LocalDate(1997, 12, d)),
      ...[1, 31].map((d) => LocalDate(1998, 1, d)),
      LocalDate(1998, 2, 1),
    ],
  );
  testRecurring(
    'Every 18 months on the 10th thru 15th of the month for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      count: 10,
      interval: 18,
      byMonthDays: {10, 11, 12, 13, 14, 15},
    ),
    start: LocalDateTime(1997, 9, 10, 9, 0, 0),
    expectedDates: [
      ...10.to(16).map((d) => LocalDate(1997, 9, d)),
      ...10.to(14).map((d) => LocalDate(1999, 3, d)),
    ],
  );
  testRecurring(
    'Every Tuesday, every other month',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      interval: 2,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.tuesday)},
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...[2, 9, 16, 23, 30].map((d) => LocalDate(1997, 9, d)),
      ...[4, 11, 18, 25].map((d) => LocalDate(1997, 11, d)),
      ...[6, 13, 20, 27].map((d) => LocalDate(1998, 1, d)),
      ...[3, 10, 17, 24, 31].map((d) => LocalDate(1998, 3, d)),
    ],
    isInfinite: true,
  );
  testRecurring(
    'Yearly in June and July for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: Frequency.yearly,
      count: 10,
      byMonths: {6, 7},
    ),
    start: LocalDateTime(1997, 6, 10, 9, 0, 0),
    expectedDates: 1997.to(2002).expand((y) {
      return [6, 7].map((m) => LocalDate(y, m, 10));
    }),
  );
  testRecurring(
    'Every other year on January, February, and March for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: Frequency.yearly,
      count: 10,
      interval: 2,
      byMonths: {1, 2, 3},
    ),
    start: LocalDateTime(1997, 3, 10, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 3, 10),
      ...1999.to(2004, by: 2).expand((y) {
        return 1.to(4).map((m) => LocalDate(y, m, 10));
      }),
    ],
  );
  testRecurring(
    'Every third year on the 1st, 100th, and 200th day for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: Frequency.yearly,
      count: 10,
      interval: 3,
      byYearDays: {1, 100, 200},
    ),
    start: LocalDateTime(1997, 1, 1, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 1, 1),
      LocalDate(1997, 4, 10),
      LocalDate(1997, 7, 19),
      LocalDate(2000, 1, 1),
      LocalDate(2000, 4, 9),
      LocalDate(2000, 7, 18),
      LocalDate(2003, 1, 1),
      LocalDate(2003, 4, 10),
      LocalDate(2003, 7, 19),
      LocalDate(2006, 1, 1),
    ],
  );
  testRecurring(
    'Every 20th Monday of the year, forever',
    rrule: RecurrenceRule(
      frequency: Frequency.yearly,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.monday, 20)},
    ),
    start: LocalDateTime(1997, 5, 19, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 5, 19),
      LocalDate(1998, 5, 18),
      LocalDate(1999, 5, 17),
    ],
    isInfinite: true,
  );
  testRecurring(
    'Monday of week number 20 (where the default start of the week is Monday), forever',
    rrule: RecurrenceRule(
      frequency: Frequency.yearly,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.monday)},
      byWeeks: {20},
    ),
    start: LocalDateTime(1997, 5, 12, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 5, 12),
      LocalDate(1998, 5, 11),
      LocalDate(1999, 5, 17),
    ],
    isInfinite: true,
  );
  testRecurring(
    'Every Thursday in March, forever',
    rrule: RecurrenceRule(
      frequency: Frequency.yearly,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.thursday)},
      byMonths: {3},
    ),
    start: LocalDateTime(1997, 3, 13, 9, 0, 0),
    expectedDates: [
      ...[13, 20, 27].map((d) => LocalDate(1997, 3, d)),
      ...[5, 12, 19, 26].map((d) => LocalDate(1998, 3, d)),
      ...[4, 11, 18, 25].map((d) => LocalDate(1999, 3, d)),
    ],
    isInfinite: true,
  );
  testRecurring(
    'Every Thursday, but only during June, July, and August, forever',
    rrule: RecurrenceRule(
      frequency: Frequency.yearly,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.thursday)},
      byMonths: {6, 7, 8},
    ),
    start: LocalDateTime(1997, 6, 5, 9, 0, 0),
    expectedDates: [
      ...[5, 12, 19, 26].map((d) => LocalDate(1997, 6, d)),
      ...[3, 10, 17, 24, 31].map((d) => LocalDate(1997, 7, d)),
      ...[7, 14, 21, 28].map((d) => LocalDate(1997, 8, d)),
      ...[4, 11, 18, 25].map((d) => LocalDate(1998, 6, d)),
      ...[2, 9, 16, 23, 30].map((d) => LocalDate(1998, 7, d)),
      ...[6, 13, 20, 27].map((d) => LocalDate(1998, 8, d)),
      ...[3, 10, 17, 24].map((d) => LocalDate(1999, 6, d)),
      ...[1, 8, 15, 22, 29].map((d) => LocalDate(1999, 7, d)),
      ...[5, 12, 19, 26].map((d) => LocalDate(1999, 8, d)),
    ],
    isInfinite: true,
  );
  // Note: the orginal includes an EXDATE for the start, but our implementation
  // doesn't require the start to be in the result set.
  testRecurring(
    'Every Friday the 13th, forever',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.friday)},
      byMonthDays: {13},
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      LocalDate(1998, 2, 13),
      LocalDate(1998, 3, 13),
      LocalDate(1998, 11, 13),
      LocalDate(1999, 8, 13),
      LocalDate(2000, 10, 13),
    ],
    isInfinite: true,
  );
  testRecurring(
    'The first Saturday that follows the first Sunday of the month, forever',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.saturday)},
      byMonthDays: {7, 8, 9, 10, 11, 12, 13},
    ),
    start: LocalDateTime(1997, 9, 13, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 9, 13),
      LocalDate(1997, 10, 11),
      LocalDate(1997, 11, 8),
      LocalDate(1997, 12, 13),
      LocalDate(1998, 1, 10),
      LocalDate(1998, 2, 7),
      LocalDate(1998, 3, 7),
      LocalDate(1998, 4, 11),
      LocalDate(1998, 5, 9),
      LocalDate(1998, 6, 13),
    ],
    isInfinite: true,
  );
  testRecurring(
    'Every 4 years, the first Tuesday after a Monday in November, forever (U.S. Presidential Election day)',
    rrule: RecurrenceRule(
      frequency: Frequency.yearly,
      interval: 4,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.tuesday)},
      byMonthDays: {2, 3, 4, 5, 6, 7, 8},
      byMonths: {11},
    ),
    start: LocalDateTime(1996, 11, 5, 9, 0, 0),
    expectedDates: [
      LocalDate(1996, 11, 5),
      LocalDate(2000, 11, 7),
      LocalDate(2004, 11, 2),
    ],
    isInfinite: true,
  );
  testRecurring(
    'The third instance into the month of one of Tuesday, Wednesday, or Thursday, for the next 3 months',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      count: 3,
      byWeekDays: {
        ByWeekDayEntry(DayOfWeek.tuesday),
        ByWeekDayEntry(DayOfWeek.wednesday),
        ByWeekDayEntry(DayOfWeek.thursday),
      },
      bySetPositions: {3},
    ),
    start: LocalDateTime(1997, 9, 4, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 9, 4),
      LocalDate(1997, 10, 7),
      LocalDate(1997, 11, 6),
    ],
  );
  testRecurring(
    'The second-to-last weekday of the month',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      byWeekDays: {
        ByWeekDayEntry(DayOfWeek.monday),
        ByWeekDayEntry(DayOfWeek.tuesday),
        ByWeekDayEntry(DayOfWeek.wednesday),
        ByWeekDayEntry(DayOfWeek.thursday),
        ByWeekDayEntry(DayOfWeek.friday),
      },
      bySetPositions: {-2},
    ),
    start: LocalDateTime(1997, 9, 29, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 9, 29),
      LocalDate(1997, 10, 30),
      LocalDate(1997, 11, 27),
      LocalDate(1997, 12, 30),
      LocalDate(1998, 1, 29),
      LocalDate(1998, 2, 26),
      LocalDate(1998, 3, 30),
    ],
    isInfinite: true,
  );
  testRecurring(
    'Every 3 hours from 9:00 AM to 5:00 PM on a specific day',
    rrule: RecurrenceRule(
      frequency: Frequency.hourly,
      until: LocalDateTime(1997, 09, 02, 17, 0, 0),
      interval: 3,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDateTimes:
        9.to(16, by: 3).map((h) => LocalDateTime(1997, 9, 2, h, 0, 0)),
  );
  testRecurring(
    'Every 15 minutes for 6 occurrences',
    rrule: RecurrenceRule(
      frequency: Frequency.minutely,
      count: 6,
      interval: 15,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDateTimes: [
      LocalTime(9, 0, 0),
      LocalTime(9, 15, 0),
      LocalTime(9, 30, 0),
      LocalTime(9, 45, 0),
      LocalTime(10, 0, 0),
      LocalTime(10, 15, 0),
    ].map((t) => LocalDate(1997, 9, 2).at(t)),
  );
  testRecurring(
    'Every hour and a half for 4 occurrences',
    rrule: RecurrenceRule(
      frequency: Frequency.minutely,
      count: 4,
      interval: 90,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDateTimes: [
      LocalTime(9, 0, 0),
      LocalTime(10, 30, 0),
      LocalTime(12, 00, 0),
      LocalTime(13, 30, 0),
    ].map((t) => LocalDate(1997, 9, 2).at(t)),
  );
  group('Every 20 minutes from 9:00 AM to 4:40 PM every day', () {
    final expected = [2, 3].expand((d) {
      return 9.to(17).expand((h) {
        return 0.to(41, by: 20).map((m) => LocalDateTime(1997, 9, d, h, m, 0));
      });
    });
    testRecurring(
      'with frequency daily',
      rrule: RecurrenceRule(
        frequency: Frequency.daily,
        byMinutes: {0, 20, 40},
        byHours: {9, 10, 11, 12, 13, 14, 15, 16},
      ),
      start: LocalDateTime(1997, 9, 2, 9, 0, 0),
      expectedDateTimes: expected,
      isInfinite: true,
    );
    testRecurring(
      'with frequency minutely',
      rrule: RecurrenceRule(
        frequency: Frequency.minutely,
        interval: 20,
        byHours: {9, 10, 11, 12, 13, 14, 15, 16},
      ),
      start: LocalDateTime(1997, 9, 2, 9, 0, 0),
      expectedDateTimes: expected,
      isInfinite: true,
    );
  });
  group(
      'An example where the days generated makes a difference because of WKST',
      () {
    testRecurring(
      'with weekStart monday',
      rrule: RecurrenceRule(
        frequency: Frequency.weekly,
        count: 4,
        interval: 2,
        byWeekDays: {
          ByWeekDayEntry(DayOfWeek.tuesday),
          ByWeekDayEntry(DayOfWeek.sunday)
        },
        weekStart: DayOfWeek.monday,
      ),
      start: LocalDateTime(1997, 8, 5, 9, 0, 0),
      expectedDates: [5, 10, 19, 24].map((d) => LocalDate(1997, 8, d)),
    );
    testRecurring(
      'with weekStart sunday',
      rrule: RecurrenceRule(
        frequency: Frequency.weekly,
        count: 4,
        interval: 2,
        byWeekDays: {
          ByWeekDayEntry(DayOfWeek.tuesday),
          ByWeekDayEntry(DayOfWeek.sunday)
        },
        weekStart: DayOfWeek.sunday,
      ),
      start: LocalDateTime(1997, 8, 5, 9, 0, 0),
      expectedDates: [5, 17, 19, 31].map((d) => LocalDate(1997, 8, d)),
    );
  });
  testRecurring(
    'An example where an invalid date (i.e., February 30) is ignored',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      count: 5,
      byMonthDays: {15, 30},
    ),
    start: LocalDateTime(2007, 1, 15, 9, 0, 0),
    expectedDates: [
      LocalDate(2007, 1, 15),
      LocalDate(2007, 1, 30),
      LocalDate(2007, 2, 15),
      LocalDate(2007, 3, 15),
      LocalDate(2007, 3, 30),
    ],
  );
}
