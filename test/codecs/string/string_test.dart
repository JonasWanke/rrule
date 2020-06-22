import 'package:rrule/rrule.dart';
import 'package:test/test.dart';
import 'package:time_machine/time_machine.dart';

void main() {
  // Note: There are more tests in `../rrule_ical_test.dart`.

  group('from string', () {
    test('throws on missing frequency', () {
      final codec = RecurrenceRuleStringCodec();

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
      final codec = RecurrenceRuleStringCodec();

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
      final codec = RecurrenceRuleStringCodec();

      expect(
        codec.decode('RRULE:FREQ=DAILY;UNTIL=20200101'),
        RecurrenceRule(
          frequency: Frequency.daily,
          until: LocalDate(2020, 1, 1).atMidnight(),
        ),
      );
      expect(
        codec.decode('RRULE:FREQ=DAILY;UNTIL=20200101T123456'),
        RecurrenceRule(
          frequency: Frequency.daily,
          until: LocalDateTime(2020, 1, 1, 12, 34, 56),
        ),
      );
      expect(
        codec.decode('RRULE:FREQ=DAILY;UNTIL=20200101T123456Z'),
        RecurrenceRule(
          frequency: Frequency.daily,
          until: LocalDateTime(2020, 1, 1, 12, 34, 56),
        ),
      );
    });

    test('parses week day entries', () {
      final codec = RecurrenceRuleStringCodec();

      expect(
        codec.decode('RRULE:FREQ=YEARLY;BYDAY=MO,TU,WE,TH,FR,SA,SU'),
        RecurrenceRule(
          frequency: Frequency.yearly,
          byWeekDays: {
            ByWeekDayEntry(DayOfWeek.monday),
            ByWeekDayEntry(DayOfWeek.tuesday),
            ByWeekDayEntry(DayOfWeek.wednesday),
            ByWeekDayEntry(DayOfWeek.thursday),
            ByWeekDayEntry(DayOfWeek.friday),
            ByWeekDayEntry(DayOfWeek.saturday),
            ByWeekDayEntry(DayOfWeek.sunday),
          },
        ),
      );
      expect(
        codec.decode('RRULE:FREQ=YEARLY;BYDAY=-20SA,-4MO,53FR'),
        RecurrenceRule(
          frequency: Frequency.yearly,
          byWeekDays: {
            ByWeekDayEntry(DayOfWeek.saturday, -20),
            ByWeekDayEntry(DayOfWeek.monday, -4),
            ByWeekDayEntry(DayOfWeek.friday, 53),
          },
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
