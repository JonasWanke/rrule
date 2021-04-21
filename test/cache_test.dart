import 'package:rrule/src/cache.dart';
import 'package:test/test.dart';

void main() {
  test('should add data to the cache of the before method', () {
    final cache = Cache();
    final results = <DateTime>[];
    cache.add(CacheMethod.before, 1, results);

    expect(cache.beforeResults, containsPair(1, results));
  });

  test('should add data to the cache of the after method', () {
    final cache = Cache();
    final results = <DateTime>[];
    cache.add(CacheMethod.after, 1, results);

    expect(cache.afterResults, containsPair(1, results));
  });

  test('should add data to the cache of the between method', () {
    final cache = Cache();
    final results = <DateTime>[];
    cache.add(CacheMethod.between, 1, results);

    expect(cache.betweenResults, containsPair(1, results));
  });

  test('should return data from the cache of the before method', () {
    final cache = Cache();
    final results = <DateTime>[];
    cache.add(CacheMethod.before, 1, results);

    expect(cache.get(CacheMethod.before, 1), results);
  });

  test('should return data from the cache of the after method', () {
    final cache = Cache();
    final results = <DateTime>[];
    cache.add(CacheMethod.after, 1, results);

    expect(cache.get(CacheMethod.after, 1), results);
  });

  test('should return data from the cache of the between method', () {
    final cache = Cache();
    final results = <DateTime>[];
    cache.add(CacheMethod.between, 1, results);

    expect(cache.get(CacheMethod.between, 1), results);
  });
}
