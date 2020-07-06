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
    'Weekly on Monday',
    string: 'RRULE:FREQ=WEEKLY;BYDAY=MO',
  );
  testText(
    'Every other week on Monday',
    string: 'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=MO',
  );
  testText(
    'Every 4 weeks on Monday',
    string: 'RRULE:FREQ=WEEKLY;INTERVAL=4;BYDAY=MO',
  );

  // 0/1 digits in the comment before a text function mean whether each of
  // bySetPositions, byMonths & byWeekDays (in that order) is included.

  // 000
  testText(
    'Weekly',
    string: 'RRULE:FREQ=WEEKLY',
  );
  // 001
  testText(
    'Weekly on Monday & Thursday',
    string: 'RRULE:FREQ=WEEKLY;BYDAY=MO,TH',
  );
  // 010
  testText(
    'Weekly in January & December',
    string: 'RRULE:FREQ=WEEKLY;BYMONTH=1,12',
  );
  // 011
  testText(
    'Weekly in January & December on Monday & Thursday',
    string: 'RRULE:FREQ=WEEKLY;BYMONTH=1,12;BYDAY=MO,TH',
  );
  // 100: invalid
  // 101
  testText(
    'Weekly on the 1st & 2nd-to-last instance of Monday & Thursday',
    string: 'RRULE:FREQ=WEEKLY;BYSETPOS=1,-2;BYDAY=MO,TH',
  );
  // 110
  testText(
    'Weekly in January & December on the 1st & 2nd-to-last instance',
    string: 'RRULE:FREQ=WEEKLY;BYSETPOS=1,-2;BYMONTH=1,12',
  );
  // 111
  testText(
    'Weekly in January & December on the 1st & 2nd-to-last instance of Monday & Thursday',
    string: 'RRULE:FREQ=WEEKLY;BYSETPOS=1,-2;BYMONTH=1,12;BYDAY=MO,TH',
  );
}
