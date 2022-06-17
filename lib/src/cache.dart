import 'package:meta/meta.dart';

@immutable
class CacheKey {
  const CacheKey({
    required this.start,
    this.after,
    this.includeAfter = false,
    this.before,
    this.includeBefore = false,
  });

  final DateTime start;
  final DateTime? after;
  final bool includeAfter;
  final DateTime? before;
  final bool includeBefore;

  @override
  int get hashCode =>
      Object.hash(start, after, includeAfter, before, includeBefore);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is CacheKey &&
        other.after == after &&
        other.includeAfter == includeAfter &&
        other.before == before &&
        other.includeBefore == includeBefore;
  }
}

class Cache {
  final Map<CacheKey, List<DateTime>> _results = {};

  @visibleForTesting
  Map<CacheKey, List<DateTime>> get results => _results;

  void add(CacheKey key, List<DateTime> data) {
    _results[key] = data;
  }

  List<DateTime>? get(CacheKey key) {
    return _results[key];
  }
}
