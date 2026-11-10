/// Privacidade das fotos guardadas (evidências de compra e anexos): os metadados saem, a imagem
/// fica byte a byte igual e a orientação é preservada.
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/media/image_metadata.dart';

/// One JPEG segment: marker, length and payload.
List<int> _seg(int marker, List<int> payload) => [
  0xFF,
  marker,
  (payload.length + 2) >> 8,
  (payload.length + 2) & 0xFF,
  ...payload,
];

/// An EXIF payload with the orientation and a GPS pointer, in the byte order asked for.
List<int> _exif({required int orientation, bool little = false}) {
  List<int> u16(int v) => little ? [v & 0xFF, v >> 8] : [v >> 8, v & 0xFF];
  List<int> u32(int v) => little
      ? [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, v >> 24]
      : [v >> 24, (v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF];
  return [
    ...'Exif'.codeUnits, 0, 0,
    ...(little ? [0x49, 0x49] : [0x4D, 0x4D]),
    ...u16(42),
    ...u32(8),
    ...u16(2),
    // GPSInfo IFD pointer (the tag that leads to latitude and longitude)
    ...u16(0x8825), ...u16(4), ...u32(1), ...u32(38),
    ...u16(0x0112), ...u16(3), ...u32(1), ...u16(orientation), ...u16(0),
    ...u32(0),
    // "GPS data"
    ...'-3.7319,-38.5267'.codeUnits,
  ];
}

const _picture = [0x11, 0x22, 0x33, 0xFF, 0x00, 0x44, 0x55];

Uint8List _jpeg({
  int orientation = 6,
  bool little = false,
  bool withExif = true,
}) => Uint8List.fromList([
  0xFF, 0xD8,
  ..._seg(0xE0, [...'JFIF'.codeUnits, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0]),
  if (withExif) ..._seg(0xE1, _exif(orientation: orientation, little: little)),
  ..._seg(
    0xE1,
    'http://ns.adobe.com/xap/1.0/\u0000<x>Rua das Flores 10</x>'.codeUnits,
  ),
  ..._seg(0xED, 'Photoshop 3.0 autor: Fulano'.codeUnits),
  ..._seg(0xFE, 'tirada no celular de Fulano'.codeUnits),
  ..._seg(0xE2, 'ICC_PROFILE perfil de cor'.codeUnits),
  ..._seg(0xDB, List.filled(65, 7)), // quantization table
  ..._seg(0xC0, [8, 0, 2, 0, 2, 1, 1, 0x11, 0]), // frame header
  ..._seg(0xC4, List.filled(20, 3)), // Huffman table
  ..._seg(0xDA, [1, 1, 0, 0, 0x3F, 0]), // start of scan
  ..._picture,
  0xFF, 0xD9,
]);

bool _contains(Uint8List haystack, String needle) {
  final n = needle.codeUnits;
  outer:
  for (var i = 0; i + n.length <= haystack.length; i++) {
    for (var j = 0; j < n.length; j++) {
      if (haystack[i + j] != n[j]) continue outer;
    }
    return true;
  }
  return false;
}

/// Everything from the start-of-scan marker on: the picture data.
Uint8List _scan(Uint8List b) {
  for (var i = 0; i + 1 < b.length; i++) {
    if (b[i] == 0xFF && b[i + 1] == 0xDA) return Uint8List.sublistView(b, i);
  }
  return Uint8List(0);
}

void main() {
  test(
    'position, texts and device data leave; the picture stays byte for byte',
    () {
      final original = _jpeg();
      final before = Uint8List.fromList(original);
      final clean = stripImageMetadata(original);
      expect(original, before, reason: 'a entrada não é alterada');
      for (final secret in [
        '-3.7319,-38.5267',
        'Rua das Flores',
        'Fulano',
        'ns.adobe.com',
        'Photoshop',
      ]) {
        expect(
          _contains(original, secret),
          isTrue,
          reason: 'estava lá: $secret',
        );
        expect(_contains(clean, secret), isFalse, reason: 'saiu: $secret');
      }
      expect(_scan(clean), _scan(original), reason: 'dados da imagem intactos');
      // what describes the picture is still there
      expect(_contains(clean, 'JFIF'), isTrue);
      expect(_contains(clean, 'ICC_PROFILE'), isTrue);
      expect(clean.length, lessThan(original.length));
      expect(isJpeg(clean), isTrue);
      expect(clean.sublist(clean.length - 2), [0xFF, 0xD9]);
    },
  );

  test(
    'the orientation is kept, in either byte order, and nothing else from EXIF',
    () {
      for (final little in [false, true]) {
        for (final orientation in [3, 6, 8]) {
          final clean = stripImageMetadata(
            _jpeg(orientation: orientation, little: little),
          );
          // the app writes its own minimal block right after the start of the file
          expect(clean.sublist(0, 4), [0xFF, 0xD8, 0xFF, 0xE1]);
          expect(clean.sublist(4, 6), [0x00, 0x22]);
          expect(clean[31], orientation, reason: 'little=$little');
          expect(_contains(clean, '-3.7319'), isFalse);
          // cleaning what is already clean changes nothing
          expect(stripImageMetadata(clean), clean);
        }
      }
    },
  );

  test('an upright photo, or one without EXIF, gets no EXIF block at all', () {
    for (final jpeg in [_jpeg(orientation: 1), _jpeg(withExif: false)]) {
      final clean = stripImageMetadata(jpeg);
      expect(clean.sublist(0, 4), [
        0xFF,
        0xD8,
        0xFF,
        0xE0,
      ], reason: 'JFIF primeiro');
      expect(_contains(clean, 'Exif'), isFalse);
    }
  });

  test('what is not a well-formed JPEG comes back exactly as it was', () {
    final png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 1, 2, 3]);
    expect(stripImageMetadata(png), same(png));
    expect(isJpeg(png), isFalse);
    final empty = Uint8List(0);
    expect(stripImageMetadata(empty), same(empty));
    // cut in the middle of a segment, a length that points past the end, no picture data
    final good = _jpeg();
    for (final broken in [
      Uint8List.sublistView(good, 0, 30),
      Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE1, 0xFF, 0xFF, 1, 2]),
      Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]),
      Uint8List.fromList([0xFF, 0xD8, 0x00, 0x00, 0x00, 0x00]),
      Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE1, 0x00, 0x01, 0x00]),
    ]) {
      expect(stripImageMetadata(broken), same(broken));
    }
    // an EXIF block that cannot be parsed is dropped, and the photo is treated as upright
    final odd = Uint8List.fromList([
      0xFF,
      0xD8,
      ..._seg(0xE1, [
        ...'Exif'.codeUnits,
        0,
        0,
        0x58,
        0x58,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        0,
      ]),
      ..._seg(0xDA, [1, 1, 0, 0, 0x3F, 0]),
      ..._picture,
      0xFF,
      0xD9,
    ]);
    final clean = stripImageMetadata(odd);
    expect(_contains(clean, 'Exif'), isFalse);
    expect(_scan(clean), _scan(odd));
  });
}
