import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'data/files/file_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Exports and attachments shared in an earlier run must not stay readable in the cache.
  unawaited(PlatformFileService.purgeShared());
  runApp(const ProviderScope(child: SerenaCashApp()));
}
