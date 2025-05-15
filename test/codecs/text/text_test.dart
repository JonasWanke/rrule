// ignore_for_file: lines_longer_than_80_chars

import 'package:rrule/rrule.dart';
import 'package:rrule/src/codecs/text/encoder.dart';
import 'package:supernova/supernova.dart';
import 'package:supernova/supernova_io.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

// ignore: avoid-top-level-members-in-tests
final dataFile = File('test/codecs/text/data.yaml');

Future<void> main() async {
  final l10n = await createL10n();

  final dataString = await dataFile.readAsString();
  final data = (loadYaml(dataString) as Map<dynamic, dynamic>)
      .cast<String, Map<dynamic, dynamic>>()
      .mapValues((it) => it.value.cast<String, String>());

  for (final MapEntry(key: locale, value: l10n) in l10n.entries) {
    group(locale, () {
      for (final MapEntry(key: rruleString, value: text) in data.entries) {
        test(rruleString, () {
          final rrule = RecurrenceRule.fromString(rruleString);

          // TODO(JonasWanke): use codec directly when supporting fromText()
          final textEncoder = RecurrenceRuleToTextEncoder(l10n);

          final localizedText = text[locale];
          if (localizedText == null) {
            throw StateError('Missing localized text for $locale');
          }

          expect(textEncoder.convert(rrule), text[locale]);
        });
      }
    });
  }
}

// ignore: avoid-top-level-members-in-tests
Future<Map<String, RruleL10n>> createL10n() async {
  return {
    'en': await RruleL10nEn.create(),
    'nl': await RruleL10nNl.create(),
    'de': await RruleL10nDe.create(),
  };
}
