import 'package:rrule/src/codecs/string/ical.dart';
import 'package:test/test.dart';

void main() {
  group('ICalProperty', () {
    group('parse', () {
      test('line with complex parameters', () {
        expect(
          ICalProperty.parse('RRULE;a=b;b="c",d,"efgs",afg:value'),
          ICalProperty(
            name: 'RRULE',
            parameters: {
              'a': ['b'],
              'b': ['c', 'd', 'efgs', 'afg'],
            },
            value: 'value',
          ),
        );
      });
    });
  });
}
