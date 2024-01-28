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
    final correctedSetPosition =
        setPosition < 0 ? setPosition : setPosition - 1;
    final datePosition = correctedSetPosition ~/ timeList.length;
    final timePosition = correctedSetPosition % timeList.length;

    if (datePosition >= dateIndices.length ||
        -datePosition > dateIndices.length) {
      continue;
    }

    final dateIndex = dateIndices[datePosition % dateIndices.length];
    final date = dateSet.firstDayOfYear.add(dateIndex.days);
    yield date + timeList[timePosition];
  }
}
