import 'package:rrule/rrule.dart';
import 'package:test/test.dart';

void main() {
  group('rrule_json', () {
    test('Rrule(daily) to JSON', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.daily,
        count: 2,
        interval: 1,
      ).toJson();

      expect(rrule, <String, dynamic>{
        'frequency': 3,
        'count': 2,
        'interval': 1,
        'weekStart': 1
      });
    });

    test('Rrule(weekly) to JSON', () {
      final rrule = RecurrenceRule(
        frequency: Frequency.weekly,
        count: 2,
        interval: 1,
      ).toJson();

      expect(rrule, <String, dynamic>{
        'frequency': 2,
        'count': 2,
        'interval': 1,
        'weekStart': 1
      });
    });

    test('Rrule(weekly byWeekDays) to JSON', () {
      final rrule = RecurrenceRule(
          frequency: Frequency.weekly,
          count: 2,
          interval: 1,
          byWeekDays: {
            ByWeekDayEntry(DateTime.monday),
            ByWeekDayEntry(DateTime.thursday)
          }).toJson();

      expect(rrule, <String, dynamic>{
        'frequency': 2,
        'count': 2,
        'interval': 1,
        'byWeekDays': [
          {'day': 1},
          {'day': 4}
        ],
        'weekStart': 1
      });
    });

    test('Rrule(monthly by day) to JSON', () {
      final rrule = RecurrenceRule(
          frequency: Frequency.monthly,
          count: 2,
          interval: 1,
          byMonthDays: {2, 12, 31}).toJson();

      expect(rrule, <String, dynamic>{
        'frequency': 1,
        'count': 2,
        'interval': 1,
        'byMonthDays': [2, 12, 31],
        'weekStart': 1
      });
    });

    test('Rrule(monthly byWeekDays) to JSON', () {
      final rrule = RecurrenceRule(
          frequency: Frequency.monthly,
          count: 2,
          interval: 1,
          byWeekDays: {ByWeekDayEntry(DateTime.monday, 2)}).toJson();

      expect(rrule, <String, dynamic>{
        'frequency': 1,
        'count': 2,
        'interval': 1,
        'byWeekDays': [
          {'day': 1, 'occurrence': 2}
        ],
        'weekStart': 1
      });
    });

    test('Rrule(yearly) to JSON', () {
      final rrule = RecurrenceRule(
          frequency: Frequency.yearly,
          count: 2,
          interval: 1,
          byMonths: {3, 5, 9},
          byMonthDays: {2, 12, 31}).toJson();

      expect(rrule, <String, dynamic>{
        'frequency': 0,
        'count': 2,
        'interval': 1,
        'byMonths': [3, 5, 9],
        'byMonthDays': [2, 12, 31],
        'weekStart': 1
      });
    });

    test('Rrule(yearly byWeekDays) to JSON', () {
      final rrule = RecurrenceRule(
          frequency: Frequency.yearly,
          count: 2,
          interval: 1,
          byMonths: {
            3,
            5,
            9
          },
          byWeekDays: {
            ByWeekDayEntry(DateTime.wednesday, 1),
            ByWeekDayEntry(DateTime.wednesday, 3)
          }).toJson();

      expect(rrule, <String, dynamic>{
        'frequency': 0,
        'count': 2,
        'interval': 1,
        'byMonths': [3, 5, 9],
        'byWeekDays': [
          {'day': 3, 'occurrence': 1},
          {'day': 3, 'occurrence': 3}
        ],
        'weekStart': 1
      });
    });
  });

  group('json_rrule', () {
    test('JSON(daily) to Rrule', () {
      final json = RecurrenceRule.fromJson(
          <String, dynamic>{'frequency': 3, 'count': 2, 'interval': 1});

      expect(
          json,
          RecurrenceRule(
              frequency: Frequency.daily, count: 2, interval: 1, weekStart: 1));
    });

    test('JSON(weekly) to Rrule', () {
      final json = RecurrenceRule.fromJson(<String, dynamic>{
        'frequency': 2,
        'count': 2,
        'interval': 1,
        'weekStart': 1
      });

      expect(json,
          RecurrenceRule(frequency: Frequency.weekly, count: 2, interval: 1));
    });

    test('JSON(weekly byWeekDays) to Rrule', () {
      final json = RecurrenceRule.fromJson(<String, dynamic>{
        'frequency': 2,
        'count': 2,
        'interval': 1,
        'byWeekDays': [
          {'day': 1},
          {'day': 4}
        ],
      });

      expect(
          json,
          RecurrenceRule(
              frequency: Frequency.weekly,
              count: 2,
              interval: 1,
              byWeekDays: {
                ByWeekDayEntry(DateTime.monday),
                ByWeekDayEntry(DateTime.thursday)
              },
              weekStart: 1));
    });

    test('JSON(monthly by day) to Rrule', () {
      final json = RecurrenceRule.fromJson(<String, dynamic>{
        'frequency': 1,
        'count': 2,
        'interval': 1,
        'byMonthDays': [2, 12, 31],
      });

      expect(
          json,
          RecurrenceRule(
              frequency: Frequency.monthly,
              count: 2,
              interval: 1,
              byMonthDays: {2, 12, 31},
              weekStart: 1));
    });
  });

  test('JSON(monthly byWeekDays) to Rrule', () {
    final json = RecurrenceRule.fromJson(<String, dynamic>{
      'frequency': 1,
      'count': 2,
      'interval': 1,
      'byWeekDays': [
        {'day': 1, 'occurrence': 2}
      ],
    });

    expect(
        json,
        RecurrenceRule(
            frequency: Frequency.monthly,
            count: 2,
            interval: 1,
            byWeekDays: {ByWeekDayEntry(DateTime.monday, 2)},
            weekStart: 1));
  });

  test('JSON(yearly) to Rrule', () {
    final json = RecurrenceRule.fromJson(<String, dynamic>{
      'frequency': 0,
      'count': 2,
      'interval': 1,
      'byMonths': [3, 5, 9],
      'byMonthDays': [2, 12, 31],
    });

    expect(
        json,
        RecurrenceRule(
            frequency: Frequency.yearly,
            count: 2,
            interval: 1,
            byMonths: {3, 5, 9},
            byMonthDays: {2, 12, 31},
            weekStart: 1));
  });

  test('JSON(yearly byWeekDays) to Rrule', () {
    final json = RecurrenceRule.fromJson(<String, dynamic>{
      'frequency': 0,
      'count': 2,
      'interval': 1,
      'byMonths': [3, 5, 9],
      'byWeekDays': [
        {'day': 3, 'occurrence': 1},
        {'day': 3, 'occurrence': 3}
      ],
    });

    expect(
        json,
        RecurrenceRule(
            frequency: Frequency.yearly,
            count: 2,
            interval: 1,
            byMonths: {3, 5, 9},
            byWeekDays: {
              ByWeekDayEntry(DateTime.wednesday, 1),
              ByWeekDayEntry(DateTime.wednesday, 3)
            },
            weekStart: 1));
  });
}
