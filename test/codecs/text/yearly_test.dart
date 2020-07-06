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

  // 0/1 digits in the comment before a text function mean whether each of
  // bySetPositions, byMonths, byWeeks, byYearDays, byMonthDays & byWeekDays
  // (in that order) is included.

  // 000000
  testText(
    'Annually',
    string: 'RRULE:FREQ=YEARLY',
  );
  // 000001
  testText(
    'Annually on every Monday & the last Thursday of the year',
    string: 'RRULE:FREQ=YEARLY;BYDAY=MO,-1TH',
  );
  // 000010
  testText(
    'Annually on the 1st & last day of the month',
    string: 'RRULE:FREQ=YEARLY;BYMONTHDAY=1,-1',
  );
  // 000011
  testText(
    'Annually on every Monday & the last Thursday of the year that are also the 1st or last day of the month',
    string: 'RRULE:FREQ=YEARLY;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
  );
  // 000100
  testText(
    'Annually on the 1st & last day of the year',
    string: 'RRULE:FREQ=YEARLY;BYYEARDAY=1,-1',
  );
  // 000101
  testText(
    'Annually on every Monday & the last Thursday of the year that are also the 1st or last day of the year',
    string: 'RRULE:FREQ=YEARLY;BYYEARDAY=1,-1;BYDAY=MO,-1TH',
  );
  // 000110
  testText(
    'Annually on the 1st & last day of the month that are also the 1st or last day of the year',
    string: 'RRULE:FREQ=YEARLY;BYYEARDAY=1,-1;BYMONTHDAY=1,-1',
  );
  // 000111
  testText(
    'Annually on every Monday & the last Thursday of the year that are also the 1st or last day of the month and that are also the 1st or last day of the year',
    string: 'RRULE:FREQ=YEARLY;BYYEARDAY=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
  );

  // 001000
  testText(
    'Annually in the 1st & last week of the year',
    string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1',
  );
  // 001001
  testText(
    'Annually on every Monday & Wednesday in the 1st & last week of the year',
    string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYDAY=MO,WE',
  );
  // 001010
  testText(
    'Annually on the 1st & last day of the month that are also in the 1st or last week of the year',
    string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYMONTHDAY=1,-1',
  );
  // 001011
  testText(
    'Annually on every Monday & Wednesday that are also the 1st or last day of the month and that are also in the 1st or last week of the year',
    string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,WE',
  );
  // 001100
  testText(
    'Annually on the 1st & last day of the year that are also in the 1st or last week of the year',
    string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYYEARDAY=1,-1',
  );
  // 001101
  testText(
    'Annually on every Monday & Wednesday that are also the 1st or last day of the year and that are also in the 1st or last week of the year',
    string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYDAY=MO,WE',
  );
  // 001110
  testText(
    'Annually on the 1st & last day of the month that are also the 1st or last day of the year and that are also in the 1st or last week of the year',
    string: 'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYMONTHDAY=1,-1',
  );
  // 001111
  testText(
    'Annually on every Monday & Wednesday that are also the 1st or last day of the month, that are also the 1st or last day of the year, and that are also in the 1st or last week of the year',
    string:
        'RRULE:FREQ=YEARLY;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,WE',
  );

  // 010000
  testText(
    'Annually in January & December',
    string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12',
  );
  // 010001
  testText(
    'Annually on every Monday & the last Thursday of the month in January & December',
    string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYDAY=MO,-1TH',
  );
  // 010010
  testText(
    'Annually on the 1st & last day of the month in January & December',
    string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYMONTHDAY=1,-1',
  );
  // 010011
  // TODO(JonasWanke): the 1st or last day in January or December
  testText(
    'Annually on every Monday & the last Thursday of the year that are also the 1st or last day of the month and that are also in January or December',
    string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
  );
  // 010100
  testText(
    'Annually on the 1st & last day of the year that are also in January or December',
    string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYYEARDAY=1,-1',
  );
  // 010101
  testText(
    'Annually on every Monday & the last Thursday of the year that are also the 1st or last day of the year and that are also in January or December',
    string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYYEARDAY=1,-1;BYDAY=MO,-1TH',
  );
  // 010110
  testText(
    'Annually on the 1st & last day of the month that are also the 1st or last day of the year and that are also in January or December',
    string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYYEARDAY=1,-1;BYMONTHDAY=1,-1',
  );
  // 010111
  testText(
    'Annually on every Monday & the last Thursday of the year that are also the 1st or last day of the month, that are also the 1st or last day of the year, and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYYEARDAY=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
  );

  // 011000
  testText(
    'Annually in the 1st & last week of the year that are also in January or December',
    string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1',
  );
  // 011001
  testText(
    'Annually on every Monday & Wednesday in the 1st & last week of the year that are also in January or December',
    string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYDAY=MO,WE',
  );
  // 011010
  testText(
    'Annually on the 1st & last day of the month that are also in the 1st or last week of the year and that are also in January or December',
    string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYMONTHDAY=1,-1',
  );
  // 011011
  testText(
    'Annually on every Monday & Wednesday that are also the 1st or last day of the month, that are also in the 1st or last week of the year, and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,WE',
  );
  // 011100
  testText(
    'Annually on the 1st & last day of the year that are also in the 1st or last week of the year and that are also in January or December',
    string: 'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYYEARDAY=1,-1',
  );
  // 011101
  testText(
    'Annually on every Monday & Wednesday that are also the 1st or last day of the year, that are also in the 1st or last week of the year, and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYDAY=MO,WE',
  );
  // 011110
  testText(
    'Annually on the 1st & last day of the month that are also the 1st or last day of the year, that are also in the 1st or last week of the year, and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYMONTHDAY=1,-1',
  );
  // 011111
  testText(
    'Annually on every Monday & Wednesday that are also the 1st or last day of the month, that are also the 1st or last day of the year, that are also in the 1st or last week of the year, and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYMONTH=1,12;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,WE',
  );

  // 100000: invalid
  // 100001
  testText(
    //'Annually on                                   every Monday & the last Thursday of the year',
    'Annually on the 1st & 2nd-to-last instance of every Monday & the last Thursday of the year',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYDAY=MO,-1TH',
  );
  // 100010
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last day of the month',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTHDAY=1,-1',
  );
  // 100011
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & the last Thursday of the year that are also the 1st or last day of the month',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
  );
  // 100100
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last day of the year',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYYEARDAY=1,-1',
  );
  // 100101
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & the last Thursday of the year that are also the 1st or last day of the year',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYYEARDAY=1,-1;BYDAY=MO,-1TH',
  );
  // 100110
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last day of the month that are also the 1st or last day of the year',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYYEARDAY=1,-1;BYMONTHDAY=1,-1',
  );
  // 100111
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & the last Thursday of the year that are also the 1st or last day of the month and that are also the 1st or last day of the year',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYYEARDAY=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
  );

  // 101000
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last week of the year',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYWEEKNO=1,-1',
  );
  // 101001
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & Wednesday in the 1st & last week of the year',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYWEEKNO=1,-1;BYDAY=MO,WE',
  );
  // 101010
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last day of the month that are also in the 1st or last week of the year',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYWEEKNO=1,-1;BYMONTHDAY=1,-1',
  );
  // 101011
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & Wednesday that are also the 1st or last day of the month and that are also in the 1st or last week of the year',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYWEEKNO=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,WE',
  );
  // 101100
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last day of the year that are also in the 1st or last week of the year',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYWEEKNO=1,-1;BYYEARDAY=1,-1',
  );
  // 101101
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & Wednesday that are also the 1st or last day of the year and that are also in the 1st or last week of the year',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYDAY=MO,WE',
  );
  // 101110
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last day of the month that are also the 1st or last day of the year and that are also in the 1st or last week of the year',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYMONTHDAY=1,-1',
  );
  // 101111
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & Wednesday that are also the 1st or last day of the month, that are also the 1st or last day of the year, and that are also in the 1st or last week of the year',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,WE',
  );

  // 110000
  testText(
    'Annually on the 1st & 2nd-to-last instance of January & December',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12',
  );
  // 110001
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & the last Thursday of the month in January & December',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYDAY=MO,-1TH',
  );
  // 110010
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last day of the month in January & December',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYMONTHDAY=1,-1',
  );
  // 110011
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & the last Thursday of the year that are also the 1st or last day of the month and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
  );
  // 110100
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last day of the year that are also in January or December',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYYEARDAY=1,-1',
  );
  // 110101
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & the last Thursday of the year that are also the 1st or last day of the year and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYYEARDAY=1,-1;BYDAY=MO,-1TH',
  );
  // 110110
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last day of the month that are also the 1st or last day of the year and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYYEARDAY=1,-1;BYMONTHDAY=1,-1',
  );
  // 110111
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & the last Thursday of the year that are also the 1st or last day of the month, that are also the 1st or last day of the year, and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYYEARDAY=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
  );

  // 111000
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last week of the year that are also in January or December',
    string: 'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYWEEKNO=1,-1',
  );
  // 111001
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & Wednesday in the 1st & last week of the year that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYWEEKNO=1,-1;BYDAY=MO,WE',
  );
  // 111010
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last day of the month that are also in the 1st or last week of the year and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYWEEKNO=1,-1;BYMONTHDAY=1,-1',
  );
  // 111011
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & Wednesday that are also the 1st or last day of the month, that are also in the 1st or last week of the year, and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYWEEKNO=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,WE',
  );
  // 111100
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last day of the year that are also in the 1st or last week of the year and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYWEEKNO=1,-1;BYYEARDAY=1,-1',
  );
  // 111101
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & Wednesday that are also the 1st or last day of the year, that are also in the 1st or last week of the year, and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYDAY=MO,WE',
  );
  // 111110
  testText(
    'Annually on the 1st & 2nd-to-last instance of the 1st & last day of the month that are also the 1st or last day of the year, that are also in the 1st or last week of the year, and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYMONTHDAY=1,-1',
  );
  // 111111
  testText(
    'Annually on the 1st & 2nd-to-last instance of every Monday & Wednesday that are also the 1st or last day of the month, that are also the 1st or last day of the year, that are also in the 1st or last week of the year, and that are also in January or December',
    string:
        'RRULE:FREQ=YEARLY;BYSETPOS=1,-2;BYMONTH=1,12;BYWEEKNO=1,-1;BYYEARDAY=1,-1;BYMONTHDAY=1,-1;BYDAY=MO,WE',
  );
}
