import 'package:flutter/material.dart';

void main() => runApp(const SerenaCashApp());

/// Placeholder root while the domain is migrated; replaced in M4 by the real app shell.
class SerenaCashApp extends StatelessWidget {
  const SerenaCashApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(home: Scaffold(body: Center(child: Text('SerenaCash'))));
}
