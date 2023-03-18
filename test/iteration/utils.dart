import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:test/test.dart';

@isTest
// ignore: avoid-top-level-members-in-tests
void testRecurring(
  String description, {
  required RecurrenceRule rrule,
  required DateTime start,
  required Iterable<DateTime> expected,
  bool isInfinite = false,
}) {
  test(description, () {
    if (isInfinite) {
      final actual = rrule.getInstances(start: start).take(expected.length * 2);
      expect(
        actual.length,
        expected.length * 2,
        reason: "Is actually 'infinite'",
      );
      expect(actual.take(expected.length), expected);
    } else {
      expect(rrule.getInstances(start: start), expected);
    }
  });
}
