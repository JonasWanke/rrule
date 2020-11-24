import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:test/test.dart';
import 'package:time_machine/time_machine.dart';

import 'codecs/text/utils.dart';
import 'codecs/utils.dart';
import 'iteration/utils.dart';

@isTestGroup
void testRrule(
  String description, {
  @required String string,
  @required String text,
  @required RecurrenceRule rrule,
  @required LocalDateTime start,
  Iterable<LocalDate> expectedDates,
  Iterable<LocalDateTime> expectedDateTimes,
  bool isInfinite = false,
  @required RruleL10n l10n,
}) {
  group(description, () {
    testStringCodec(
      'StringCodec',
      codec: RecurrenceRuleStringCodec(
        toStringOptions: RecurrenceRuleToStringOptions(isTimeUtc: true),
      ),
      value: rrule,
      string: string,
    );

    // TODO(JonasWanke): Remove the condition when all properties are supported.
    if (text != null) {
      testText('TextCodec', text: text, string: string, l10n: l10n);
    }

    testRecurring(
      'recurrence',
      rrule: rrule,
      start: start,
      expectedDates: expectedDates,
      expectedDateTimes: expectedDateTimes,
      isInfinite: isInfinite,
    );
  });
}
