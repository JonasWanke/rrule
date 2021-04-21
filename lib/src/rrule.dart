import 'package:meta/meta.dart';

import 'cache.dart';
import 'recurrence_rule.dart';
import 'utils.dart';

class RRule {
  RRule({required this.rule, required this.start, Cache? initialCache}) {
    if (initialCache != null) _cache = initialCache;
  }

  final RecurrenceRule rule;

  final DateTime start;

  Cache _cache = Cache();

  @visibleForTesting
  Cache get cache => _cache;

  List<DateTime> before({
    required DateTime date,
    bool inc = false,
  }) {
    final instances = rule.getInstances(start: start);
    final argumentsHash = hashList([instances, date, inc]);
    final fromCache = _cache.get(CacheMethod.before, argumentsHash);
    if (fromCache != null) return fromCache;

    final result = instances.takeWhile(inc ? _le(date) : _l(date)).toList();

    _cache.add(CacheMethod.before, argumentsHash, result);

    return result;
  }

  List<DateTime> after({required DateTime date, bool inc = false}) {
    assert(rule.until != null);

    final instances = rule.getInstances(start: start);
    final argumentsHash = hashList([instances, date, inc]);
    final fromCache = _cache.get(CacheMethod.after, argumentsHash);
    if (fromCache != null) return fromCache;

    final result = instances.skipWhile(inc ? _l(date) : _le(date)).toList();

    _cache.add(CacheMethod.after, argumentsHash, result);

    return result;
  }

  List<DateTime> between({
    required DateTime start,
    required DateTime end,
    bool inc = false,
  }) {
    final instances = rule.getInstances(start: start);
    final argumentsHash = hashList([instances, start, end, inc]);
    final fromCache = _cache.get(CacheMethod.between, argumentsHash);
    if (fromCache != null) return fromCache;

    final result = instances
        .skipWhile(inc ? _l(start) : _le(start))
        .takeWhile(inc ? _le(end) : _l(end))
        .toList();

    _cache.add(CacheMethod.between, argumentsHash, result);

    return result;
  }

  bool Function(DateTime date) _l(DateTime date) {
    return (value) => value < date;
  }

  bool Function(DateTime date) _le(DateTime date) {
    return (value) => value <= date;
  }
}
