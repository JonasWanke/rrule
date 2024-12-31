import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:rrule/src/codecs/text/encoder.dart';
import 'package:test/test.dart';

import 'codecs/utils.dart';
import 'iteration/utils.dart';

@isTestGroup
// ignore: avoid-top-level-members-in-tests
void testRrule(
  String description, {
  required String string,
  required String? textEn,
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
    if (textEn != null) {
      testTextEn('TextCodec', textEn: textEn, string: string, l10n: l10n);
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

@isTest
// ignore: avoid-top-level-members-in-tests
void testTextEn(
  String description, {
  required String textEn,
  required String string,
  required RruleL10n Function() l10n,
}) {
  test(description, () async {
    const stringCodec = RecurrenceRuleStringCodec();
    final rrule = stringCodec.decode(string);

    // TODO(JonasWanke): use codec directly when supporting fromText()
    final textEncoder = RecurrenceRuleToTextEncoder(l10n());
    expect(textEncoder.convert(rrule), textEn);
  });
}
