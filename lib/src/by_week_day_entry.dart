import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'codecs/string/string.dart';
import 'recurrence_rule.dart';
import 'utils.dart';

/// Corresponds to a single entry in the `BYDAY` list of a [RecurrenceRule].
@immutable
class ByWeekDayEntry implements Comparable<ByWeekDayEntry> {
  ByWeekDayEntry(this.day, [this.occurrence])
      : assert(day.isValidRruleDayOfWeek),
        assert(occurrence == null || debugCheckIsValidWeekNumber(occurrence));

  final int day;

  final int? occurrence;
  bool get hasOccurrence => occurrence != null;
  bool get hasNoOccurrence => !hasOccurrence;

  @override
  int compareTo(ByWeekDayEntry other) {
    final result = (occurrence ?? 0).compareTo(other.occurrence ?? 0);
    if (result != 0) return result;

    // This correctly starts with monday.
    return day.compareTo(other.day);
  }

  @override
  int get hashCode => hashList([day, occurrence]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ByWeekDayEntry &&
        other.day == day &&
        other.occurrence == occurrence;
  }

  @override
  String toString() => ByWeekDayEntryStringCodec().encode(this);

  factory ByWeekDayEntry.fromJson(Map<String, int?>? json) {
    if (json == null) {
      throw ArgumentError('The json object is null');
    }
    return ByWeekDayEntry(json['day']!, json['occurrence']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['day'] = day;
    data['occurrence'] = occurrence;
    return data..removeWhere((key, dynamic value) => value == null);
  }
}

extension ByWeekDayEntryIterable on Iterable<ByWeekDayEntry> {
  bool get anyHasOccurrence => any((e) => e.hasOccurrence);
  bool get noneHasOccurrence => none((e) => e.hasOccurrence);
}
