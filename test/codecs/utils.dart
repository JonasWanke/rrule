import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:rrule/src/codecs/json/decoder.dart';
import 'package:rrule/src/codecs/json/encoder.dart';
import 'package:test/test.dart';

@isTestGroup
void testStringCodec<T>(
  String description, {
  required Codec<T, String> codec,
  required T value,
  required String string,
}) {
  group(description, () {
    test('to string', () => expect(codec.encode(value), string));
    test('from string', () => expect(codec.decode(string), value));
  });
}

@isTest
void testJsonCodec(
  String description,
  RecurrenceRule value, {
  Map<String, dynamic>? json,
}) {
  test(description, () {
    const encoder = RecurrenceRuleToJsonEncoder();
    const decoder = RecurrenceRuleFromJsonDecoder();

    final encoded = encoder.convert(value);
    if (json != null) expect(encoded, json);

    expect(decoder.convert(encoded), value);
  });
}
