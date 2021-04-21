import 'package:rrule/rrule.dart';
import 'package:rrule/src/cache.dart';
import 'package:rrule/src/rrule.dart';
import 'package:test/test.dart';

void main() {
  test('should be initialized with the initial cache', () {
    final cache = Cache();
    cache.add(CacheMethod.before, 1, <DateTime>[]);

    final rule = RecurrenceRule(frequency: Frequency.daily);
    final start = DateTime.utc(2020);
    final rrule = RRule(rule: rule, start: start, initialCache: cache);

    expect(rrule.cache.beforeResults, isNotEmpty);
  });

  test('should return valid list of dates for the method before', () {
    final rule = RecurrenceRule(frequency: Frequency.monthly);
    final start = DateTime.utc(2020);
    final rrule = RRule(rule: rule, start: start);

    expect(rrule.before(date: DateTime.utc(2020, 3)), [
      DateTime.utc(2020, 1),
      DateTime.utc(2020, 2),
    ]);

    expect(
      rrule.before(date: DateTime.utc(2020, 3), inc: true).last,
      DateTime.utc(2020, 3),
    );
  });

  test('should return valid list of dates for the method after', () {
    final start = DateTime.utc(2020);
    final end = DateTime.utc(2020, 3);
    final rule = RecurrenceRule(frequency: Frequency.monthly, until: end);
    final rrule = RRule(rule: rule, start: start);

    expect(rrule.after(date: DateTime.utc(2020, 1)), [
      DateTime.utc(2020, 2),
      DateTime.utc(2020, 3),
    ]);

    expect(
      rrule.after(date: DateTime.utc(2020, 1), inc: true).first,
      DateTime.utc(2020, 1),
    );
  });

  test('should return valid list of dates for the method between', () {
    final start = DateTime.utc(2020);
    final rule = RecurrenceRule(frequency: Frequency.monthly);
    final rrule = RRule(rule: rule, start: start);

    expect(
      rrule.between(start: DateTime.utc(2020, 2), end: DateTime.utc(2020, 4)),
      [DateTime.utc(2020, 3)],
    );

    expect(
      rrule.between(
        start: DateTime.utc(2020, 2),
        end: DateTime.utc(2020, 4),
        inc: true,
      ),
      [DateTime.utc(2020, 2), DateTime.utc(2020, 3), DateTime.utc(2020, 4)],
    );
  });

  group('should add data to the cache of the corresponding method', () {
    test('before', () {
      final rule = RecurrenceRule(frequency: Frequency.daily);
      final start = DateTime.utc(2020);
      final rrule = RRule(rule: rule, start: start);

      final beforeResult = rrule.before(date: DateTime(2020, 2));
      final cacheResults = rrule.cache.beforeResults;
      expect(beforeResult, cacheResults.values.first);
    });

    test('after', () {
      final start = DateTime.utc(2020);
      final end = DateTime.utc(2020, 3);
      final rule = RecurrenceRule(frequency: Frequency.daily, until: end);
      final rrule = RRule(rule: rule, start: start);

      final afterResult = rrule.after(date: DateTime(2020, 2));
      final cacheResults = rrule.cache.afterResults;
      expect(afterResult, cacheResults.values.first);
    });

    test('between', () {
      final start = DateTime.utc(2020);
      final end = DateTime.utc(2020, 3);
      final rule = RecurrenceRule(frequency: Frequency.daily, until: end);
      final rrule = RRule(rule: rule, start: start);

      final betweenResult = rrule.between(
        start: DateTime.utc(2020, 1),
        end: DateTime.utc(2020, 2),
      );

      final cacheResults = rrule.cache.betweenResults;
      expect(betweenResult, cacheResults.values.first);
    });
  });

  group('should return data from the cache of the corresponding method', () {
    //TODO: add mockito for testing this logic
  });
}
