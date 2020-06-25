import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:test/test.dart';
import 'package:time_machine/time_machine.dart';

import 'utils.dart' as utils;

void main() {
  setUpAll(TimeMachine.initialize);
  RruleL10n l10n;

  setUp(() async => l10n = await RruleL10nEn.withDefaultCulture());

  @isTest
  void testText(String text, {@required String string}) =>
      utils.testText(text, text: text, string: string, l10n: l10n);

  testText(
    'Weekly in January – March, August & September on Monday, Wednesday – Friday & Sunday',
    string: 'RRULE:FREQ=WEEKLY;BYMONTH=1,2,3,8,9;BYDAY=MO,WE,TH,FR,SU',
  );
  testText(
    'Every other week in January – March on weekdays & Sunday',
    string:
        'RRULE:FREQ=WEEKLY;INTERVAL=2;BYMONTH=1,2,3;BYDAY=MO,TU,WE,TH,FR,SU',
  );
  testText(
    'Monthly on every Monday – Wednesday, the 1st Thursday & Friday, the 2nd Thursday – Saturday, the 2nd-to-last Thursday, Friday & Sunday, and the last Thursday, Friday & Sunday that are also the 1st – 5th, 26th, or 3rd-to-last – last day of the month',
    string:
        'RRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,1TH,1FR,2TH,2FR,2SA,-2TH,-2FR,-2SU,-1TH,-1FR,-1SU;BYMONTHDAY=1,2,3,4,5,26,-3,-2,-1',
  );

  group('FREQ=YEARLY', () {
    // 0/1 digits in the comment before a text function mean whether each of
    // byMonths, byWeeks, byYearDays, byMonthDays & byWeekDays (in that order)
    // is included

    // 00000
    testText(
      'Annually',
      string: 'RRULE:FREQ=YEARLY',
    );
    // 00001
    testText(
      'Annually on every Monday & the last Thursday of the year',
      string: 'RRULE:FREQ=YEARLY;BYDAY=MO,-1TH',
    );
    // 00010
    testText(
      'Annually on the 1st & last day of the month',
      string: 'RRULE:FREQ=YEARLY;BYMONTHDAY=1,-1',
    );
    // 00011
    testText(
      'Annually on every Monday & the last Thursday of the year that are also the 1st or last day of the month',
      string: 'RRULE:FREQ=YEARLY;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
    );
    // 00100
    testText(
      'Annually on the 1st & last day of the year',
      string: 'RRULE:FREQ=YEARLY;BYYEARDAY=1,-1',
    );
    // 00101
    testText(
      'Annually on every Monday & the last Thursday of the year that are also the 1st or last day of the year',
      string: 'RRULE:FREQ=YEARLY;BYYEARDAY=1,-1;BYDAY=MO,-1TH',
    );
    // 00110
    testText(
      'Annually on the 1st & last day of the month that are also the 1st or last day of the year',
      string: 'RRULE:FREQ=YEARLY;BYYEARDAY=1,-1;BYMONTHDAY=1,-1',
    );
    // 00111
    testText(
      'Annually on every Monday & the last Thursday of the year that are also the 1st or last day of the month and that are also the 1st or last day of the year',
      string: 'RRULE:FREQ=YEARLY;BYYEARDAY=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
    );

    // 01000
    testText(
      'Annually in the 1st & last week of the year',
      string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1',
    );
    // 01001
    testText(
      'Annually on every Monday & Wednesday in the 1st & last week of the year',
      string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYDAY=MO,WE',
    );
    // 01010
    testText(
      'Annually on the 1st & last day of the month that are also in the 1st or last week of the year',
      string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYMONTHDAY=1,-1',
    );
    // 01011
    testText(
      'Annually on every Monday & Wednesday that are also the 1st or last day of the month and that are also in the 1st or last week of the year',
      string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,WE',
    );
    // 01100
    testText(
      'Annually on the 1st & last day of the year that are also in the 1st or last week of the year',
      string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYYEARDAY=1,-1',
    );
    // 01101
    testText(
      'Annually on every Monday & Wednesday that are also the 1st or last day of the year and that are also in the 1st or last week of the year',
      string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYDAY=MO,WE',
    );
    // 01110
    testText(
      'Annually on the 1st & last day of the month that are also the 1st or last day of the year and that are also in the 1st or last week of the year',
      string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYMONTHDAY=1,-1',
    );
    // 01111
    testText(
      'Annually on every Monday & Wednesday that are also the 1st or last day of the month, that are also the 1st or last day of the year, and that are also in the 1st or last week of the year',
      string:
          'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,WE',
    );

    // 10000
    testText(
      'Annually in January & December',
      string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12',
    );
    // 10001
    testText(
      'Annually on every Monday & the last Thursday of the month in January & December',
      string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYDAY=MO,-1TH',
    );
    // 10010
    testText(
      'Annually on the 1st & last day of the month in January & December',
      string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYMONTHDAY=1,-1',
    );
    // 10011
    // TODO(JonasWanke): the 1st or last day in January or December
    testText(
      'Annually on every Monday & the last Thursday of the year that are also the 1st or last day of the month and that are also in January or December',
      string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
    );
    // 10100
    testText(
      'Annually on the 1st & last day of the year that are also in January or December',
      string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYYEARDAY=1,-1',
    );
    // 10101
    testText(
      'Annually on every Monday & the last Thursday of the year that are also the 1st or last day of the year and that are also in January or December',
      string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYYEARDAY=1,-1;BYDAY=MO,-1TH',
    );
    // 10110
    testText(
      'Annually on the 1st & last day of the month that are also the 1st or last day of the year and that are also in January or December',
      string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYYEARDAY=1,-1;BYMONTHDAY=1,-1',
    );
    // 10111
    testText(
      'Annually on every Monday & the last Thursday of the year that are also the 1st or last day of the month, that are also the 1st or last day of the year, and that are also in January or December',
      string:
          'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYYEARDAY=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
    );

    // 11000
    testText(
      'Annually in the 1st & last week of the year that are also in January or December',
      string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1',
    );
    // 11001
    testText(
      'Annually on every Monday & Wednesday in the 1st & last week of the year that are also in January or December',
      string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYDAY=MO,WE',
    );
    // 11010
    testText(
      'Annually on the 1st & last day of the month that are also in the 1st or last week of the year and that are also in January or December',
      string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYMONTHDAY=1,-1',
    );
    // 11011
    testText(
      'Annually on every Monday & Wednesday that are also the 1st or last day of the month, that are also in the 1st or last week of the year, and that are also in January or December',
      string:
          'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,WE',
    );
    // 11100
    testText(
      'Annually on the 1st & last day of the year that are also in the 1st or last week of the year and that are also in January or December',
      string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYYEARDAY=1,-1',
    );
    // 11101
    testText(
      'Annually on every Monday & Wednesday that are also the 1st or last day of the year, that are also in the 1st or last week of the year, and that are also in January or December',
      string:
          'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYDAY=MO,WE',
    );
    // 11110
    testText(
      'Annually on the 1st & last day of the month that are also the 1st or last day of the year, that are also in the 1st or last week of the year, and that are also in January or December',
      string:
          'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYMONTHDAY=1,-1',
    );
    // 11111
    testText(
      'Annually on every Monday & Wednesday that are also the 1st or last day of the month, that are also the 1st or last day of the year, that are also in the 1st or last week of the year, and that are also in January or December',
      string:
          'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,WE',
    );
  });

  // All remaining examples taken from https://github.com/jakubroztocil/rrule/blob/3dc698300e5861311249e85e0e237708702b055d/test/nlp.test.ts,
  // though with modified texts.
  testText(
    'Hourly',
    string: 'RRULE:FREQ=HOURLY',
  );
  testText(
    'Every 4 hours',
    string: 'RRULE:INTERVAL=4;FREQ=HOURLY',
  );
  testText(
    'Daily',
    string: 'RRULE:FREQ=DAILY',
  );
  testText(
    'Weekly',
    string: 'RRULE:FREQ=WEEKLY',
  );
  testText(
    'Weekly, 20 times',
    string: 'RRULE:FREQ=WEEKLY;COUNT=20',
  );
  testText(
    'Weekly, until Monday, January 1, 2007 8:00:00 AM',
    string: 'RRULE:FREQ=WEEKLY;UNTIL=20070101T080000Z',
  );
  testText(
    'Weekly on Tuesday',
    string: 'RRULE:FREQ=WEEKLY;BYDAY=TU',
  );
  testText(
    'Weekly on Monday & Wednesday',
    string: 'RRULE:FREQ=WEEKLY;BYDAY=MO,WE',
  );
  testText(
    'Weekly on weekdays',
    string: 'RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',
  );
  testText(
    'Every other week',
    string: 'RRULE:INTERVAL=2;FREQ=WEEKLY',
  );
  testText(
    'Monthly',
    string: 'RRULE:FREQ=MONTHLY',
  );
  testText(
    'Monthly on the 4th',
    string: 'RRULE:FREQ=MONTHLY;BYMONTHDAY=4',
  );
  testText(
    'Monthly on the 4th-to-last day',
    string: 'RRULE:FREQ=MONTHLY;BYMONTHDAY=-4',
  );
  testText(
    'Monthly on the 3rd Tuesday',
    string: 'RRULE:FREQ=MONTHLY;BYDAY=+3TU',
  );
  testText(
    'Monthly on the 3rd-to-last Tuesday',
    string: 'RRULE:FREQ=MONTHLY;BYDAY=-3TU',
  );
  testText(
    'Monthly on the last Monday',
    string: 'RRULE:FREQ=MONTHLY;BYDAY=-1MO',
  );
  testText(
    'Monthly on the 2nd-to-last Friday',
    string: 'RRULE:FREQ=MONTHLY;BYDAY=-2FR',
  );
  testText(
    'Every 6 months',
    string: 'RRULE:INTERVAL=6;FREQ=MONTHLY',
  );
  testText(
    'Annually',
    string: 'RRULE:FREQ=YEARLY',
  );
  testText(
    'Annually on the 1st Friday of the year',
    string: 'RRULE:FREQ=YEARLY;BYDAY=+1FR',
  );
  testText(
    'Annually on the 13th Friday of the year',
    string: 'RRULE:FREQ=YEARLY;BYDAY=+13FR',
  );
}
