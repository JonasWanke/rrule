import 'package:rrule/src/codecs/string/ical.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('ICalProperty', () {
    group('Codec', () {
      testStringCodec(
        'line with complex parameters',
        codec: const ICalPropertyStringCodec(),
        value: const ICalProperty(
          name: 'RRULE',
          parameters: {
            'a': ['b'],
            'b': ['c;', 'd', 'ef,gs', 'afg'],
          },
          value: 'value',
        ),
        string: 'RRULE;a=b;b="c;",d,"ef,gs",afg:value',
      );

      test('simple unfolding', () {
        expect(
          const ICalPropertyStringCodec()
              .decode('na\r\n me:\r\n\tvalu\r\n  e\r\n \t'),
          const ICalProperty(name: 'name', value: 'value'),
        );
      });
      test('detects invalid newlines', () {
        expect(
          () => const ICalPropertyStringCodec().decode('na\rme:nvalue'),
          throwsFormatException,
        );
        expect(
          () => const ICalPropertyStringCodec().decode('name:val\nue'),
          throwsFormatException,
        );
        expect(
          () => const ICalPropertyStringCodec().decode('name:\r\nvalue'),
          throwsFormatException,
        );
      });
    });
  });
}
