import 'package:time/time.dart';

import '../recurrence_rule.dart';
import '../utils.dart';
import 'date_set.dart';

Iterable<DateTime> buildSetPositionsList(
  RecurrenceRule rrule,
  DateSet dateSet,
  Iterable<Duration> timeSet,
) sync* {
  assert(timeSet.every((it) => it.isValidRruleTimeOfDay));

  final dateIndices = dateSet.start
      .until(dateSet.end)
      .where((it) => dateSet.isIncluded[it])
      .toList();
  if (dateIndices.isEmpty) return;

  final timeList = timeSet.toList(growable: false);
  for (final setPosition in rrule.bySetPositions) {
    int datePosition;
    int timePosition;

    if (setPosition < 0) {
      datePosition = (setPosition / timeList.length).floor();
      timePosition = setPosition % timeList.length;
    } else {
      assert(setPosition > 0);
      datePosition = ((setPosition - 1) / timeList.length).floor();
      timePosition = (setPosition - 1) % timeList.length;
    }

    if (datePosition >= dateIndices.length ||
        -datePosition > dateIndices.length) {
      continue;
    }

    final dateIndex = dateIndices[datePosition % dateIndices.length];
    final date = dateSet.firstDayOfYear.add(dateIndex.days);
    yield date + timeList[timePosition];
  }
}
