import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:test/test.dart';

import 'codecs/text/utils.dart';
import 'codecs/utils.dart';
import 'iteration/utils.dart';

@isTestGroup
// ignore: avoid-top-level-members-in-tests
void testRrule(
  String description, {
  required String string,
  required String? text,
  required RecurrenceRule rrule,
  required DateTime start,
  required Iterable<DateTime> expected,
  bool isInfinite = false,
  required RruleL10n Function() l10n,
}) {
  group(description, () {
    testStringCodec(
      'StringCodec',
      codec: const RecurrenceRuleStringCodec(
        toStringOptions: RecurrenceRuleToStringOptions(isTimeUtc: true),
      ),
      value: rrule,
      string: string,
    );
    testJsonCodec('JsonCodec', rrule);

    // TODO(JonasWanke): Remove the condition when all properties are supported.
    if (text != null) {
      testText('TextCodec', text: text, string: string, l10n: l10n);
    }

    testRecurring(
      'recurrence',
      rrule: rrule,
      start: start,
      expected: expected,
      isInfinite: isInfinite,
    );
  });
}
