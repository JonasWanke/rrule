import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

/// Pattern corresponding to the `DATE` rule specified in
/// [RFC 5545 Section 3.3.4: Date](https://tools.ietf.org/html/rfc5545#section-3.3.4).
final iCalDatePattern = DateFormat('yyyyMMdd');

/// Pattern corresponding to the `TIME` rule specified in
/// [RFC 5545 Section 3.3.12: Time](https://tools.ietf.org/html/rfc5545#section-3.3.12).
final iCalTimePattern = DateFormat('HHmmss');

/// Pattern corresponding to the `DATE-TIME` rule specified in
/// [RFC 5545 Section 3.3.5: Date-Time](https://tools.ietf.org/html/rfc5545#section-3.3.5).
final iCalDateTimePattern =
    DateFormat("${iCalDatePattern.pattern}'T'${iCalTimePattern.pattern}");

/// Maximum year number supported by iCalendar.
const iCalMaxYear = 9999;

/// An iCalendar content line.
///
/// See [RFC 5545 Section 3.1](https://tools.ietf.org/html/rfc5545#section-3.1)
/// for more information.
@immutable
class ICalProperty {
  const ICalProperty({
    required this.name,
    this.parameters = const {},
    required this.value,
  });

  factory ICalProperty.parse(String contentLine) =>
      ICalPropertyStringCodec().decode(contentLine);

  final String name;
  final Map<String, List<String>> parameters;
  final String value;

  @override
  int get hashCode => Object.hash(name, parameters, value);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ICalProperty &&
        other.name == name &&
        DeepCollectionEquality().equals(other.parameters, parameters) &&
        other.value == value;
  }

  @override
  String toString() => ICalPropertyStringCodec().encode(this);
}

class ICalPropertyFormatException extends FormatException {
  const ICalPropertyFormatException(String message, String source, int offset)
      : super(message, source, offset);
}

@immutable
class ICalPropertyStringCodec extends Codec<ICalProperty, String> {
  const ICalPropertyStringCodec();

  @override
  Converter<ICalProperty, String> get encoder => _ICalPropertyToStringEncoder();

  @override
  Converter<String, ICalProperty> get decoder =>
      _ICalPropertyFromStringDecoder();
}

@immutable
class _ICalPropertyToStringEncoder extends Converter<ICalProperty, String> {
  const _ICalPropertyToStringEncoder();

  @override
  String convert(ICalProperty input) {
    final output = StringBuffer(input.name);

    for (final entry in input.parameters.entries) {
      output.writeICalParameter(entry.key, entry.value);
    }

    output
      ..write(':')
      ..write(input.value);
    return output.toString();
  }
}

extension _ICalPropertyToStringEncoderStringBuffer on StringBuffer {
  void writeICalParameter(String name, List<String> values) {
    write(';');
    write(name);
    write('=');
    writeAll(
      values.map<String>((v) => v.contains(RegExp('[,:;]')) ? '"$v"' : v),
      ',',
    );
  }
}

@immutable
class _ICalPropertyFromStringDecoder extends Converter<String, ICalProperty> {
  const _ICalPropertyFromStringDecoder();

  // https://tools.ietf.org/html/rfc3629#section-4
  static const _utf82 = '(?:[\xC2-\xDF]$_utf8Tail)';
  static const _utf83 =
      '(?:\xE0[\xA0-\xBF]$_utf8Tail|[\xE1-\xEC]$_utf8Tail{2}|\xED[\x80-\x9F]$_utf8Tail|[\xEE-\xEF]$_utf8Tail{2})';
  static const _utf84 =
      '(?:\xF0[\x90-\xBF]$_utf8Tail{2}|[\xF1-\xF3]$_utf8Tail{3}|\xF4[\x80-\x8F]$_utf8Tail{2})';
  static const _utf8Tail = '[\x80-\xBF]';

  // https://tools.ietf.org/html/rfc5234#appendix-B.1
  static const _alpha = '[\x41-\x5A\x61-\x7A]'; // A-Z / a-z
  static const _digit = '[\x30-\x39]'; // 0-9
  static const _dquote = '\x22'; // "
  static const _htab = '\x09';
  static const _sp = '\x20';
  static const _wsp = '[$_sp$_htab]';

  // https://tools.ietf.org/html/rfc5545#section-3.1
  static const _name = '(?:$_ianaToken|$_xName)';
  static const _ianaToken = '(?:$_alpha|$_digit|-)+';
  static const _xName = '(?:X-(?:$_vendorId-)?(?:$_alpha|$_digit|-))';
  static const _vendorId = '(?:(?:$_alpha|$_digit){3,})';
  static const _paramName = '(?:$_ianaToken|$_xName)';
  static const _param = '(?:($_paramName)=($_paramValue(?:,$_paramValue)*))';
  static const _paramValue = '(?:$_paramtext|$_quotedString)';
  static const _paramtext = '(?:$_safeChar*)';
  static const _quotedString = '(?:$_dquote$_qsafeChar*$_dquote)';
  static const _qsafeChar = '(?:$_wsp|\x21|[\x23-\x7E]|$_nonUsAscii)';
  static const _safeChar =
      '(?:$_wsp|\x21|[\x23-\x2B]|[\x2D-\x39]|[\x3C-\x7E]|$_nonUsAscii)';
  static const _nonUsAscii = '(?:$_utf82|$_utf83|$_utf84)';

  @override
  ICalProperty convert(String input) {
    final contentLine = _unfold(input);
    final lineBreakMatch = RegExp('[\r\n]').firstMatch(contentLine);
    if (lineBreakMatch != null) {
      throw ICalPropertyFormatException(
        'Unexpected line break detected',
        contentLine,
        lineBreakMatch.start,
      );
    }

    // Add some positive lookaheads to make sure we get everything
    final name = RegExp(_name).matchAsPrefix('$contentLine(?=[;:])')!.group(0)!;

    var index = name.length;
    final parameters = <String, List<String>>{};
    while (contentLine[index] == ';') {
      // Add 1 for the ";" separator.
      index++;

      final match = RegExp('$_param(?=[;:])').matchAsPrefix(contentLine, index);
      if (match == null) {
        throw ICalPropertyFormatException(
            'Expected parameter after ";" character', contentLine, index);
      }

      final name = match.group(1)!;
      index += name.length;

      final values = <String>[];
      while (contentLine[index] == '=' || contentLine[index] == ',') {
        // Add 1 for the "," separator.
        index++;

        final match =
            RegExp('$_paramValue(?=[,;:])').matchAsPrefix(contentLine, index);
        if (match == null) {
          throw ICalPropertyFormatException(
              'Invalid parameter value', contentLine, index);
        }

        final value = match.group(0)!;
        if (value.startsWith(_dquote)) {
          // value is quoted.
          values.add(value.substring(1, value.length - 1));
        } else {
          values.add(value);
        }

        index = match.end;
      }
      parameters[name] = values;

      index = match.end;
    }

    return ICalProperty(
      name: name,
      parameters: parameters,
      // Add 1 for the ":" separator.
      value: contentLine.substring(index + 1),
    );
  }

  /// Unfolds multiple-line representations of a content line back to a single
  /// line.
  ///
  /// See [RFC 5545 Section 3.1](https://tools.ietf.org/html/rfc5545#section-3.1)
  /// for more information.
  String _unfold(String input) {
    // TODO(JonasWanke): RFC 5545 Section 3.1. allows line breaks within a UTF-8 multi-octet sequence. That should not be allowed inside a String, so maybe support raw byte sequences?
    return input.replaceAll(RegExp('\r\n[ \t]+'), '');
  }
}
