import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:rrule/src/codecs/text/encoder.dart';
import 'package:test/test.dart';

@isTest
void testText(
  String description, {
  required String text,
  required String string,
  required RruleL10n Function() l10n,
}) {
  test(description, () async {
    final stringCodec = RecurrenceRuleStringCodec();
    final rrule = stringCodec.decode(string);

    // TODO(JonasWanke): use codec directly when supporting fromText()
    final textEncoder = RecurrenceRuleToTextEncoder(l10n());
    expect(textEncoder.convert(rrule), text);
  });
}
