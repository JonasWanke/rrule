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
        final actual =
            rrule.getInstances(start: start).take(expectedDates.length * 2);
        expect(
          actual.length,
          expectedDates.length * 2,
          reason: 'Is actually \'infinite\'',
        );
        expect(actual.take(expectedDates.length), expectedDates);
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
  group('Every day in January, for 3 years', () {
    final expected = 1998.to(2001).expand((y) {
      return 1.to(32).map((d) => LocalDateTime(y, 1, d, 9, 0, 0));
    });
    testRecurring(
      'with frequency yearly',
      rrule: RecurrenceRule(
        frequency: RecurrenceFrequency.yearly,
        until: LocalDateTime(2000, 01, 31, 14, 0, 0),
        byWeekDays: {
          ByWeekDayEntry(DayOfWeek.sunday),
          ByWeekDayEntry(DayOfWeek.monday),
          ByWeekDayEntry(DayOfWeek.tuesday),
          ByWeekDayEntry(DayOfWeek.wednesday),
          ByWeekDayEntry(DayOfWeek.thursday),
          ByWeekDayEntry(DayOfWeek.friday),
          ByWeekDayEntry(DayOfWeek.saturday),
        },
        byMonths: {1},
      ),
      start: LocalDateTime(1998, 1, 1, 9, 0, 0),
      expectedDates: expected,
    );
    testRecurring(
      'with frequency daily',
      rrule: RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        until: LocalDateTime(2000, 01, 31, 14, 0, 0),
        byMonths: {1},
      ),
      start: LocalDateTime(1998, 1, 1, 9, 0, 0),
      expectedDates: expected,
    );
  });
  testRecurring(
    'Weekly for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      count: 10,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...2.to(31, by: 7).map((d) => LocalDate(1997, 9, d)),
      ...7.to(29, by: 7).map((d) => LocalDate(1997, 10, d)),
      LocalDate(1997, 11, 4),
    ].map((d) => d.at(LocalTime(9, 0, 0))),
  );
  testRecurring(
    'Weekly until December 24, 1997',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      until: LocalDate(1997, 12, 24).atMidnight(),
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...2.to(31, by: 7).map((d) => LocalDate(1997, 9, d)),
      ...7.to(29, by: 7).map((d) => LocalDate(1997, 10, d)),
      ...4.to(26, by: 7).map((d) => LocalDate(1997, 11, d)),
      ...2.to(24, by: 7).map((d) => LocalDate(1997, 12, d)),
    ].map((d) => d.at(LocalTime(9, 0, 0))),
  );
  testRecurring(
    'Every other week - forever',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      interval: 2,
      weekStart: DayOfWeek.sunday,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...2.to(31, by: 14).map((d) => LocalDate(1997, 9, d)),
      ...14.to(29, by: 14).map((d) => LocalDate(1997, 10, d)),
      ...11.to(26, by: 14).map((d) => LocalDate(1997, 11, d)),
      ...9.to(24, by: 14).map((d) => LocalDate(1997, 12, d)),
      ...6.to(21, by: 14).map((d) => LocalDate(1998, 1, d)),
      ...3.to(18, by: 14).map((d) => LocalDate(1998, 2, d)),
    ].map((d) => d.at(LocalTime(9, 0, 0))),
    isInfinite: true,
  );
  group('Weekly on Tuesday and Thursday for five weeks', () {
    final expected = [
      ...[2, 4, 9, 11, 16, 18, 23, 25, 30].map((d) => LocalDate(1997, 09, d)),
      LocalDate(1997, 10, 2),
    ].map((d) => d.at(LocalTime(9, 0, 0)));
    testRecurring(
      'with until',
      rrule: RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        until: LocalDate(1997, 10, 07).atMidnight(),
        weekStart: DayOfWeek.sunday,
        byWeekDays: {
          ByWeekDayEntry(DayOfWeek.tuesday),
          ByWeekDayEntry(DayOfWeek.thursday),
        },
      ),
      start: LocalDateTime(1997, 9, 2, 9, 0, 0),
      expectedDates: expected,
    );
    testRecurring(
      'with count',
      rrule: RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        count: 10,
        byWeekDays: {
          ByWeekDayEntry(DayOfWeek.tuesday),
          ByWeekDayEntry(DayOfWeek.thursday),
        },
        weekStart: DayOfWeek.sunday,
      ),
      start: LocalDateTime(1997, 9, 2, 9, 0, 0),
      expectedDates: expected,
    );
  });
  testRecurring(
    'Every other week on Monday, Wednesday, and Friday until December 24, 1997',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      until: LocalDate(1997, 12, 24).atMidnight(),
      interval: 2,
      byWeekDays: {
        ByWeekDayEntry(DayOfWeek.monday),
        ByWeekDayEntry(DayOfWeek.wednesday),
        ByWeekDayEntry(DayOfWeek.friday),
      },
      weekStart: DayOfWeek.sunday,
    ),
    start: LocalDateTime(1997, 9, 1, 9, 0, 0),
    expectedDates: [
      ...[1, 3, 5, 15, 17, 19, 29].map((d) => LocalDate(1997, 9, d)),
      ...[1, 3, 13, 15, 17, 27, 29, 31].map((d) => LocalDate(1997, 10, d)),
      ...[10, 12, 14, 24, 26, 28].map((d) => LocalDate(1997, 11, d)),
      ...[8, 10, 12, 22].map((d) => LocalDate(1997, 12, d)),
    ].map((d) => d.at(LocalTime(9, 0, 0))),
  );
  testRecurring(
    'Every other week on Tuesday and Thursday, for 8 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      count: 8,
      interval: 2,
      byWeekDays: {
        ByWeekDayEntry(DayOfWeek.tuesday),
        ByWeekDayEntry(DayOfWeek.thursday),
      },
      weekStart: DayOfWeek.sunday,
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...[2, 4, 16, 18, 30].map((d) => LocalDate(1997, 9, d)),
      ...[2, 14, 16].map((d) => LocalDate(1997, 10, d)),
    ].map((d) => d.at(LocalTime(9, 0, 0))),
  );
  testRecurring(
    'Monthly on the third-to-the-last day of the month, forever',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      byMonthDays: {-3},
    ),
    start: LocalDateTime(1997, 9, 28, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 9, 28),
      LocalDate(1997, 10, 29),
      LocalDate(1997, 11, 28),
      LocalDate(1997, 12, 29),
      LocalDate(1998, 1, 29),
      LocalDate(1998, 2, 26),
    ].map((d) => d.at(LocalTime(9, 0, 0))),
    isInfinite: true,
  );
  testRecurring(
    'Monthly on the 2nd and 15th of the month for 10 occurrences',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      count: 10,
      byMonthDays: {2, 15},
    ),
    start: LocalDateTime(1997, 9, 2, 9, 0, 0),
    expectedDates: [
      ...[2, 15].map((d) => LocalDate(1997, 9, d)),
      ...[2, 15].map((d) => LocalDate(1997, 10, d)),
      ...[2, 15].map((d) => LocalDate(1997, 11, d)),
      ...[2, 15].map((d) => LocalDate(1997, 12, d)),
      ...[2, 15].map((d) => LocalDate(1998, 1, d)),
    ].map((d) => d.at(LocalTime(9, 0, 0))),
  );
  testRecurring(
    'Monthly on the first and last day of the month for 10 occurrences:',
    rrule: RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      count: 10,
      byMonthDays: {1, -1},
    ),
    start: LocalDateTime(1997, 9, 30, 9, 0, 0),
    expectedDates: [
      LocalDate(1997, 9, 30),
      ...[1, 31].map((d) => LocalDate(1997, 10, d)),
      ...[1, 30].map((d) => LocalDate(1997, 11, d)),
      ...[1, 31].map((d) => LocalDate(1997, 12, d)),
      ...[1, 31].map((d) => LocalDate(1998, 1, d)),
      LocalDate(1998, 2, 1),
    ].map((d) => d.at(LocalTime(9, 0, 0))),
  );
}
