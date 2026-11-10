/// Removes from a JPEG everything that describes where, when and with what it was taken (EXIF with
/// GPS position, XMP, IPTC, comments) before the photo is kept. The picture itself is not touched:
/// not one pixel is re-encoded. The only thing kept from the metadata is the orientation, because
/// without it a photo taken upright would be shown lying on its side.
library;

import 'dart:typed_data';

const _soi = 0xD8, _eoi = 0xD9, _sos = 0xDA;
const _app0 = 0xE0, _app1 = 0xE1, _app2 = 0xE2, _app14 = 0xEE, _com = 0xFE;

bool isJpeg(Uint8List bytes) =>
    bytes.length > 3 && bytes[0] == 0xFF && bytes[1] == _soi;

int _u16(Uint8List b, int o, bool little) =>
    little ? b[o] | (b[o + 1] << 8) : (b[o] << 8) | b[o + 1];
int _u32(Uint8List b, int o, bool little) => little
    ? b[o] | (b[o + 1] << 8) | (b[o + 2] << 16) | (b[o + 3] << 24)
    : (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3];

/// The orientation (1 to 8) written in an EXIF block, or null when it has none or cannot be read.
/// [exif] is the payload of the APP1 segment, starting at "Exif\0\0".
int? _orientationOf(Uint8List exif) {
  // "Exif\0\0" + TIFF header (8) + entry count (2)
  if (exif.length < 16) return null;
  const sig = [0x45, 0x78, 0x69, 0x66, 0x00, 0x00];
  for (var i = 0; i < 6; i++) {
    if (exif[i] != sig[i]) return null;
  }
  const t = 6;
  final little = exif[t] == 0x49 && exif[t + 1] == 0x49;
  final big = exif[t] == 0x4D && exif[t + 1] == 0x4D;
  if (!little && !big) return null;
  if (_u16(exif, t + 2, little) != 42) return null;
  final ifd = t + _u32(exif, t + 4, little);
  if (ifd < t + 8 || ifd + 2 > exif.length) return null;
  final count = _u16(exif, ifd, little);
  for (var i = 0; i < count; i++) {
    final e = ifd + 2 + i * 12;
    if (e + 12 > exif.length) return null;
    if (_u16(exif, e, little) != 0x0112) continue;
    if (_u16(exif, e + 2, little) != 3) return null; // SHORT
    final v = _u16(exif, e + 8, little);
    return v >= 1 && v <= 8 ? v : null;
  }
  return null;
}

/// An EXIF block that says the orientation and nothing else.
Uint8List _orientationSegment(int orientation) => Uint8List.fromList([
  0xFF, _app1, 0x00, 0x22, // marker, length 34
  0x45, 0x78, 0x69, 0x66, 0x00, 0x00, // "Exif\0\0"
  0x4D, 0x4D, 0x00, 0x2A, 0x00, 0x00, 0x00, 0x08, // big-endian TIFF, IFD at 8
  0x00, 0x01, // one entry
  0x01, 0x12, 0x00, 0x03, 0x00, 0x00, 0x00, 0x01, // Orientation, SHORT, count 1
  0x00, orientation, 0x00, 0x00, // the value
  0x00, 0x00, 0x00, 0x00, // no further IFD
]);

/// [bytes] without its metadata. Anything that is not a well-formed JPEG comes back unchanged
/// (returning a damaged photo would be worse than keeping one as it is); the caller can tell with
/// [isJpeg] whether the format is one this function handles.
Uint8List stripImageMetadata(Uint8List bytes) {
  if (!isJpeg(bytes)) return bytes;
  final out = BytesBuilder(copy: false);
  final kept = <Uint8List>[];
  int? orientation;
  var i = 2;
  while (true) {
    if (i + 4 > bytes.length || bytes[i] != 0xFF) return bytes;
    // Padding bytes before a marker.
    while (i < bytes.length && bytes[i] == 0xFF && bytes[i + 1] == 0xFF) {
      i++;
      if (i + 1 >= bytes.length) return bytes;
    }
    final marker = bytes[i + 1];
    if (marker == _eoi) return bytes; // no picture data before the end
    // Markers that stand alone, with no length.
    if (marker == 0x01 || (marker >= 0xD0 && marker <= 0xD7)) {
      kept.add(Uint8List.sublistView(bytes, i, i + 2));
      i += 2;
      continue;
    }
    // The picture data starts here: the rest is copied as it is.
    if (marker == _sos) break;
    if (i + 4 > bytes.length) return bytes;
    final length = (bytes[i + 2] << 8) | bytes[i + 3];
    if (length < 2 || i + 2 + length > bytes.length) return bytes;
    final end = i + 2 + length;
    final isApp = marker >= _app0 && marker <= 0xEF;
    if (marker == _app1) {
      orientation ??= _orientationOf(Uint8List.sublistView(bytes, i + 4, end));
    }
    // Kept: JFIF header, colour profile, Adobe colour transform, and every segment that describes
    // the picture itself (tables, frame). Dropped: EXIF, XMP, IPTC, maker data, comments.
    final keep =
        marker == _app0 ||
        marker == _app2 ||
        marker == _app14 ||
        (!isApp && marker != _com);
    if (keep) kept.add(Uint8List.sublistView(bytes, i, end));
    i = end;
  }
  out.add(const [0xFF, _soi]);
  if (orientation != null && orientation != 1) {
    out.add(_orientationSegment(orientation));
  }
  for (final k in kept) {
    out.add(k);
  }
  out.add(Uint8List.sublistView(bytes, i));
  return out.takeBytes();
}
