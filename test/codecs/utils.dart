import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:test/test.dart';

@isTestGroup
void testStringCodec<T>(
  String description, {
  @required Codec<T, String> codec,
  @required T value,
  @required String string,
}) {
  group(description, () {
    test('to string', () => expect(codec.encode(value), string));
    test('from string', () => expect(codec.decode(string), value));
  });
}
