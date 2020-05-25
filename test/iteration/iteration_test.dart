import 'package:basics/basics.dart';
import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:test/test.dart';
import 'package:time_machine/time_machine.dart';

void main() {
  @isTest
  void testRecurring(
    String description, {
    @required RecurrenceRule rrule,
    @required LocalDateTime start,
    @required Iterable<LocalDateTime> expectedDates,
    bool isInfinite = false,
  }) {
    test(description, () {
      if (isInfinite) {
        expect(
          rrule.getInstances(start: start).take(expectedDates.length),
          expectedDates,
        );
      } else {
        expect(rrule.getInstances(start: start), expectedDates);
      }
    });
  }

  testRecurring(
    'Daily for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      count: 10,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: 2.to(12).map((d) => LocalDateTime(1997, 9, d, 9, 0, 0)),
  );
  testRecurring(
    'Daily until December 24, 1997',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      until: LocalDate(1997, 12, 24).atMidnight(),
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...2.to(31).map((d) => LocalDate(1997, 9, d)),
      ...1.to(32).map((d) => LocalDate(1997, 10, d)),
      ...1.to(31).map((d) => LocalDate(1997, 11, d)),
      ...1.to(24).map((d) => LocalDate(1997, 12, d)),
    ].map((d) => d.at(LocalTime(9, 0, 0))),
  );
  testRecurring(
    'Every other day - forever',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      interval: 2,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...2.to(31, by: 2).map((d) => LocalDate(1997, 9, d)),
      ...2.to(31, by: 2).map((d) => LocalDate(1997, 10, d)),
      ...1.to(30, by: 2).map((d) => LocalDate(1997, 11, d)),
      ...1.to(32, by: 2).map((d) => LocalDate(1997, 12, d)),
    ].map((d) => d.at(LocalTime(9, 0, 0))),
    isInfinite: true,
  );
  testRecurring(
    'Every 10 days, 5 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      count: 5,
      interval: 10,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...2.to(23, by: 10).map((d) => LocalDate(1997, 9, d)),
      ...2.to(13, by: 10).map((d) => LocalDate(1997, 10, d)),
    ].map((d) => d.at(LocalTime(9, 0, 0))),
  );
}
