import 'package:meta/meta.dart';

enum CacheMethod { before, after, between }

class Cache {
  final Map<int, List<DateTime>> _before = {};
  @visibleForTesting
  Map<int, List<DateTime>> get beforeResults => _before;

  final Map<int, List<DateTime>> _after = {};
  @visibleForTesting
  Map<int, List<DateTime>> get afterResults => _after;

  final Map<int, List<DateTime>> _between = {};
  @visibleForTesting
  Map<int, List<DateTime>> get betweenResults => _between;

  void add(CacheMethod method, int argumentsHash, List<DateTime> data) {
    switch (method) {
      case CacheMethod.before:
        return _before.addAll({argumentsHash: data});
      case CacheMethod.after:
        return _after.addAll({argumentsHash: data});
      case CacheMethod.between:
        return _between.addAll({argumentsHash: data});
    }
  }

  List<DateTime>? get(CacheMethod method, int argumentsHash) {
    switch (method) {
      case CacheMethod.before:
        return _before[argumentsHash];
      case CacheMethod.after:
        return _after[argumentsHash];
      case CacheMethod.between:
        return _between[argumentsHash];
    }
  }
}
