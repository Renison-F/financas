/// Attachments of a saved transaction: photo (camera) or file, stored as bytes inside the encrypted database.
library;

import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../data/files/file_service.dart';
import '../../data/media/image_metadata.dart';
import '../../domain/entities/entities.dart';
import '../../ui/components/components.dart';

const maxAttachmentBytes = 10 * 1024 * 1024;

class AttachmentsSection extends ConsumerStatefulWidget {
  const AttachmentsSection({super.key, required this.transaction});
  final Transaction transaction;
  @override
  ConsumerState<AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends ConsumerState<AttachmentsSection> {
  String? _error;
  bool _busy = false;

  Future<void> _add(List<int> raw, String fileName, String mime) async {
    final l = context.l10n;
    // A photo keeps its picture and loses its metadata (GPS position, device, date) before it is
    // stored; other kinds of file are kept exactly as they are.
    final bytes = stripImageMetadata(Uint8List.fromList(raw));
    if (bytes.length > maxAttachmentBytes) {
      return setState(() => _error = l.attachmentTooBig);
    }
    final ctl = ref.read(appControllerProvider.notifier);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ctl.addAttachment(
        widget.transaction.id,
        Attachment(
          id: ctl.newId(),
          fileName: fileName,
          mimeType: mime,
          sizeBytes: bytes.length,
          sha256: crypto.sha256.convert(bytes).toString(),
        ),
        bytes,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _photo() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 2000,
    );
    if (x == null) return;
    await _add(
      await x.readAsBytes(),
      x.name.isEmpty ? 'foto.jpg' : x.name,
      'image/jpeg',
    );
  }

  Future<void> _file() async {
    final files = await FilePicker.pickFiles(type: FileType.any);
    final f = files.firstOrNull;
    if (f == null) return;
    final bytes = await f.xFile.readAsBytes();
    await _add(bytes, f.name, f.xFile.mimeType ?? 'application/octet-stream');
  }

  Future<void> _open(Attachment a) async {
    final bytes = await ref
        .read(appControllerProvider.notifier)
        .attachmentBytes(a.id);
    if (bytes == null) return;
    // Through the file service: the decrypted copy is removed as soon as the share sheet closes.
    await ref
        .read(fileServiceProvider)
        .shareBytes(a.fileName, bytes, a.mimeType);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final t =
        s.ledger.transactionById(widget.transaction.id) ?? widget.transaction;
    final allowed = s.access.features.contains('attachments');
    return SCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(title: l.attachmentsTitle),
          if (t.attachments.isEmpty)
            Text(
              l.attachmentCount(0),
              style: Type.bodySmall.copyWith(color: c.textMuted),
            )
          else
            for (final a in t.attachments)
              ListRow(
                icon: a.mimeType.startsWith('image/')
                    ? SIconName.camera
                    : SIconName.receipt,
                title: a.fileName,
                description: '${(a.sizeBytes / 1024).toStringAsFixed(0)} KB',
                trailing: SIconButton(
                  icon: SIconName.trash,
                  label: l.removeAttachment,
                  onPressed: () => ref
                      .read(appControllerProvider.notifier)
                      .removeAttachment(a.id),
                ),
                onTap: () => _open(a),
              ),
          const SizedBox(height: Spacing.xs),
          if (!allowed) ...[
            Text(
              l.attachmentsPlusHint,
              style: Type.caption.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: 6),
            SButton(
              label: l.knowPlus,
              variant: SButtonVariant.secondary,
              compact: true,
              onPressed: () => context.push('/paywall?feature=attachments'),
            ),
          ] else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SButton(
                  label: l.addPhoto,
                  icon: SIconName.camera,
                  variant: SButtonVariant.secondary,
                  compact: true,
                  loading: _busy,
                  onPressed: _photo,
                ),
                SButton(
                  label: l.addFile,
                  icon: SIconName.upload,
                  variant: SButtonVariant.secondary,
                  compact: true,
                  onPressed: _busy ? null : _file,
                ),
              ],
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _error!,
                style: Type.bodySmall.copyWith(color: c.negative),
              ),
            ),
        ],
      ),
    );
  }
}
