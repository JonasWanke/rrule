import 'package:rrule/rrule.dart';
import 'package:test/test.dart';

void main() {
  // There are more tests in `../../rrule_ical_test.dart`.

  group('from string', () {
    test('throws on missing frequency', () {
      const codec = RecurrenceRuleStringCodec();

      expect(
        () => codec.decode('RRULE:COUNT=3;COUNT=6'),
        throwsFormatException,
      );
      expect(
        () => codec.decode('RRULE:'),
        throwsFormatException,
      );
    });

    test('throws on duplicate parts', () {
      const codec = RecurrenceRuleStringCodec();

      expect(
        () => codec.decode('RRULE:FREQ=DAILY,COUNT=3;COUNT=6'),
        throwsFormatException,
      );
      expect(
        () => codec.decode('RRULE:FREQ=DAILY,COUNT=3;UNTIL=20200101'),
        throwsFormatException,
      );
      expect(
        () => codec.decode('RRULE:FREQ=DAILY,BYSECOND=3,5;BYSECOND=19,3'),
        throwsFormatException,
      );
      expect(
        () => codec.decode('RRULE:FREQ=DAILY,BYDAY=+1MO;BYDAY=TU'),
        throwsFormatException,
      );
    });

    test('parses dates', () {
      const codec = RecurrenceRuleStringCodec();

      expect(
        codec.decode('RRULE:FREQ=DAILY;UNTIL=20200101'),
        RecurrenceRule(
          frequency: Frequency.daily,
          until: DateTime.utc(2020, 1, 1),
        ),
      );
      expect(
        codec.decode('RRULE:FREQ=DAILY;UNTIL=20200101T123456'),
        RecurrenceRule(
          frequency: Frequency.daily,
          until: DateTime.utc(2020, 1, 1, 12, 34, 56),
        ),
      );
      expect(
        codec.decode('RRULE:FREQ=DAILY;UNTIL=20200101T123456Z'),
        RecurrenceRule(
          frequency: Frequency.daily,
          until: DateTime.utc(2020, 1, 1, 12, 34, 56),
        ),
      );
    });

    test('parses week day entries', () {
      const codec = RecurrenceRuleStringCodec();

      expect(
        codec.decode('RRULE:FREQ=YEARLY;BYDAY=MO,TU,WE,TH,FR,SA,SU'),
        RecurrenceRule(
          frequency: Frequency.yearly,
          byWeekDays: [
            ByWeekDayEntry(DateTime.monday),
            ByWeekDayEntry(DateTime.tuesday),
            ByWeekDayEntry(DateTime.wednesday),
            ByWeekDayEntry(DateTime.thursday),
            ByWeekDayEntry(DateTime.friday),
            ByWeekDayEntry(DateTime.saturday),
            ByWeekDayEntry(DateTime.sunday),
          ],
        ),
      );
      expect(
        codec.decode('RRULE:FREQ=YEARLY;BYDAY=-20SA,-4MO,53FR'),
        RecurrenceRule(
          frequency: Frequency.yearly,
          byWeekDays: [
            ByWeekDayEntry(DateTime.saturday, -20),
            ByWeekDayEntry(DateTime.monday, -4),
            ByWeekDayEntry(DateTime.friday, 53),
          ],
        ),
      );

      expect(
        () => codec.decode('RRULE:FREQ=YEARLY;BYDAY=-54SA'),
        throwsFormatException,
      );
      expect(
        () => codec.decode('RRULE:FREQ=YEARLY;BYDAY=-4'),
        throwsFormatException,
      );
      expect(
        () => codec.decode('RRULE:FREQ=YEARLY;BYDAY=TUE'),
        throwsFormatException,
      );
      expect(
        () => codec.decode('RRULE:FREQ=YEARLY;BYDAY=FO'),
        throwsFormatException,
      );
      expect(
        () => codec.decode('RRULE:FREQ=YEARLY;BYDAY=60'),
        throwsFormatException,
      );
    });
  });
}
