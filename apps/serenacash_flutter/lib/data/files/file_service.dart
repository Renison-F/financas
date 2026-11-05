/// Picking text files and sharing generated files (CSV, JSON, PDF) through the platform share sheet.
library;

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

  /// Removes anything a previous share left behind (the app was killed while the sheet was open, or
  /// the receiving app was still reading). Called when the app starts.
  static Future<void> purgeShared() async {
    try {
      final dir = await _shareDir();
      await for (final f in dir.list()) {
        await f.delete(recursive: true);
      }
    } catch (_) {
      // Nothing to clean, or no temporary directory on this platform.
    }
  }

  @override
  Future<PickedText?> pickTextFile() async {
    final files = await FilePicker.pickFiles(type: FileType.any);
    final f = files.firstOrNull;
    if (f == null) return null;
    final bytes = await f.xFile.readAsBytes();
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
    }
  }

  @override
  Future<void> sharePdf(String fileName, List<int> bytes) => Printing.sharePdf(
    bytes: bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
    filename: fileName,
  );
}
