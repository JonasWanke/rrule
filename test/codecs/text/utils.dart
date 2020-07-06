import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:rrule/src/codecs/text/encoder.dart';
import 'package:test/test.dart';
import 'package:time_machine/time_machine.dart';

@isTest
void testText(
  String description, {
  @required String text,
  @required String string,
  @required RruleL10n l10n,
}) {
  test(description, () async {
    await TimeMachine.initialize();

    final stringCodec = RecurrenceRuleStringCodec();
    final rrule = stringCodec.decode(string);

    // TODO(JonasWanke): use codec directly when supporting fromText()
    final textEncoder = RecurrenceRuleToTextEncoder(
      l10n ?? await RruleL10nEn.create(),
    );
    expect(textEncoder.convert(rrule), text);
  });
}
