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
    'Monthly on every Monday',
    string: 'RRULE:FREQ=MONTHLY;BYDAY=MO',
  );
  testText(
    'Every other month on every Monday',
    string: 'RRULE:FREQ=MONTHLY;INTERVAL=2;BYDAY=MO',
  );
  testText(
    'Every 4 months on every Monday',
    string: 'RRULE:FREQ=MONTHLY;INTERVAL=4;BYDAY=MO',
  );

  // https://github.com/JonasWanke/rrule/issues/13
  testText(
    'Monthly on the last day',
    string:
        'RRULE:FREQ=MONTHLY;INTERVAL=1;BYSETPOS=-1;BYDAY=MO,TU,WE,TH,FR,SA,SU',
  );

  // 0/1 digits in the comment before a text function mean whether each of
  // bySetPositions, byMonths, byMonthDays & byWeekDays (in that order) is
  // included.

  // 0000
  testText(
    'Monthly',
    string: 'RRULE:FREQ=MONTHLY',
  );
  // 0001
  testText(
    'Monthly on every Monday & the last Thursday',
    string: 'RRULE:FREQ=MONTHLY;BYDAY=MO,-1TH',
  );
  // 0010
  testText(
    'Monthly on the 1st & last day',
    string: 'RRULE:FREQ=MONTHLY;BYMONTHDAY=1,-1',
  );
  // 0011
  testText(
    'Monthly on every Monday & the last Thursday that are also the 1st or last day of the month',
    string: 'RRULE:FREQ=MONTHLY;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
  );
  // 0100
  testText(
    'Monthly in January & December',
    string: 'RRULE:FREQ=MONTHLY;BYMONTH=1,12',
  );
  // 0101
  testText(
    'Monthly in January & December on every Monday & the last Thursday',
    string: 'RRULE:FREQ=MONTHLY;BYMONTH=1,12;BYDAY=MO,-1TH',
  );
  // 0110
  testText(
    'Monthly in January & December on the 1st & last day',
    string: 'RRULE:FREQ=MONTHLY;BYMONTH=1,12;BYMONTHDAY=1,-1',
  );
  // 0111
  testText(
    'Monthly in January & December on every Monday & the last Thursday that are also the 1st or last day of the month',
    string: 'RRULE:FREQ=MONTHLY;BYMONTH=1,12;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
  );

  // 1000: invalid
  // 1001
  testText(
    'Monthly on the 1st & 2nd-to-last instance of every Monday & the last Thursday',
    string: 'RRULE:FREQ=MONTHLY;BYSETPOS=1,-2;BYDAY=MO,-1TH',
  );
  // 1010
  testText(
    'Monthly on the 1st & 2nd-to-last instance of the 1st & last day',
    string: 'RRULE:FREQ=MONTHLY;BYSETPOS=1,-2;BYMONTHDAY=1,-1',
  );
  // 1011
  testText(
    'Monthly on the 1st & 2nd-to-last instance of every Monday & the last Thursday that are also the 1st or last day of the month',
    string: 'RRULE:FREQ=MONTHLY;BYSETPOS=1,-2;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
  );
  // 1100
  testText(
    'Monthly in January & December on the 1st & 2nd-to-last instance',
    string: 'RRULE:FREQ=MONTHLY;BYSETPOS=1,-2;BYMONTH=1,12',
  );
  // 1101
  testText(
    'Monthly in January & December on the 1st & 2nd-to-last instance of every Monday & the last Thursday',
    string: 'RRULE:FREQ=MONTHLY;BYSETPOS=1,-2;BYMONTH=1,12;BYDAY=MO,-1TH',
  );
  // 1110
  testText(
    'Monthly in January & December on the 1st & 2nd-to-last instance of the 1st & last day',
    string: 'RRULE:FREQ=MONTHLY;BYSETPOS=1,-2;BYMONTH=1,12;BYMONTHDAY=1,-1',
  );
  // 1111
  testText(
    'Monthly in January & December on the 1st & 2nd-to-last instance of every Monday & the last Thursday that are also the 1st or last day of the month',
    string:
        'RRULE:FREQ=MONTHLY;BYSETPOS=1,-2;BYMONTH=1,12;BYMONTHDAY=1,-1;BYDAY=MO,-1TH',
  );
}
