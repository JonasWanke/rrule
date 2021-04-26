import 'package:rrule/src/cache.dart';
import 'package:test/test.dart';

void main() {
  test('should add data to the cache', () {
    final cache = Cache();
    final key = CacheKey(start: DateTime.now());
    final results = <DateTime>[];
    cache.add(key, results);

    expect(cache.results, containsPair(key, results));
  });

  test('should return date from the cache by key', () {
    final cache = Cache();
    final key = CacheKey(start: DateTime.now());
    final results = <DateTime>[];
    cache.add(key, results);

    expect(cache.get(key), results);
  });
}
