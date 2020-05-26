import 'package:basics/basics.dart';
import 'package:time_machine/time_machine.dart';

import '../recurrence_rule.dart';
import 'date_set.dart';

Iterable<LocalDateTime> buildSetPositionsList(
  RecurrenceRule rrule,
  DateSet dateSet,
  Iterable<LocalTime> timeSet,
) sync* {
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

    final dateIndices = <int>[];
    for (final k in dateSet.start.to(dateSet.end)) {
      if (dateSet.isIncluded[k]) {
        dateIndices.add(k);
      }
    }

    final dateIndex = dateIndices[datePosition % dateIndices.length];
    final date = dateSet.firstDayOfYear.addDays(dateIndex);
    final time = timeList[timePosition];
    yield date.at(time);
  }
}
