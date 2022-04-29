import 'package:rrule/rrule.dart';

import '../utils.dart';

void main() {
  // There are more tests in `../../rrule_ical_test.dart`.

  testJsonCodec(
    'Annually on the 2nd Monday & the last Sunday of the month in October, 5 times',
    RecurrenceRule(
      frequency: Frequency.yearly,
      count: 5,
      byWeekDays: {
        ByWeekDayEntry(DateTime.sunday, -1),
        ByWeekDayEntry(DateTime.monday, 2),
      },
      byMonths: {10},
    ),
    json: <String, dynamic>{
      'freq': 'YEARLY',
      'count': 5,
      'byday': ['-1SU', '2MO'],
      // 'bymonth': 10,
      'bymonth': [10],
    },
  );

  testJsonCodec(
    'Decode JSON containing lists of type `List<dynamic>`',
    RecurrenceRule(
      frequency: Frequency.yearly,
      count: 5,
      byWeekDays: {
        ByWeekDayEntry(DateTime.sunday, -1),
        ByWeekDayEntry(DateTime.monday, 2),
      },
      byMonths: {10},
    ),
    json: <String, dynamic>{
      'freq': 'YEARLY',
      'count': 5,
      'byday': <dynamic>['-1SU', '2MO'],
      'bymonth': [10],
    },
  );

  testJsonCodec(
    'Every other month on the 1st, 15th & last day, until Tuesday, October 1, 2013 12:00:00 AM',
    RecurrenceRule(
      frequency: Frequency.monthly,
      interval: 2,
      byMonthDays: {1, 15, -1},
      until: DateTime.utc(2013, 10, 1),
    ),
    json: <String, dynamic>{
      'freq': 'MONTHLY',
      // 'until': '2013-10-01'
      'until': '2013-10-01T00:00:00',
      'interval': 2,
      // 'bymonthday': [1, 15, -1],
      'bymonthday': [-1, 1, 15],
    },
  );
}
