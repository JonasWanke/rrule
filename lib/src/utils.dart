import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

/// Combines the [Object.hashCode] values of an arbitrary number of objects
/// from an [Iterable] into one value. This function will return the same
/// value if given `null` as if given an empty list.
// Borrowed from dart:ui.
int hashList(Iterable<Object> arguments) {
  var result = 0;
  if (arguments != null) {
    for (final argument in arguments) {
      var hash = result;
      hash = 0x1fffffff & (hash + argument.hashCode);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      result = hash ^ (hash >> 6);
    }
  }
  result = 0x1fffffff & (result + ((0x03ffffff & result) << 3));
  result = result ^ (result >> 11);
  return 0x1fffffff & (result + ((0x00003fff & result) << 15));
}

extension FancyParseResult<T> on ParseResult<T> {
  T get valueOrNull => TryGetValue(null);
}

extension FancyLocalDate on LocalDate {
  LocalDate copyWith({int year, int month, int day}) {
    return LocalDate(
      year ?? this.year,
      month ?? monthOfYear,
      day ?? dayOfMonth,
    );
  }
}

extension FancyLocalTime on LocalTime {
  LocalTime copyWith({int hour, int minute, int second, int nanos}) {
    return LocalTime(
      hour ?? hourOfDay,
      minute ?? minuteOfHour,
      second ?? secondOfMinute,
      ns: nanos ?? nanosecondOfSecond,
    );
  }
}

extension FancyIterable<T> on Iterable<T> {
  bool isEmptyOrContains(T item) => isEmpty || contains(item);
}
