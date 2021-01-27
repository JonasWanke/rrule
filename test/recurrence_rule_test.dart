import 'package:rrule/rrule.dart';
import 'package:test/test.dart';
import 'package:time_machine/time_machine.dart';

void main() {
  group('copyWith', () {
    test('until can be adjusted', () {
      expect(
        RecurrenceRule(
          frequency: Frequency.daily,
          until: LocalDateTime(2021, 1, 1, 0, 0, 0),
        ).copyWith(clearUntil: true).until,
        isNull,
      );
      expect(
        RecurrenceRule(
          frequency: Frequency.daily,
          until: LocalDateTime(2021, 1, 1, 0, 0, 0),
        ).copyWith(until: LocalDateTime(2021, 2, 2, 0, 0, 0)).until,
        LocalDateTime(2021, 2, 2, 0, 0, 0),
      );
    });
    test('count can be adjusted', () {
      expect(
        RecurrenceRule(frequency: Frequency.daily, count: 10)
            .copyWith(clearCount: true)
            .count,
        isNull,
      );
      expect(
        RecurrenceRule(frequency: Frequency.daily, count: 10)
            .copyWith(count: 20)
            .count,
        20,
      );
    });
    test('interval can be adjusted', () {
      expect(
        RecurrenceRule(frequency: Frequency.daily, interval: 10)
            .copyWith(clearInterval: true)
            .interval,
        isNull,
      );
      expect(
        RecurrenceRule(frequency: Frequency.daily, interval: 10)
            .copyWith(interval: 20)
            .interval,
        20,
      );
    });
  });
}
