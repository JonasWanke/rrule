import 'package:rrule/rrule.dart';
import 'package:rrule/src/cache.dart';
import 'package:rrule/src/utils.dart';
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

    test('should support date before inclusive', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.monthly,
        until: DateTime.utc(2021),
      );

      final instances = rrule.getAllInstances(
        start: DateTime.utc(2020),
        before: DateTime.utc(2020, 5),
        includeBefore: true,
      );

      expect(instances.last, DateTime.utc(2020, 5));
    });

    test('should support date before exclusive', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.monthly,
        until: DateTime.utc(2021),
      );

      final instances = rrule.getAllInstances(
        start: DateTime.utc(2020),
        before: DateTime.utc(2020, 5),
      );

      expect(instances.last, DateTime.utc(2020, 4));
    });
  });

  test(
    '#19: No warning for creating a RRULE with BYWEEKNO, but with non-YEARLY frequency',
    () {
      expect(
        () => RecurrenceRule(
          frequency: Frequency.daily,
          byWeeks: const [1, 2, 3],
        ),
        throwsA(isA<AssertionError>()),
      );
    },
  );
  test(
    '#25: Generating date with count parameter for the same day return unexpected result',
    () {
      final rrule =
          RecurrenceRule.fromString('RRULE:FREQ=DAILY;COUNT=5;INTERVAL=1');
      final start = DateTime.parse('2021-06-17 19:00:00.000Z');
      final after = DateTime.parse('2021-06-24 04:00:00.000Z');
      final before = DateTime.parse('2021-06-25 03:59:59.000Z');
      final instances = rrule
          .getInstances(
            start: start,
            after: after,
            includeAfter: true,
            before: before,
            includeBefore: true,
          )
          .toList();

      expect(instances.length, 0);
    },
  );
  test(
    "#29: getting instances for rrule yearly, 'every 2nd tuesday of January' fails",
    () {
      const rruleString =
          'RRULE:FREQ=YEARLY;COUNT=4;INTERVAL=1;BYDAY=2TU;BYMONTH=1';
      final rrule = RecurrenceRule(
        frequency: Frequency.yearly,
        count: 4,
        interval: 1,
        byMonths: const [1],
        byWeekDays: [ByWeekDayEntry(DateTime.tuesday, 2)],
      );
      expect(RecurrenceRule.fromString(rruleString), rrule);

      final instances =
          rrule.getAllInstances(start: InternalDateTimeRrule.date(2022, 1, 1));
      expect(instances.length, 4);
    },
  );
  test(
    '#46: Start DateTime with microseconds should not skip first instance',
    () {
      final rrule = RecurrenceRule(frequency: Frequency.daily);

      final start = DateTime.utc(
        2023,
        03,
        16,
        00,
        00,
        00,
        123, // milliseconds
        456, // microseconds
      );
      final instances = rrule.getInstances(start: start);

      expect(instances.first, equals(start));
    },
  );
  test('#48: DateTime.copyWith should preserve microseconds', () {
    final start = DateTime(2023, 03, 20, 00, 00, 00, 0, 123);

    expect(
      start.copyWith(isUtc: true).copyWith(isUtc: false),
      equals(start),
    );
  });
}
