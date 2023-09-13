import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:rrule/src/utils.dart';
import 'package:test/test.dart';

import 'utils.dart' as utils;

void main() {
  late final RruleL10n l10n;
  setUpAll(() async => l10n = await RruleL10nEn.create());

  @isTestGroup
  void testRrule(
    String description, {
    required String string,
    String? text,
    required RecurrenceRule rrule,
    required DateTime start,
    required Iterable<DateTime> expected,
    bool isInfinite = false,
    bool testNonLatin = false,
  }) {
    utils.testRrule(
      description,
      string: string,
      text: text,
      rrule: rrule,
      start: start,
      expected: expected,
      isInfinite: isInfinite,
      l10n: () => l10n,
      testNonLatin: testNonLatin,
    );
  }

  // Non-latin tests
  testRrule(
    'Daily until December 24, 1997 - Non-Latin',
    string: 'RRULE:FREQ=DAILY;UNTIL=19971224T000000Z',
    text: 'Daily, until Wednesday, December 24, 1997 12:00:00 AM',
    rrule: RecurrenceRule(
      frequency: Frequency.daily,
      until: DateTime.utc(1997, 12, 24),
    ),
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [
      ...2.until(31).map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
      ...1.until(32).map((d) => DateTime.utc(1997, 10, d, 9, 0, 0)),
      ...1.until(31).map((d) => DateTime.utc(1997, 11, d, 9, 0, 0)),
      ...1.until(24).map((d) => DateTime.utc(1997, 12, d, 9, 0, 0)),
    ],
    testNonLatin: true,
  );

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
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: 2.until(12).map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
  );
  testRrule(
    'Daily until December 24, 1997',
    string: 'RRULE:FREQ=DAILY;UNTIL=19971224T000000Z',
    text: 'Daily, until Wednesday, December 24, 1997 12:00:00 AM',
    rrule: RecurrenceRule(
      frequency: Frequency.daily,
      until: DateTime.utc(1997, 12, 24),
    ),
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [
      ...2.until(31).map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
      ...1.until(32).map((d) => DateTime.utc(1997, 10, d, 9, 0, 0)),
      ...1.until(31).map((d) => DateTime.utc(1997, 11, d, 9, 0, 0)),
      ...1.until(24).map((d) => DateTime.utc(1997, 12, d, 9, 0, 0)),
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
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [
      ...[2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]
          .map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
      ...[2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]
          .map((d) => DateTime.utc(1997, 10, d, 9, 0, 0)),
      ...[1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29]
          .map((d) => DateTime.utc(1997, 11, d, 9, 0, 0)),
      ...[1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31]
          .map((d) => DateTime.utc(1997, 12, d, 9, 0, 0)),
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
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [
      ...[2, 12, 22].map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
      ...[2, 12].map((d) => DateTime.utc(1997, 10, d, 9, 0, 0)),
    ],
  );
  group('Every day in January, for 3 years', () {
    final expected = 1998.rangeTo(2000).expand((y) {
      return 1.rangeTo(31).map((d) => DateTime.utc(y, 1, d, 9, 0, 0));
    }).toList();
    testRrule(
      'with frequency yearly',
      // RRULE:FREQ=YEARLY;UNTIL=20000131T140000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA
      string:
          'RRULE:FREQ=YEARLY;UNTIL=20000131T140000Z;BYDAY=MO,TU,WE,TH,FR,SA,SU;BYMONTH=1',
      text:
          'Annually on weekdays, every Saturday & Sunday in January, until Monday, January 31, 2000 2:00:00 PM',
      rrule: RecurrenceRule(
        frequency: Frequency.yearly,
        until: DateTime.utc(2000, 01, 31, 14, 0, 0),
        byWeekDays: {
          ByWeekDayEntry(DateTime.sunday),
          ByWeekDayEntry(DateTime.monday),
          ByWeekDayEntry(DateTime.tuesday),
          ByWeekDayEntry(DateTime.wednesday),
          ByWeekDayEntry(DateTime.thursday),
          ByWeekDayEntry(DateTime.friday),
          ByWeekDayEntry(DateTime.saturday),
        },
        byMonths: const {1},
      ),
      start: DateTime.utc(1998, 1, 1, 9, 0, 0),
      expected: expected,
    );
    testRrule(
      'with frequency daily',
      string: 'RRULE:FREQ=DAILY;UNTIL=20000131T140000Z;BYMONTH=1',
      text: 'Daily in January, until Monday, January 31, 2000 2:00:00 PM',
      rrule: RecurrenceRule(
        frequency: Frequency.daily,
        until: DateTime.utc(2000, 01, 31, 14, 0, 0),
        byMonths: const {1},
      ),
      start: DateTime.utc(1998, 1, 1, 9, 0, 0),
      expected: expected,
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
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [
      ...[2, 9, 16, 23, 30].map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
      ...[7, 14, 21, 28].map((d) => DateTime.utc(1997, 10, d, 9, 0, 0)),
      DateTime.utc(1997, 11, 4, 9, 0, 0),
    ],
  );
  testRrule(
    'Weekly until December 24, 1997',
    string: 'RRULE:FREQ=WEEKLY;UNTIL=19971224T000000Z',
    text: 'Weekly, until Wednesday, December 24, 1997 12:00:00 AM',
    rrule: RecurrenceRule(
      frequency: Frequency.weekly,
      until: DateTime.utc(1997, 12, 24),
    ),
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [
      ...[2, 9, 16, 23, 30].map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
      ...[7, 14, 21, 28].map((d) => DateTime.utc(1997, 10, d, 9, 0, 0)),
      ...[4, 11, 18, 25].map((d) => DateTime.utc(1997, 11, d, 9, 0, 0)),
      ...[2, 9, 16, 23].map((d) => DateTime.utc(1997, 12, d, 9, 0, 0)),
    ],
  );
  /*
  TODO(JonasWanke): Re-add these tests when we support WKST again.
  testRrule(
    'Every other week - forever',
    string: 'RRULE:FREQ=WEEKLY;INTERVAL=2;WKST=SU',
    text: 'Every other week',
    rrule: RecurrenceRule(
      frequency: Frequency.weekly,
      interval: 2,
      weekStart: DateTime.sunday,
    ),
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [
      ...[2, 16, 30].map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
      ...[14, 28].map((d) => DateTime.utc(1997, 10, d, 9, 0, 0)),
      ...[11, 25].map((d) => DateTime.utc(1997, 11, d, 9, 0, 0)),
      ...[9, 23].map((d) => DateTime.utc(1997, 12, d, 9, 0, 0)),
      ...[6, 20].map((d) => DateTime.utc(1998, 1, d, 9, 0, 0)),
      ...[3, 18].map((d) => DateTime.utc(1998, 2, d, 9, 0, 0)),
    ],
    isInfinite: true,
  );
  group('Weekly on Tuesday and Thursday for five weeks', () {
    final expected = [
      ...[2, 4, 9, 11, 16, 18, 23, 25, 30]
          .map((d) => DateTime.utc(1997, 09, d, 9, 0, 0)),
      DateTime.utc(1997, 10, 2, 9, 0, 0),
    ];
    testRrule(
      'with until',
      // RRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH
      string: 'RRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;BYDAY=TU,TH;WKST=SU',
      text:
          'Weekly on Tuesday & Thursday, until Tuesday, October 7, 1997 12:00:00 AM',
      rrule: RecurrenceRule(
        frequency: Frequency.weekly,
        until: DateTime.utc(1997, 10, 07),
        weekStart: DateTime.sunday,
        byWeekDays: {
          ByWeekDayEntry(DateTime.tuesday),
          ByWeekDayEntry(DateTime.thursday),
        },
      ),
      start: DateTime.utc(1997, 9, 2, 9, 0, 0),
      expected: expected,
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
          ByWeekDayEntry(DateTime.tuesday),
          ByWeekDayEntry(DateTime.thursday),
        },
        weekStart: DateTime.sunday,
      ),
      start: DateTime.utc(1997, 9, 2, 9, 0, 0),
      expected: expected,
    );
  });
  testRrule(
    'Every other week on Monday, Wednesday, and Friday until December 24, 1997',
    // RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;BYDAY=MO,WE,FR
    string:
        'RRULE:FREQ=WEEKLY;UNTIL=19971224T000000Z;INTERVAL=2;BYDAY=MO,WE,FR;WKST=SU',
    text:
        'Every other week on Monday, Wednesday & Friday, until Wednesday, December 24, 1997 12:00:00 AM',
    rrule: RecurrenceRule(
      frequency: Frequency.weekly,
      until: DateTime.utc(1997, 12, 24),
      interval: 2,
      byWeekDays: {
        ByWeekDayEntry(DateTime.monday),
        ByWeekDayEntry(DateTime.wednesday),
        ByWeekDayEntry(DateTime.friday),
      },
      weekStart: DateTime.sunday,
    ),
    start: DateTime.utc(1997, 9, 1, 9, 0, 0),
    expected: [
      ...[1, 3, 5, 15, 17, 19, 29]
          .map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
      ...[1, 3, 13, 15, 17, 27, 29, 31]
          .map((d) => DateTime.utc(1997, 10, d, 9, 0, 0)),
      ...[10, 12, 14, 24, 26, 28]
          .map((d) => DateTime.utc(1997, 11, d, 9, 0, 0)),
      ...[8, 10, 12, 22].map((d) => DateTime.utc(1997, 12, d, 9, 0, 0)),
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
        ByWeekDayEntry(DateTime.tuesday),
        ByWeekDayEntry(DateTime.thursday),
      },
      weekStart: DateTime.sunday,
    ),
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [
      ...[2, 4, 16, 18, 30].map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
      ...[2, 14, 16].map((d) => DateTime.utc(1997, 10, d, 9, 0, 0)),
    ],
  );
  */
  testRrule(
    'Monthly on the first Friday for 10 occurrences',
    string: 'RRULE:FREQ=MONTHLY;COUNT=10;BYDAY=1FR',
    text: 'Monthly on the 1st Friday, 10 times',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      count: 10,
      byWeekDays: {ByWeekDayEntry(DateTime.friday, 1)},
    ),
    start: DateTime.utc(1997, 9, 5, 9, 0, 0),
    expected: [
      DateTime.utc(1997, 9, 5, 9, 0, 0),
      DateTime.utc(1997, 10, 3, 9, 0, 0),
      DateTime.utc(1997, 11, 7, 9, 0, 0),
      DateTime.utc(1997, 12, 5, 9, 0, 0),
      DateTime.utc(1998, 1, 2, 9, 0, 0),
      DateTime.utc(1998, 2, 6, 9, 0, 0),
      DateTime.utc(1998, 3, 6, 9, 0, 0),
      DateTime.utc(1998, 4, 3, 9, 0, 0),
      DateTime.utc(1998, 5, 1, 9, 0, 0),
      DateTime.utc(1998, 6, 5, 9, 0, 0),
    ],
  );
  testRrule(
    'Monthly on the first Friday until December 24, 1997',
    string: 'RRULE:FREQ=MONTHLY;UNTIL=19971224T000000Z;BYDAY=1FR',
    text:
        'Monthly on the 1st Friday, until Wednesday, December 24, 1997 12:00:00 AM',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      until: DateTime.utc(1997, 12, 24),
      byWeekDays: {ByWeekDayEntry(DateTime.friday, 1)},
    ),
    start: DateTime.utc(1997, 9, 5, 9, 0, 0),
    expected: [
      DateTime.utc(1997, 9, 5, 9, 0, 0),
      DateTime.utc(1997, 10, 3, 9, 0, 0),
      DateTime.utc(1997, 11, 7, 9, 0, 0),
      DateTime.utc(1997, 12, 5, 9, 0, 0),
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
        ByWeekDayEntry(DateTime.sunday, 1),
        ByWeekDayEntry(DateTime.sunday, -1),
      },
    ),
    start: DateTime.utc(1997, 9, 7, 9, 0, 0),
    expected: [
      ...[7, 28].map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
      ...[2, 30].map((d) => DateTime.utc(1997, 11, d, 9, 0, 0)),
      ...[4, 25].map((d) => DateTime.utc(1998, 1, d, 9, 0, 0)),
      ...[1, 29].map((d) => DateTime.utc(1998, 3, d, 9, 0, 0)),
      ...[3, 31].map((d) => DateTime.utc(1998, 5, d, 9, 0, 0)),
    ],
  );
  testRrule(
    'Monthly on the second-to-last Monday of the month for 6 months',
    string: 'RRULE:FREQ=MONTHLY;COUNT=6;BYDAY=-2MO',
    text: 'Monthly on the 2nd-to-last Monday, 6 times',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      count: 6,
      byWeekDays: {ByWeekDayEntry(DateTime.monday, -2)},
    ),
    start: DateTime.utc(1997, 9, 22, 9, 0, 0),
    expected: [
      DateTime.utc(1997, 9, 22, 9, 0, 0),
      DateTime.utc(1997, 10, 20, 9, 0, 0),
      DateTime.utc(1997, 11, 17, 9, 0, 0),
      DateTime.utc(1997, 12, 22, 9, 0, 0),
      DateTime.utc(1998, 1, 19, 9, 0, 0),
      DateTime.utc(1998, 2, 16, 9, 0, 0),
    ],
  );
  testRrule(
    'Monthly on the third-to-the-last day of the month, forever',
    string: 'RRULE:FREQ=MONTHLY;BYMONTHDAY=-3',
    text: 'Monthly on the 3rd-to-last day',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      byMonthDays: const {-3},
    ),
    start: DateTime.utc(1997, 9, 28, 9, 0, 0),
    expected: [
      DateTime.utc(1997, 9, 28, 9, 0, 0),
      DateTime.utc(1997, 10, 29, 9, 0, 0),
      DateTime.utc(1997, 11, 28, 9, 0, 0),
      DateTime.utc(1997, 12, 29, 9, 0, 0),
      DateTime.utc(1998, 1, 29, 9, 0, 0),
      DateTime.utc(1998, 2, 26, 9, 0, 0),
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
      byMonthDays: const {2, 15},
    ),
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [
      ...[2, 15].map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
      ...[2, 15].map((d) => DateTime.utc(1997, 10, d, 9, 0, 0)),
      ...[2, 15].map((d) => DateTime.utc(1997, 11, d, 9, 0, 0)),
      ...[2, 15].map((d) => DateTime.utc(1997, 12, d, 9, 0, 0)),
      ...[2, 15].map((d) => DateTime.utc(1998, 1, d, 9, 0, 0)),
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
      byMonthDays: const {1, -1},
    ),
    start: DateTime.utc(1997, 9, 30, 9, 0, 0),
    expected: [
      DateTime.utc(1997, 9, 30, 9, 0, 0),
      ...[1, 31].map((d) => DateTime.utc(1997, 10, d, 9, 0, 0)),
      ...[1, 30].map((d) => DateTime.utc(1997, 11, d, 9, 0, 0)),
      ...[1, 31].map((d) => DateTime.utc(1997, 12, d, 9, 0, 0)),
      ...[1, 31].map((d) => DateTime.utc(1998, 1, d, 9, 0, 0)),
      DateTime.utc(1998, 2, 1, 9, 0, 0),
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
      byMonthDays: const {10, 11, 12, 13, 14, 15},
    ),
    start: DateTime.utc(1997, 9, 10, 9, 0, 0),
    expected: [
      ...10.until(16).map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
      ...10.until(14).map((d) => DateTime.utc(1999, 3, d, 9, 0, 0)),
    ],
  );
  testRrule(
    'Every Tuesday, every other month',
    string: 'RRULE:FREQ=MONTHLY;INTERVAL=2;BYDAY=TU',
    text: 'Every other month on every Tuesday',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      interval: 2,
      byWeekDays: {ByWeekDayEntry(DateTime.tuesday)},
    ),
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [
      ...[2, 9, 16, 23, 30].map((d) => DateTime.utc(1997, 9, d, 9, 0, 0)),
      ...[4, 11, 18, 25].map((d) => DateTime.utc(1997, 11, d, 9, 0, 0)),
      ...[6, 13, 20, 27].map((d) => DateTime.utc(1998, 1, d, 9, 0, 0)),
      ...[3, 10, 17, 24, 31].map((d) => DateTime.utc(1998, 3, d, 9, 0, 0)),
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
      byMonths: const {6, 7},
    ),
    start: DateTime.utc(1997, 6, 10, 9, 0, 0),
    expected: 1997.until(2002).expand((y) {
      return [6, 7].map((m) => DateTime.utc(y, m, 10, 9, 0, 0));
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
      byMonths: const {1, 2, 3},
    ),
    start: DateTime.utc(1997, 3, 10, 9, 0, 0),
    expected: [
      DateTime.utc(1997, 3, 10, 9, 0, 0),
      ...[1999, 2001, 2003].expand((y) {
        return 1.until(4).map((m) => DateTime.utc(y, m, 10, 9, 0, 0));
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
      byYearDays: const {1, 100, 200},
    ),
    start: DateTime.utc(1997, 1, 1, 9, 0, 0),
    expected: [
      DateTime.utc(1997, 1, 1, 9, 0, 0),
      DateTime.utc(1997, 4, 10, 9, 0, 0),
      DateTime.utc(1997, 7, 19, 9, 0, 0),
      DateTime.utc(2000, 1, 1, 9, 0, 0),
      DateTime.utc(2000, 4, 9, 9, 0, 0),
      DateTime.utc(2000, 7, 18, 9, 0, 0),
      DateTime.utc(2003, 1, 1, 9, 0, 0),
      DateTime.utc(2003, 4, 10, 9, 0, 0),
      DateTime.utc(2003, 7, 19, 9, 0, 0),
      DateTime.utc(2006, 1, 1, 9, 0, 0),
    ],
  );
  testRrule(
    'Every 20th Monday of the year, forever',
    string: 'RRULE:FREQ=YEARLY;BYDAY=20MO',
    text: 'Annually on the 20th Monday of the year',
    rrule: RecurrenceRule(
      frequency: Frequency.yearly,
      byWeekDays: {ByWeekDayEntry(DateTime.monday, 20)},
    ),
    start: DateTime.utc(1997, 5, 19, 9, 0, 0),
    expected: [
      DateTime.utc(1997, 5, 19, 9, 0, 0),
      DateTime.utc(1998, 5, 18, 9, 0, 0),
      DateTime.utc(1999, 5, 17, 9, 0, 0),
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
      byWeekDays: {ByWeekDayEntry(DateTime.monday)},
      byWeeks: const {20},
    ),
    start: DateTime.utc(1997, 5, 12, 9, 0, 0),
    expected: [
      DateTime.utc(1997, 5, 12, 9, 0, 0),
      DateTime.utc(1998, 5, 11, 9, 0, 0),
      DateTime.utc(1999, 5, 17, 9, 0, 0),
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
      byWeekDays: {ByWeekDayEntry(DateTime.thursday)},
      byMonths: const {3},
    ),
    start: DateTime.utc(1997, 3, 13, 9, 0, 0),
    expected: [
      ...[13, 20, 27].map((d) => DateTime.utc(1997, 3, d, 9, 0, 0)),
      ...[5, 12, 19, 26].map((d) => DateTime.utc(1998, 3, d, 9, 0, 0)),
      ...[4, 11, 18, 25].map((d) => DateTime.utc(1999, 3, d, 9, 0, 0)),
    ],
    isInfinite: true,
  );
  testRrule(
    'Every Thursday, but only during June, July, and August, forever',
    string: 'RRULE:FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8',
    text: 'Annually on every Thursday in June – August',
    rrule: RecurrenceRule(
      frequency: Frequency.yearly,
      byWeekDays: {ByWeekDayEntry(DateTime.thursday)},
      byMonths: const {6, 7, 8},
    ),
    start: DateTime.utc(1997, 6, 5, 9, 0, 0),
    expected: [
      ...[5, 12, 19, 26].map((d) => DateTime.utc(1997, 6, d, 9, 0, 0)),
      ...[3, 10, 17, 24, 31].map((d) => DateTime.utc(1997, 7, d, 9, 0, 0)),
      ...[7, 14, 21, 28].map((d) => DateTime.utc(1997, 8, d, 9, 0, 0)),
      ...[4, 11, 18, 25].map((d) => DateTime.utc(1998, 6, d, 9, 0, 0)),
      ...[2, 9, 16, 23, 30].map((d) => DateTime.utc(1998, 7, d, 9, 0, 0)),
      ...[6, 13, 20, 27].map((d) => DateTime.utc(1998, 8, d, 9, 0, 0)),
      ...[3, 10, 17, 24].map((d) => DateTime.utc(1999, 6, d, 9, 0, 0)),
      ...[1, 8, 15, 22, 29].map((d) => DateTime.utc(1999, 7, d, 9, 0, 0)),
      ...[5, 12, 19, 26].map((d) => DateTime.utc(1999, 8, d, 9, 0, 0)),
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
      byWeekDays: {ByWeekDayEntry(DateTime.friday)},
      byMonthDays: const {13},
    ),
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [
      DateTime.utc(1998, 2, 13, 9, 0, 0),
      DateTime.utc(1998, 3, 13, 9, 0, 0),
      DateTime.utc(1998, 11, 13, 9, 0, 0),
      DateTime.utc(1999, 8, 13, 9, 0, 0),
      DateTime.utc(2000, 10, 13, 9, 0, 0),
    ],
    isInfinite: true,
  );
  testRrule(
    'The first Saturday that follows the first Sunday of the month, forever',
    string: 'RRULE:FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13',
    text: 'Monthly on every Saturday that are also the 7th – 13th',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      byWeekDays: {ByWeekDayEntry(DateTime.saturday)},
      byMonthDays: const {7, 8, 9, 10, 11, 12, 13},
    ),
    start: DateTime.utc(1997, 9, 13, 9, 0, 0),
    expected: [
      DateTime.utc(1997, 9, 13, 9, 0, 0),
      DateTime.utc(1997, 10, 11, 9, 0, 0),
      DateTime.utc(1997, 11, 8, 9, 0, 0),
      DateTime.utc(1997, 12, 13, 9, 0, 0),
      DateTime.utc(1998, 1, 10, 9, 0, 0),
      DateTime.utc(1998, 2, 7, 9, 0, 0),
      DateTime.utc(1998, 3, 7, 9, 0, 0),
      DateTime.utc(1998, 4, 11, 9, 0, 0),
      DateTime.utc(1998, 5, 9, 9, 0, 0),
      DateTime.utc(1998, 6, 13, 9, 0, 0),
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
      byWeekDays: {ByWeekDayEntry(DateTime.tuesday)},
      byMonthDays: const {2, 3, 4, 5, 6, 7, 8},
      byMonths: const {11},
    ),
    start: DateTime.utc(1996, 11, 5, 9, 0, 0),
    expected: [
      DateTime.utc(1996, 11, 5, 9, 0, 0),
      DateTime.utc(2000, 11, 7, 9, 0, 0),
      DateTime.utc(2004, 11, 2, 9, 0, 0),
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
        ByWeekDayEntry(DateTime.tuesday),
        ByWeekDayEntry(DateTime.wednesday),
        ByWeekDayEntry(DateTime.thursday),
      },
      bySetPositions: const {3},
    ),
    start: DateTime.utc(1997, 9, 4, 9, 0, 0),
    expected: [
      DateTime.utc(1997, 9, 4, 9, 0, 0),
      DateTime.utc(1997, 10, 7, 9, 0, 0),
      DateTime.utc(1997, 11, 6, 9, 0, 0),
    ],
  );
  testRrule(
    'The second-to-last weekday of the month',
    string: 'RRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      byWeekDays: {
        ByWeekDayEntry(DateTime.monday),
        ByWeekDayEntry(DateTime.tuesday),
        ByWeekDayEntry(DateTime.wednesday),
        ByWeekDayEntry(DateTime.thursday),
        ByWeekDayEntry(DateTime.friday),
      },
      bySetPositions: const {-2},
    ),
    start: DateTime.utc(1997, 9, 29, 9, 0, 0),
    expected: [
      DateTime.utc(1997, 9, 29, 9, 0, 0),
      DateTime.utc(1997, 10, 30, 9, 0, 0),
      DateTime.utc(1997, 11, 27, 9, 0, 0),
      DateTime.utc(1997, 12, 30, 9, 0, 0),
      DateTime.utc(1998, 1, 29, 9, 0, 0),
      DateTime.utc(1998, 2, 26, 9, 0, 0),
      DateTime.utc(1998, 3, 30, 9, 0, 0),
    ],
    isInfinite: true,
  );
  testRrule(
    'Every 3 hours from 9:00 AM to 5:00 PM on a specific day',
    // RRULE:FREQ=HOURLY;INTERVAL=3;UNTIL=19970902T170000Z
    string: 'RRULE:FREQ=HOURLY;UNTIL=19970902T170000Z;INTERVAL=3',
    rrule: RecurrenceRule(
      frequency: Frequency.hourly,
      until: DateTime.utc(1997, 09, 02, 17, 0, 0),
      interval: 3,
    ),
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [9, 12, 15].map((h) => DateTime.utc(1997, 9, 2, h, 0, 0)),
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
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [
      const Duration(hours: 9, minutes: 0),
      const Duration(hours: 9, minutes: 15),
      const Duration(hours: 9, minutes: 30),
      const Duration(hours: 9, minutes: 45),
      const Duration(hours: 10, minutes: 0),
      const Duration(hours: 10, minutes: 15),
    ].map((t) => DateTime.utc(1997, 9, 2).add(t)),
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
    start: DateTime.utc(1997, 9, 2, 9, 0, 0),
    expected: [
      const Duration(hours: 9, minutes: 0),
      const Duration(hours: 10, minutes: 30),
      const Duration(hours: 12, minutes: 0),
      const Duration(hours: 13, minutes: 30),
    ].map((t) => DateTime.utc(1997, 9, 2).add(t)),
  );
  group('Every 20 minutes from 9:00 AM to 4:40 PM every day', () {
    final expected = [2, 3].expand((d) {
      return 9.until(17).expand((h) {
        return [0, 20, 40].map((m) => DateTime.utc(1997, 9, d, h, m, 0));
      });
    });
    testRrule(
      'with frequency daily',
      // RRULE:FREQ=DAILY;BYHOUR=9,10,11,12,13,14,15,16;BYMINUTE=0,20,40
      string: 'RRULE:FREQ=DAILY;BYMINUTE=0,20,40;BYHOUR=9,10,11,12,13,14,15,16',
      rrule: RecurrenceRule(
        frequency: Frequency.daily,
        byMinutes: const {0, 20, 40},
        byHours: const {9, 10, 11, 12, 13, 14, 15, 16},
      ),
      start: DateTime.utc(1997, 9, 2, 9, 0, 0),
      expected: expected,
      isInfinite: true,
    );
    testRrule(
      'with frequency minutely',
      string: 'RRULE:FREQ=MINUTELY;INTERVAL=20;BYHOUR=9,10,11,12,13,14,15,16',
      rrule: RecurrenceRule(
        frequency: Frequency.minutely,
        interval: 20,
        byHours: const {9, 10, 11, 12, 13, 14, 15, 16},
      ),
      start: DateTime.utc(1997, 9, 2, 9, 0, 0),
      expected: expected,
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
            ByWeekDayEntry(DateTime.tuesday),
            ByWeekDayEntry(DateTime.sunday),
          },
          weekStart: DateTime.monday,
        ),
        start: DateTime.utc(1997, 8, 5, 9, 0, 0),
        expected: [5, 10, 19, 24].map((d) => DateTime.utc(1997, 8, d, 9, 0, 0)),
      );
      /*
    TODO(JonasWanke): Re-add this test when we support WKST again.
    testRrule(
      'with weekStart sunday',
      // RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=SU
      string: 'RRULE:FREQ=WEEKLY;COUNT=4;INTERVAL=2;BYDAY=TU,SU;WKST=SU',
      rrule: RecurrenceRule(
        frequency: Frequency.weekly,
        count: 4,
        interval: 2,
        byWeekDays: {
          ByWeekDayEntry(DateTime.tuesday),
          ByWeekDayEntry(DateTime.sunday),
        },
        weekStart: DateTime.sunday,
      ),
      start: DateTime.utc(1997, 8, 5, 9, 0, 0),
      expected: [5, 17, 19, 31].map((d) => DateTime.utc(1997, 8, d, 9, 0, 0)),
    );
   */
    },
  );
  testRrule(
    'An example where an invalid date (i.e., February 30) is ignored',
    string: 'RRULE:FREQ=MONTHLY;COUNT=5;BYMONTHDAY=15,30',
    text: 'Monthly on the 15th & 30th, 5 times',
    rrule: RecurrenceRule(
      frequency: Frequency.monthly,
      count: 5,
      byMonthDays: const {15, 30},
    ),
    start: DateTime.utc(2007, 1, 15, 9, 0, 0),
    expected: [
      DateTime.utc(2007, 1, 15, 9, 0, 0),
      DateTime.utc(2007, 1, 30, 9, 0, 0),
      DateTime.utc(2007, 2, 15, 9, 0, 0),
      DateTime.utc(2007, 3, 15, 9, 0, 0),
      DateTime.utc(2007, 3, 30, 9, 0, 0),
    ],
  );
}
