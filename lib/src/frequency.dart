import 'package:meta/meta.dart';

import 'codecs/string/string.dart';

@immutable
class Frequency implements Comparable<Frequency> {
  const Frequency._(this._value, this._string);

  static const Frequency secondly = Frequency._(6, recurFreqSecondly);
  static const Frequency minutely = Frequency._(5, recurFreqMinutely);
  static const Frequency hourly = Frequency._(4, recurFreqHourly);
  static const Frequency daily = Frequency._(3, recurFreqDaily);
  static const Frequency weekly = Frequency._(2, recurFreqWeekly);
  static const Frequency monthly = Frequency._(1, recurFreqMonthly);
  static const Frequency yearly = Frequency._(0, recurFreqYearly);

  final int _value;
  final String _string;

  @override
  int compareTo(Frequency other) => _value.compareTo(other._value);
  bool operator <(Frequency other) => _value < other._value;
  bool operator <=(Frequency other) => _value <= other._value;
  bool operator >(Frequency other) => _value > other._value;
  bool operator >=(Frequency other) => _value >= other._value;

  @override
  int get hashCode => _value.hashCode;
  @override
  bool operator ==(Object other) =>
      other is Frequency && other._value == _value;

  @override
  String toString() => _string;
}
