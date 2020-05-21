import 'package:rrule/src/codecs/string/ical.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('ICalProperty', () {
    group('Codec', () {
      testStringCodec(
        'line with complex parameters',
        codec: ICalPropertyStringCodec(),
        value: ICalProperty(
          name: 'RRULE',
          parameters: {
            'a': ['b'],
            'b': ['c;', 'd', 'ef,gs', 'afg'],
          },
          value: 'value',
        ),
        string: 'RRULE;a=b;b="c;",d,"ef,gs",afg:value',
      );
    });
  });
}
