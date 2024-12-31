import 'package:rrule/rrule.dart';
import 'package:rrule/src/codecs/text/encoder.dart';
import 'package:supernova/supernova.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'text_test.dart';

// ignore: prefer-correct-test-file-name
Future<void> main() async {
  final l10ns = await createL10n();

  final dataEditor = YamlEditor(await dataFile.readAsString());
  final data = (dataEditor.parseAt([]) as YamlMap)
      .cast<String, Map<dynamic, dynamic>>()
      .mapValues((it) => it.value.cast<String, String>());

  for (final MapEntry(key: locale, value: l10n)
      in l10ns.entries.sortedBy((it) => it.key)) {
    for (final MapEntry(key: rruleString, value: text) in data.entries) {
      final rrule = RecurrenceRule.fromString(rruleString);

      // TODO(JonasWanke): use codec directly when supporting fromText()
      final textEncoder = RecurrenceRuleToTextEncoder(l10n);

      if (l10ns.length > 1 && text.containsKey(locale)) {
        // Remove and re-add the entry to ensure they are ordered
        // alphabetically.
        dataEditor.remove([rruleString, locale]);
      }
      dataEditor.update([rruleString, locale], textEncoder.convert(rrule));
    }
  }

  await dataFile.writeAsString(dataEditor.toString());
}
