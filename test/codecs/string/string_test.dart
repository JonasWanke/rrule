import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:test/test.dart';
import 'package:time_machine/time_machine.dart';

import '../utils.dart';

void main() {
  @isTestGroup
  void testCodec(
    String description, {
    @required RecurrenceRule rrule,
    @required String string,
  }) {
    testStringCodec(
      description,
      codec: RecurrenceRuleStringCodec(
        toStringOptions: RecurrenceRuleToStringOptions(isTimeUtc: true),
      ),
      value: rrule,
      string: string,
    );
  }

  // All examples taken from https://tools.ietf.org/html/rfc5545#section-3.8.5.3.
  // Some RRULE-strings had some fields reordered to match the production rule
  // (recur-rule-part) order and remain consistent. The original string is
  // prepended as a comment.
  testCodec(
    'Daily for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      count: 10,
    ),
    string: 'RRULE:FREQ=DAILY;COUNT=10',
  );
  testCodec(
    'Daily until December 24, 1997',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      until: LocalDate(1997, 12, 24).atMidnight(),
    ),
    string: 'RRULE:FREQ=DAILY;UNTIL=19971224T000000Z',
  );
  testCodec(
    'Every other day - forever',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      interval: 2,
    ),
    string: 'RRULE:FREQ=DAILY;INTERVAL=2',
  );
  testCodec(
    'Every 10 days, 5 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      count: 5,
      interval: 10,
    ),
    // RRULE:FREQ=DAILY;INTERVAL=10;COUNT=5
    string: 'RRULE:FREQ=DAILY;COUNT=5;INTERVAL=10',
  );
  group('Every day in January, for 3 years', () {
    testCodec(
      'with frequency yearly',
      rrule: RecurrenceRule(
        frequency: RecurrenceFrequency.yearly,
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
      // RRULE:FREQ=YEARLY;UNTIL=20000131T140000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA
      string:
          'RRULE:FREQ=YEARLY;UNTIL=20000131T140000Z;BYDAY=MO,TU,WE,TH,FR,SA,SU;BYMONTH=1',
    );
    testCodec(
      'with frequency daily',
      rrule: RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        until: LocalDateTime(2000, 01, 31, 14, 0, 0),
        byMonths: {1},
      ),
      string: 'RRULE:FREQ=DAILY;UNTIL=20000131T140000Z;BYMONTH=1',
    );
  });
  testCodec(
    'Weekly for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      count: 10,
    ),
    string: 'RRULE:FREQ=WEEKLY;COUNT=10',
  );
  testCodec(
    'Weekly until December 24, 1997',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      until: LocalDate(1997, 12, 24).atMidnight(),
    ),
    string: 'RRULE:FREQ=WEEKLY;UNTIL=19971224T000000Z',
  );
  testCodec(
    'Every other week - forever',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      interval: 2,
      weekStart: DayOfWeek.sunday,
    ),
    string: 'RRULE:FREQ=WEEKLY;INTERVAL=2;WKST=SU',
  );
  group('Weekly on Tuesday and Thursday for five weeks', () {
    testCodec(
      'with until',
      rrule: RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        until: LocalDate(1997, 10, 07).atMidnight(),
        weekStart: DayOfWeek.sunday,
        byWeekDays: {
          ByWeekDayEntry(DayOfWeek.tuesday),
          ByWeekDayEntry(DayOfWeek.thursday),
        },
      ),
      // RRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH
      string: 'RRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;BYDAY=TU,TH;WKST=SU',
    );
    testCodec(
      'with count',
      rrule: RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        count: 10,
        byWeekDays: {
          ByWeekDayEntry(DayOfWeek.tuesday),
          ByWeekDayEntry(DayOfWeek.thursday),
        },
        weekStart: DayOfWeek.sunday,
      ),
      // RRULE:FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH
      string: 'RRULE:FREQ=WEEKLY;COUNT=10;BYDAY=TU,TH;WKST=SU',
    );
  });
  testCodec(
    'Every other week on Monday, Wednesday, and Friday until December 24, 1997',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      until: LocalDate(1997, 12, 24).atMidnight(),
      interval: 2,
      byWeekDays: {
        ByWeekDayEntry(DayOfWeek.monday),
        ByWeekDayEntry(DayOfWeek.wednesday),
        ByWeekDayEntry(DayOfWeek.friday),
      },
      weekStart: DayOfWeek.sunday,
    ),
    // RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;BYDAY=MO,WE,FR
    string:
        'RRULE:FREQ=WEEKLY;UNTIL=19971224T000000Z;INTERVAL=2;BYDAY=MO,WE,FR;WKST=SU',
  );
  testCodec(
    'Every other week on Tuesday and Thursday, for 8 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      count: 8,
      interval: 2,
      byWeekDays: {
        ByWeekDayEntry(DayOfWeek.tuesday),
        ByWeekDayEntry(DayOfWeek.thursday),
      },
      weekStart: DayOfWeek.sunday,
    ),
    // RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH
    string: 'RRULE:FREQ=WEEKLY;COUNT=8;INTERVAL=2;BYDAY=TU,TH;WKST=SU',
  );
  testCodec(
    'Monthly on the first Friday for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      count: 10,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.friday, 1)},
    ),
    string: 'RRULE:FREQ=MONTHLY;COUNT=10;BYDAY=1FR',
  );
  testCodec(
    'Monthly on the first Friday until December 24, 1997',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      until: LocalDate(1997, 12, 24).atMidnight(),
      byWeekDays: {ByWeekDayEntry(DayOfWeek.friday, 1)},
    ),
    string: 'RRULE:FREQ=MONTHLY;UNTIL=19971224T000000Z;BYDAY=1FR',
  );
  testCodec(
    'Every other month on the first and last Sunday of the month for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      count: 10,
      interval: 2,
      byWeekDays: {
        ByWeekDayEntry(DayOfWeek.sunday, 1),
        ByWeekDayEntry(DayOfWeek.sunday, -1),
      },
    ),
    // RRULE:FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU
    string: 'RRULE:FREQ=MONTHLY;COUNT=10;INTERVAL=2;BYDAY=-1SU,1SU',
  );
  testCodec(
    'Monthly on the second-to-last Monday of the month for 6 months',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      count: 6,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.monday, -2)},
    ),
    string: 'RRULE:FREQ=MONTHLY;COUNT=6;BYDAY=-2MO',
  );
  testCodec(
    'Monthly on the third-to-the-last day of the month, forever',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      byMonthDays: {-3},
    ),
    string: 'RRULE:FREQ=MONTHLY;BYMONTHDAY=-3',
  );
  testCodec(
    'Monthly on the 2nd and 15th of the month for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      count: 10,
      byMonthDays: {2, 15},
    ),
    string: 'RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15',
  );
  testCodec(
    'Monthly on the first and last day of the month for 10 occurrences:',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      count: 10,
      byMonthDays: {1, -1},
    ),
    // RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1
    string: 'RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=-1,1',
  );
  testCodec(
    'Every 18 months on the 10th thru 15th of the month for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      count: 10,
      interval: 18,
      byMonthDays: {10, 11, 12, 13, 14, 15},
    ),
    // RRULE:FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,15
    string:
        'RRULE:FREQ=MONTHLY;COUNT=10;INTERVAL=18;BYMONTHDAY=10,11,12,13,14,15',
  );
  testCodec(
    'Every Tuesday, every other month',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      interval: 2,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.tuesday)},
    ),
    string: 'RRULE:FREQ=MONTHLY;INTERVAL=2;BYDAY=TU',
  );
  testCodec(
    'Yearly in June and July for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.yearly,
      count: 10,
      byMonths: {6, 7},
    ),
    string: 'RRULE:FREQ=YEARLY;COUNT=10;BYMONTH=6,7',
  );
  testCodec(
    'Every other year on January, February, and March for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.yearly,
      count: 10,
      interval: 2,
      byMonths: {1, 2, 3},
    ),
    // RRULE:FREQ=YEARLY;INTERVAL=2;COUNT=10;BYMONTH=1,2,3
    string: 'RRULE:FREQ=YEARLY;COUNT=10;INTERVAL=2;BYMONTH=1,2,3',
  );
  testCodec(
    'Every third year on the 1st, 100th, and 200th day for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.yearly,
      count: 10,
      interval: 3,
      byYearDays: {1, 100, 200},
    ),
    // RRULE:FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200
    string: 'RRULE:FREQ=YEARLY;COUNT=10;INTERVAL=3;BYYEARDAY=1,100,200',
  );
  testCodec(
    'Every 20th Monday of the year, forever',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.yearly,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.monday, 20)},
    ),
    string: 'RRULE:FREQ=YEARLY;BYDAY=20MO',
  );
  testCodec(
    'Monday of week number 20 (where the default start of the week is Monday), forever',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.yearly,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.monday)},
      byWeeks: {20},
    ),
    // RRULE:FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO
    string: 'RRULE:FREQ=YEARLY;BYDAY=MO;BYWEEKNO=20',
  );
  testCodec(
    'Every Thursday in March, forever',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.yearly,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.thursday)},
      byMonths: {3},
    ),
    // RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=TH
    string: 'RRULE:FREQ=YEARLY;BYDAY=TH;BYMONTH=3',
  );
  testCodec(
    'Every Thursday, but only during June, July, and August, forever',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.yearly,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.thursday)},
      byMonths: {6, 7, 8},
    ),
    string: 'RRULE:FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8',
  );
  testCodec(
    'Every Friday the 13th, forever',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.friday)},
      byMonthDays: {13},
    ),
    string: 'RRULE:FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13',
  );
  testCodec(
    'The first Saturday that follows the first Sunday of the month, forever',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.saturday)},
      byMonthDays: {7, 8, 9, 10, 11, 12, 13},
    ),
    string: 'RRULE:FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13',
  );
  testCodec(
    'Every 4 years, the first Tuesday after a Monday in November, forever (U.S. Presidential Election day)',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.yearly,
      interval: 4,
      byWeekDays: {ByWeekDayEntry(DayOfWeek.tuesday)},
      byMonthDays: {2, 3, 4, 5, 6, 7, 8},
      byMonths: {11},
    ),
    // RRULE:FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8
    string:
        'RRULE:FREQ=YEARLY;INTERVAL=4;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8;BYMONTH=11',
  );
  testCodec(
    'The third instance into the month of one of Tuesday, Wednesday, or Thursday, for the next 3 months',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      count: 3,
      byWeekDays: {
        ByWeekDayEntry(DayOfWeek.tuesday),
        ByWeekDayEntry(DayOfWeek.wednesday),
        ByWeekDayEntry(DayOfWeek.thursday),
      },
      bySetPositions: {3},
    ),
    string: 'RRULE:FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3',
  );
  testCodec(
    'The second-to-last weekday of the month',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      byWeekDays: {
        ByWeekDayEntry(DayOfWeek.monday),
        ByWeekDayEntry(DayOfWeek.tuesday),
        ByWeekDayEntry(DayOfWeek.wednesday),
        ByWeekDayEntry(DayOfWeek.thursday),
        ByWeekDayEntry(DayOfWeek.friday),
      },
      bySetPositions: {-2},
    ),
    string: 'RRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2',
  );
  testCodec(
    'Every 3 hours from 9:00 AM to 5:00 PM on a specific day',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.hourly,
      until: LocalDateTime(1997, 09, 02, 17, 0, 0),
      interval: 3,
    ),
    // RRULE:FREQ=HOURLY;INTERVAL=3;UNTIL=19970902T170000Z
    string: 'RRULE:FREQ=HOURLY;UNTIL=19970902T170000Z;INTERVAL=3',
  );
  testCodec(
    'Every 15 minutes for 6 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.minutely,
      count: 6,
      interval: 15,
    ),
    // RRULE:FREQ=MINUTELY;INTERVAL=15;COUNT=6
    string: 'RRULE:FREQ=MINUTELY;COUNT=6;INTERVAL=15',
  );
  testCodec(
    'Every hour and a half for 4 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.minutely,
      count: 4,
      interval: 90,
    ),
    // RRULE:FREQ=MINUTELY;INTERVAL=90;COUNT=4
    string: 'RRULE:FREQ=MINUTELY;COUNT=4;INTERVAL=90',
  );
  group('Every 20 minutes from 9:00 AM to 4:40 PM every day', () {
    testCodec(
      'with frequency daily',
      rrule: RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        byMinutes: {0, 20, 40},
        byHours: {9, 10, 11, 12, 13, 14, 15, 16},
      ),
      // RRULE:FREQ=DAILY;BYHOUR=9,10,11,12,13,14,15,16;BYMINUTE=0,20,40
      string: 'RRULE:FREQ=DAILY;BYMINUTE=0,20,40;BYHOUR=9,10,11,12,13,14,15,16',
    );
    testCodec(
      'with frequency minutely',
      rrule: RecurrenceRule(
        frequency: RecurrenceFrequency.minutely,
        interval: 20,
        byHours: {9, 10, 11, 12, 13, 14, 15, 16},
      ),
      string: 'RRULE:FREQ=MINUTELY;INTERVAL=20;BYHOUR=9,10,11,12,13,14,15,16',
    );
  });
  group(
      'An example where the days generated makes a difference because of WKST',
      () {
    testCodec(
      'with weekStart monday',
      rrule: RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        count: 4,
        interval: 2,
        byWeekDays: {
          ByWeekDayEntry(DayOfWeek.tuesday),
          ByWeekDayEntry(DayOfWeek.sunday)
        },
        weekStart: DayOfWeek.monday,
      ),
      // RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=MO
      string: 'RRULE:FREQ=WEEKLY;COUNT=4;INTERVAL=2;BYDAY=TU,SU;WKST=MO',
    );
    testCodec(
      'with weekStart sunday',
      rrule: RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        count: 4,
        interval: 2,
        byWeekDays: {
          ByWeekDayEntry(DayOfWeek.tuesday),
          ByWeekDayEntry(DayOfWeek.sunday)
        },
        weekStart: DayOfWeek.sunday,
      ),
      // RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=SU
      string: 'RRULE:FREQ=WEEKLY;COUNT=4;INTERVAL=2;BYDAY=TU,SU;WKST=SU',
    );
  });
  testCodec(
    'An example where an invalid date (i.e., February 30) is ignored',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      count: 5,
      byMonthDays: {15, 30},
    ),
    // RRULE:FREQ=MONTHLY;BYMONTHDAY=15,30;COUNT=5
    string: 'RRULE:FREQ=MONTHLY;COUNT=5;BYMONTHDAY=15,30',
  );
}
