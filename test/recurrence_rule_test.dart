// ignore_for_file: avoid_redundant_argument_values, lines_longer_than_80_chars

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:rrule/rrule.dart';
import 'package:rrule/src/cache.dart';
import 'package:rrule/src/utils.dart';
import 'package:test/test.dart';

import 'codecs/text/utils.dart';
import 'codecs/utils.dart';

void main() {
  late final RruleL10n l10n;
  setUpAll(() async => l10n = await RruleL10nEn.create());

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
  test('#44: prevent IntegerDivisionByZeroException with SETPOS', () {
    final rrule = RecurrenceRule(
      frequency: Frequency.monthly,
      interval: 1,
      byWeekDays: [
        ByWeekDayEntry(DateTime.wednesday),
        ByWeekDayEntry(DateTime.saturday),
      ],
      byMonths: const [10, 12],
      bySetPositions: const [2, 4],
      until: DateTime.utc(2023, 01, 06, 14, 15),
    );
    final start = DateTime.utc(2022);

    final instances = rrule.getInstances(start: start).take(5);

    expect(
      instances,
      equals([
        DateTime.utc(2022, 10, 05),
        DateTime.utc(2022, 10, 12),
        DateTime.utc(2022, 12, 07),
        DateTime.utc(2022, 12, 14),
      ]),
    );
  });
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
  group(
    '#59: It cannot parse its own strings when current locale does not use Latin numbers',
    () {
      setUp(() async {
        Intl.defaultLocale = 'ar';
        await initializeDateFormatting();
      });

      tearDown(() async {
        Intl.defaultLocale = 'en';
        await initializeDateFormatting();
      });

      final rrule = RecurrenceRule(
        frequency: Frequency.daily,
        until: DateTime.utc(1997, 12, 24),
      );
      const string = 'RRULE:FREQ=DAILY;UNTIL=19971224T000000Z';
      const text = 'Daily, until Wednesday, December 24, 1997 12:00:00 AM';

      testStringCodec(
        'StringCodec',
        codec: const RecurrenceRuleStringCodec(
          toStringOptions: RecurrenceRuleToStringOptions(isTimeUtc: true),
        ),
        value: rrule,
        string: string,
      );

      testText(
        'TextCodec',
        text: text,
        string: string,
        l10n: () => l10n,
      );
    },
  );
  test('#62: Monthly + byWeekDays + getInstances = fails assertion', () {
    final rrule = RecurrenceRule(
      frequency: Frequency.monthly,
      byWeekDays: [ByWeekDayEntry(DateTime.friday, 1)],
    );
    final start = DateTime.utc(2023, 03, 20, 00, 00, 00, 0, 123);

    final instances = rrule.getInstances(start: start);
    expect(instances, isNotEmpty);
  });
  test('#68: bySetPositions is behaving correctly', () {
    final rrule = RecurrenceRule(
      frequency: Frequency.weekly,
      byWeekDays: [
        ByWeekDayEntry(DateTime.monday),
        ByWeekDayEntry(DateTime.wednesday),
      ],
      bySetPositions: const [2, 3],
    );
    final start = DateTime.utc(2024, 02, 01);

    final instances = rrule.getInstances(start: start).take(5);
    expect(
      instances,
      equals([
        DateTime.utc(2024, 02, 07),
        DateTime.utc(2024, 02, 14),
        DateTime.utc(2024, 02, 21),
        DateTime.utc(2024, 02, 28),
        DateTime.utc(2024, 03, 06),
      ]),
    );
  });
}
