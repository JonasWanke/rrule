import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:test/test.dart';
import 'package:time_machine/time_machine.dart';

@isTest
void testRecurring(
  String description, {
  @required RecurrenceRule rrule,
  @required LocalDateTime start,
  Iterable<LocalDate> expectedDates,
  Iterable<LocalDateTime> expectedDateTimes,
  bool isInfinite = false,
}) {
  assert((expectedDates == null) != (expectedDateTimes == null));

  test(description, () {
    final expected =
        expectedDateTimes ?? expectedDates.map((d) => d.at(LocalTime(9, 0, 0)));

    if (isInfinite) {
      final actual = rrule.getInstances(start: start).take(expected.length * 2);
      expect(
        actual.length,
        expected.length * 2,
        reason: 'Is actually \'infinite\'',
      );
      expect(actual.take(expected.length), expected);
    } else {
      expect(rrule.getInstances(start: start), expected);
    }
  });
}
