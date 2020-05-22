import 'package:meta/meta.dart';

import 'codecs/string/string.dart';

@immutable
class RecurrenceFrequency implements Comparable<RecurrenceFrequency> {
  const RecurrenceFrequency._(this._value, this._string)
      : assert(_value != null),
        assert(_string != null);

  static const RecurrenceFrequency secondly =
      RecurrenceFrequency._(0, recurFreqSecondly);
  static const RecurrenceFrequency minutely =
      RecurrenceFrequency._(1, recurFreqMinutely);
  static const RecurrenceFrequency hourly =
      RecurrenceFrequency._(2, recurFreqHourly);
  static const RecurrenceFrequency daily =
      RecurrenceFrequency._(3, recurFreqDaily);
  static const RecurrenceFrequency weekly =
      RecurrenceFrequency._(4, recurFreqWeekly);
  static const RecurrenceFrequency monthly =
      RecurrenceFrequency._(5, recurFreqMonthly);
  static const RecurrenceFrequency yearly =
      RecurrenceFrequency._(6, recurFreqYearly);

  final int _value;
  final String _string;

  @override
  int compareTo(RecurrenceFrequency other) => _value.compareTo(other._value);
  bool operator <(RecurrenceFrequency other) => _value < other._value;
  bool operator <=(RecurrenceFrequency other) => _value <= other._value;
  bool operator >(RecurrenceFrequency other) => _value > other._value;
  bool operator >=(RecurrenceFrequency other) => _value >= other._value;

  @override
  int get hashCode => _value.hashCode;
  @override
  bool operator ==(Object other) =>
      other is RecurrenceFrequency && other._value == _value;

  @override
  String toString() => _string;
}
