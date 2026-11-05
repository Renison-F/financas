/// Picking text files and sharing generated files (CSV, JSON, PDF) through the platform share sheet.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PickedText {
  const PickedText(this.name, this.text);
  final String name;
  final String text;
}

abstract interface class FileService {
  Future<PickedText?> pickTextFile();
  Future<void> shareText(String fileName, String text, String mimeType);
  Future<void> shareBytes(String fileName, List<int> bytes, String mimeType);
  Future<void> sharePdf(String fileName, List<int> bytes);
}

final fileServiceProvider = Provider<FileService>((_) => PlatformFileService());

class PlatformFileService implements FileService {
  /// Exports and attachments are written here only for as long as the share sheet needs them.
  static Future<Directory> _shareDir() async {
    final tmp = await getTemporaryDirectory();
    return Directory(p.join(tmp.path, 'compartilhar')).create(recursive: true);
  }

  /// The share plugin keeps its own copy of the last shared file in this cache folder until the next
  /// share; an export with financial data must not sit there for days.
  static const _pluginFolder = 'share_plus';

  /// How long the receiving app gets to read the shared copy before it is removed.
  static const _grace = Duration(minutes: 3);
  static final _cameraLeftover = RegExp(
    r'^(image_picker|scaled_|CAP).*\.(jpe?g|png|heic)$',
    caseSensitive: false,
  );
  static Timer? _pending;

  /// Removes anything a previous share left behind (ours and the plugin's). Called when the app
  /// starts and a few minutes after each share.
  static Future<void> purgeShared() async {
    try {
      final tmp = await getTemporaryDirectory();
      // Our own folder, the share plugin's, and the copies the file picker makes of imported files.
      for (final name in const ['compartilhar', _pluginFolder, 'file_picker']) {
        final dir = Directory(p.join(tmp.path, name));
        if (!await dir.exists()) continue;
        await for (final f in dir.list()) {
          await f.delete(recursive: true);
        }
      }
      // Photos taken for attachments: the camera plugin leaves them at the root of the cache; the
      // attachment itself lives inside the encrypted database.
      await for (final f in tmp.list()) {
        if (f is File && _cameraLeftover.hasMatch(p.basename(f.path))) {
          await f.delete();
        }
      }
    } catch (_) {
      // Nothing to clean, or no temporary directory on this platform.
    }
  }

  static void _purgeLater() {
    _pending?.cancel();
    _pending = Timer(_grace, purgeShared);
  }

  @override
  Future<PickedText?> pickTextFile() async {
    final files = await FilePicker.pickFiles(type: FileType.any);
    final f = files.firstOrNull;
    if (f == null) return null;
    final bytes = await f.xFile.readAsBytes();
    // The picker hands over a copy in the cache; once read it has no reason to stay there.
    _purgeLater();
    String text;
    try {
      text = utf8.decode(bytes);
    } on FormatException {
      text = latin1.decode(bytes);
    }
    return PickedText(f.name, text);
  }

  @override
  Future<void> shareText(String fileName, String text, String mimeType) =>
      shareBytes(fileName, utf8.encode(text), mimeType);

  @override
  Future<void> shareBytes(
    String fileName,
    List<int> bytes,
    String mimeType,
  ) async {
    final dir = await _shareDir();
    // Only the last path segment: a name coming from data must not escape the folder.
    final file = File(p.join(dir.path, p.basename(fileName)));
    await file.writeAsBytes(bytes, flush: true);
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: mimeType)],
          subject: fileName,
        ),
      );
    } finally {
      // The share call returns when the sheet closes; the copy in the cache is no longer needed.
      // If the receiving app is still reading, the next start cleans up ([purgeShared]).
      try {
        await file.delete();
      } catch (_) {}
      _purgeLater();
    }
  }

  @override
  Future<void> sharePdf(String fileName, List<int> bytes) async {
    try {
      await Printing.sharePdf(
        bytes: bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
        filename: fileName,
      );
    } finally {
      _purgeLater();
    }
  }
}
