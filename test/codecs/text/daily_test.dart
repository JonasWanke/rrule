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
    'Daily on Monday',
    string: 'RRULE:FREQ=DAILY;BYDAY=MO',
  );
  testText(
    'Every other day on Monday',
    string: 'RRULE:FREQ=DAILY;INTERVAL=2;BYDAY=MO',
  );
  testText(
    'Every 4 days on Monday',
    string: 'RRULE:FREQ=DAILY;INTERVAL=4;BYDAY=MO',
  );

  // 0/1 digits in the comment before a text function mean whether each of
  // bySetPositions, byMonths, byMonthDays & byWeekDays (in that order) is
  // included.

  // 0000
  testText(
    'Daily',
    string: 'RRULE:FREQ=DAILY',
  );
  // 0001
  testText(
    'Daily on Monday & Thursday',
    string: 'RRULE:FREQ=DAILY;BYDAY=MO,TH',
  );
  // 0010
  testText(
    'Daily on the 1st & last day of the month',
    string: 'RRULE:FREQ=DAILY;BYMONTHDAY=1,-1',
  );
  // 0011
  testText(
    'Daily on Monday & Thursday that are also the 1st or last day of the month',
    string: 'RRULE:FREQ=DAILY;BYMONTHDAY=1,-1;BYDAY=MO,TH',
  );
  // 0100
  testText(
    'Daily in January & December',
    string: 'RRULE:FREQ=DAILY;BYMONTH=1,12',
  );
  // 0101
  testText(
    'Daily in January & December on Monday & Thursday',
    string: 'RRULE:FREQ=DAILY;BYMONTH=1,12;BYDAY=MO,TH',
  );
  // 0110
  testText(
    'Daily in January & December on the 1st & last day of the month',
    string: 'RRULE:FREQ=DAILY;BYMONTH=1,12;BYMONTHDAY=1,-1',
  );
  // 0111
  testText(
    'Daily in January & December on Monday & Thursday that are also the 1st or last day of the month',
    string: 'RRULE:FREQ=DAILY;BYMONTH=1,12;BYMONTHDAY=1,-1;BYDAY=MO,TH',
  );

  // 1000: invalid
  // 1001
  testText(
    'Daily on the 1st & 2nd-to-last instance of Monday & Thursday',
    string: 'RRULE:FREQ=DAILY;BYSETPOS=1,-2;BYDAY=MO,TH',
  );
  // 1010
  testText(
    'Daily on the 1st & 2nd-to-last instance of the 1st & last day of the month',
    string: 'RRULE:FREQ=DAILY;BYSETPOS=1,-2;BYMONTHDAY=1,-1',
  );
  // 1011
  testText(
    'Daily on the 1st & 2nd-to-last instance of Monday & Thursday that are also the 1st or last day of the month',
    string: 'RRULE:FREQ=DAILY;BYSETPOS=1,-2;BYMONTHDAY=1,-1;BYDAY=MO,TH',
  );
  // 1100
  testText(
    'Daily in January & December on the 1st & 2nd-to-last instance',
    string: 'RRULE:FREQ=DAILY;BYSETPOS=1,-2;BYMONTH=1,12',
  );
  // 1101
  testText(
    'Daily in January & December on the 1st & 2nd-to-last instance of Monday & Thursday',
    string: 'RRULE:FREQ=DAILY;BYSETPOS=1,-2;BYMONTH=1,12;BYDAY=MO,TH',
  );
  // 1110
  testText(
    'Daily in January & December on the 1st & 2nd-to-last instance of the 1st & last day of the month',
    string: 'RRULE:FREQ=DAILY;BYSETPOS=1,-2;BYMONTH=1,12;BYMONTHDAY=1,-1',
  );
  // 1111
  testText(
    'Daily in January & December on the 1st & 2nd-to-last instance of Monday & Thursday that are also the 1st or last day of the month',
    string:
        'RRULE:FREQ=DAILY;BYSETPOS=1,-2;BYMONTH=1,12;BYMONTHDAY=1,-1;BYDAY=MO,TH',
  );
}
