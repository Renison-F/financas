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
  Future<void> sharePdf(String fileName, List<int> bytes);
}

final fileServiceProvider = Provider<FileService>((_) => PlatformFileService());

class PlatformFileService implements FileService {
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
  Future<void> shareText(String fileName, String text, String mimeType) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(text, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        subject: fileName,
      ),
    );
  }

  @override
  Future<void> sharePdf(String fileName, List<int> bytes) => Printing.sharePdf(
    bytes: bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
    filename: fileName,
  );
}
