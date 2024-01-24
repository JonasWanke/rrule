// ignore_for_file: lines_longer_than_80_chars

import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:test/test.dart';

import 'utils.dart' as utils;

void main() {
  late final RruleL10n l10n;
  setUpAll(() async => l10n = await RruleL10nEn.create());

  @isTest
  void testText(String text, {required String string}) =>
      utils.testText(text, text: text, string: string, l10n: () => l10n);

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
    'Weekly, until Monday, January 1, 2007 8:00:00 AM',
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
