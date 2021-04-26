import 'package:rrule/rrule.dart';
import 'package:rrule/src/cache.dart';
import 'package:test/test.dart';

void main() {
  group('copyWith', () {
    test('until can be adjusted', () {
      expect(
        RecurrenceRule(
          frequency: Frequency.daily,
          until: DateTime.utc(2021, 1, 1),
        ).copyWith(clearUntil: true).until,
        isNull,
      );
      expect(
        RecurrenceRule(
          frequency: Frequency.daily,
          until: DateTime.utc(2021, 1, 1),
        ).copyWith(until: DateTime.utc(2021, 2, 2)).until,
        DateTime.utc(2021, 2, 2),
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

  group('cache', () {
    test('should store instances in the cache', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.monthly,
        until: DateTime.utc(2021),
        shouldCacheResults: true,
      );
      final instances = rrule.getAllInstances(start: DateTime.utc(2020));

      expect(rrule.cache.get(CacheKey(start: DateTime.utc(2020))), instances);
    });
  });

  group('getAllInstances', () {
    test('should support date after inclusive', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.monthly,
        until: DateTime.utc(2021),
      );

      final instances = rrule.getAllInstances(
        start: DateTime.utc(2020),
        after: DateTime.utc(2020, 5),
        includeAfter: true,
      );

      expect(instances.first, DateTime.utc(2020, 5));
    });

    test('should support date after exclusive', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.monthly,
        until: DateTime.utc(2021),
      );

      final instances = rrule.getAllInstances(
        start: DateTime.utc(2020),
        after: DateTime.utc(2020, 5),
      );

      expect(instances.first, DateTime.utc(2020, 6));
    });
  });

  test(
      '#19: No warning for creating a RRULE with BYWEEKNO, but with non-YEARLY frequency',
      () {
    expect(
      () => RecurrenceRule(frequency: Frequency.daily, byWeeks: {1, 2, 3}),
      throwsA(isA<AssertionError>()),
    );
  });
}
