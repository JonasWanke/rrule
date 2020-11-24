import 'package:basics/basics.dart';
import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:test/test.dart';
import 'package:time_machine/time_machine.dart';

import 'utils.dart' as utils;

void main() {
  setUpAll(TimeMachine.initialize);
  RruleL10n l10n;

  setUp(() async => l10n = await RruleL10nEn.create());

  @isTestGroup
  void testRrule(
    String description, {
    @required String string,
    @required String text,
    @required RecurrenceRule rrule,
    @required LocalDateTime start,
    Iterable<LocalDate> expectedDates,
    Iterable<LocalDateTime> expectedDateTimes,
    bool isInfinite = false,
  }) {
    utils.testRrule(
      description,
      string: string,
      text: text,
      rrule: rrule,
      start: start,
      expectedDates: expectedDates,
      expectedDateTimes: expectedDateTimes,
      isInfinite: isInfinite,
      l10n: l10n,
    );
  }

  // All examples taken from https://tools.ietf.org/html/rfc5545#section-3.8.5.3.
  // - Some RRULE-strings had some fields reordered to match the production rule
  //   (recur-rule-part) order and remain consistent. The original string is
  //   prepended as a comment.
  // - The `text` was added manually.
  testRrule(
    'Daily for 10 occurrences',
    string: 'RRULE:FREQ=DAILY;COUNT=10',
    text: 'Daily, 10 times',
    rrule: RecurrenceRule(
      frequency: Frequency.daily,
      count: 10,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: 2.to(12).map((d) => LocalDate(1997, 9, d)),
  );
  testRrule(
    'Daily until December 24, 1997',
    string: 'RRULE:FREQ=DAILY;UNTIL=19971224T000000Z',
    text: 'Daily, until Wednesday, December 24, 1997 12:00:00 AM',
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
  testRrule(
    'Every other day - forever',
    string: 'RRULE:FREQ=DAILY;INTERVAL=2',
    text: 'Every other day',
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
  testRrule(
    'Every 10 days, 5 occurrences',
    // RRULE:FREQ=DAILY;INTERVAL=10;COUNT=5
    string: 'RRULE:FREQ=DAILY;COUNT=5;INTERVAL=10',
    text: 'Every 10 days, 5 times',
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
    testRrule(
      'with frequency yearly',
      // RRULE:FREQ=YEARLY;UNTIL=20000131T140000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA
      string:
          'RRULE:FREQ=YEARLY;UNTIL=20000131T140000Z;BYDAY=MO,TU,WE,TH,FR,SA,SU;BYMONTH=1',
      text:
          'Annually on weekdays, every Saturday & Sunday in January, until Monday, January 31, 2000 2:00:00 PM',
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
    testRrule(
      'with frequency daily',
      string: 'RRULE:FREQ=DAILY;UNTIL=20000131T140000Z;BYMONTH=1',
      text: 'Daily in January, until Monday, January 31, 2000 2:00:00 PM',
      rrule: RecurrenceRule(
        frequency: Frequency.daily,
        until: LocalDateTime(2000, 01, 31, 14, 0, 0),
        byMonths: {1},
      ),
      start: LocalDateTime(1998, 1, 1, 9, 0, 0),
      expectedDates: expected,
    );
  });
  testRrule(
    'Weekly for 10 occurrences',
    string: 'RRULE:FREQ=WEEKLY;COUNT=10',
    text: 'Weekly, 10 times',
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
  testRrule(
    'Weekly until December 24, 1997',
    string: 'RRULE:FREQ=WEEKLY;UNTIL=19971224T000000Z',
    text: 'Weekly, until Wednesday, December 24, 1997 12:00:00 AM',
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
  testRrule(
    'Every other week - forever',
    string: 'RRULE:FREQ=WEEKLY;INTERVAL=2;WKST=SU',
    text: 'Every other week',
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
    testRrule(
      'with until',
      // RRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH
      string: 'RRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;BYDAY=TU,TH;WKST=SU',
      text:
          'Weekly on Tuesday & Thursday, until Tuesday, October 7, 1997 12:00:00 AM',
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
    testRrule(
      'with count',
      // RRULE:FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH
      string: 'RRULE:FREQ=WEEKLY;COUNT=10;BYDAY=TU,TH;WKST=SU',
      text: 'Weekly on Tuesday & Thursday, 10 times',
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
  testRrule(
    'Every other week on Monday, Wednesday, and Friday until December 24, 1997',
    // RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;BYDAY=MO,WE,FR
    string:
        'RRULE:FREQ=WEEKLY;UNTIL=19971224T000000Z;INTERVAL=2;BYDAY=MO,WE,FR;WKST=SU',
    text:
        'Every other week on Monday, Wednesday & Friday, until Wednesday, December 24, 1997 12:00:00 AM',
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
  testRrule(
    'Every other week on Tuesday and Thursday, for 8 occurrences',
    // RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH
    string: 'RRULE:FREQ=WEEKLY;COUNT=8;INTERVAL=2;BYDAY=TU,TH;WKST=SU',
    text: 'Every other week on Tuesday & Thursday, 8 times',
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
  testRrule(
    'Monthly on the first Friday for 10 occurrences',
    string: 'RRULE:FREQ=MONTHLY;COUNT=10;BYDAY=1FR',
    text: 'Monthly on the 1st Friday, 10 times',
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
  testRrule(
    'Monthly on the first Friday until December 24, 1997',
    string: 'RRULE:FREQ=MONTHLY;UNTIL=19971224T000000Z;BYDAY=1FR',
    text:
        'Monthly on the 1st Friday, until Wednesday, December 24, 1997 12:00:00 AM',
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
  testRrule(
    'Every other month on the first and last Sunday of the month for 10 occurrences',
    // RRULE:FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU
    string: 'RRULE:FREQ=MONTHLY;COUNT=10;INTERVAL=2;BYDAY=-1SU,1SU',
    text: 'Every other month on the 1st & last Sunday, 10 times',
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
  testRrule(
    'Monthly on the second-to-last Monday of the month for 6 months',
    string: 'RRULE:FREQ=MONTHLY;COUNT=6;BYDAY=-2MO',
    text: 'Monthly on the 2nd-to-last Monday, 6 times',
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
  testRrule(
    'Monthly on the third-to-the-last day of the month, forever',
    string: 'RRULE:FREQ=MONTHLY;BYMONTHDAY=-3',
    text: 'Monthly on the 3rd-to-last day',
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
  testRrule(
    'Monthly on the 2nd and 15th of the month for 10 occurrences',
    string: 'RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15',
    text: 'Monthly on the 2nd & 15th, 10 times',
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
  testRrule(
    'Monthly on the first and last day of the month for 10 occurrences:',
    // RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1
    string: 'RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=-1,1',
    text: 'Monthly on the 1st & last day, 10 times',
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
  testRrule(
    'Every 18 months on the 10th thru 15th of the month for 10 occurrences',
    // RRULE:FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,15
    string:
        'RRULE:FREQ=MONTHLY;COUNT=10;INTERVAL=18;BYMONTHDAY=10,11,12,13,14,15',
    text: 'Every 18 months on the 10th – 15th, 10 times',
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
  testRrule(
    'Every Tuesday, every other month',
    string: 'RRULE:FREQ=MONTHLY;INTERVAL=2;BYDAY=TU',
    text: 'Every other month on every Tuesday',
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
  testRrule(
    'Yearly in June and July for 10 occurrences',
    string: 'RRULE:FREQ=YEARLY;COUNT=10;BYMONTH=6,7',
    text: 'Annually in June & July, 10 times',
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
  testRrule(
    'Every other year on January, February, and March for 10 occurrences',
    // RRULE:FREQ=YEARLY;INTERVAL=2;COUNT=10;BYMONTH=1,2,3
    string: 'RRULE:FREQ=YEARLY;COUNT=10;INTERVAL=2;BYMONTH=1,2,3',
    text: 'Every other year in January – March, 10 times',
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
  testRrule(
    'Every third year on the 1st, 100th, and 200th day for 10 occurrences',
    // RRULE:FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200
    string: 'RRULE:FREQ=YEARLY;COUNT=10;INTERVAL=3;BYYEARDAY=1,100,200',
    text: 'Every 3 years on the 1st, 100th & 200th day of the year, 10 times',
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
  testRrule(
    'Every 20th Monday of the year, forever',
    string: 'RRULE:FREQ=YEARLY;BYDAY=20MO',
    text: 'Annually on the 20th Monday of the year',
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
  testRrule(
    'Monday of week number 20 (where the default start of the week is Monday), forever',
    // RRULE:FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO
    string: 'RRULE:FREQ=YEARLY;BYDAY=MO;BYWEEKNO=20',
    text: 'Annually on Monday in the 20th week of the year',
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
  testRrule(
    'Every Thursday in March, forever',
    // RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=TH
    string: 'RRULE:FREQ=YEARLY;BYDAY=TH;BYMONTH=3',
    text: 'Annually on every Thursday in March',
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
  testRrule(
    'Every Thursday, but only during June, July, and August, forever',
    string: 'RRULE:FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8',
    text: 'Annually on every Thursday in June – August',
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
  testRrule(
    'Every Friday the 13th, forever',
    string: 'RRULE:FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13',
    text: 'Monthly on every Friday that are also the 13th',
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
  testRrule(
    'The first Saturday that follows the first Sunday of the month, forever',
    string: 'RRULE:FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13',
    text: 'Monthly on every Saturday that are also the 7th – 13th',
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
  testRrule(
    'Every 4 years, the first Tuesday after a Monday in November, forever (U.S. Presidential Election day)',
    // RRULE:FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8
    string:
        'RRULE:FREQ=YEARLY;INTERVAL=4;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8;BYMONTH=11',
    text:
        'Every 4 years on every Tuesday that are also the 2nd – 8th day of the month and that are also in November',
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
  testRrule(
    'The third instance into the month of one of Tuesday, Wednesday, or Thursday, for the next 3 months',
    string: 'RRULE:FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3',
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
  testRrule(
    'The second-to-last weekday of the month',
    string: 'RRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2',
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
  testRrule(
    'Every 3 hours from 9:00 AM to 5:00 PM on a specific day',
    // RRULE:FREQ=HOURLY;INTERVAL=3;UNTIL=19970902T170000Z
    string: 'RRULE:FREQ=HOURLY;UNTIL=19970902T170000Z;INTERVAL=3',
    rrule: RecurrenceRule(
      frequency: Frequency.hourly,
      until: LocalDateTime(1997, 09, 02, 17, 0, 0),
      interval: 3,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDateTimes:
        9.to(16, by: 3).map((h) => LocalDateTime(1997, 9, 2, h, 0, 0)),
  );
  testRrule(
    'Every 15 minutes for 6 occurrences',
    // RRULE:FREQ=MINUTELY;INTERVAL=15;COUNT=6
    string: 'RRULE:FREQ=MINUTELY;COUNT=6;INTERVAL=15',
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
  testRrule(
    'Every hour and a half for 4 occurrences',
    // RRULE:FREQ=MINUTELY;INTERVAL=90;COUNT=4
    string: 'RRULE:FREQ=MINUTELY;COUNT=4;INTERVAL=90',
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
    testRrule(
      'with frequency daily',
      // RRULE:FREQ=DAILY;BYHOUR=9,10,11,12,13,14,15,16;BYMINUTE=0,20,40
      string: 'RRULE:FREQ=DAILY;BYMINUTE=0,20,40;BYHOUR=9,10,11,12,13,14,15,16',
      rrule: RecurrenceRule(
        frequency: Frequency.daily,
        byMinutes: {0, 20, 40},
        byHours: {9, 10, 11, 12, 13, 14, 15, 16},
      ),
      start: LocalDateTime(1997, 9, 2, 9, 0, 0),
      expectedDateTimes: expected,
      isInfinite: true,
    );
    testRrule(
      'with frequency minutely',
      string: 'RRULE:FREQ=MINUTELY;INTERVAL=20;BYHOUR=9,10,11,12,13,14,15,16',
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
    testRrule(
      'with weekStart monday',
      // RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=MO
      string: 'RRULE:FREQ=WEEKLY;COUNT=4;INTERVAL=2;BYDAY=TU,SU;WKST=MO',
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
    testRrule(
      'with weekStart sunday',
      // RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=SU
      string: 'RRULE:FREQ=WEEKLY;COUNT=4;INTERVAL=2;BYDAY=TU,SU;WKST=SU',
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
  testRrule(
    'An example where an invalid date (i.e., February 30) is ignored',
    string: 'RRULE:FREQ=MONTHLY;COUNT=5;BYMONTHDAY=15,30',
    text: 'Monthly on the 15th & 30th, 5 times',
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
