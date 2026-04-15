#!/usr/bin/env dart
/// Syncs mustache templates from lark_template/lark_note_app/__brick__/
/// into Lark's embedded Dart constants.
///
/// Usage:
///   dart run tools/sync_brick.dart
///
/// Reads template files from:
///   bricks/lark_template/lark_note_app/__brick__/ (git submodule)
///
/// Generates:
///   lib/src/wizard/generator/brick_templates.g.dart

import 'dart:io';

/// Relative path to the brick templates via git submodule.
const brickSourceDir =
    'bricks/lark_template/lark_note_app/__brick__';
const outputFile =
    'lib/src/wizard/generator/brick_templates.g.dart';

void main() {
  final brickDir = Directory(brickSourceDir);
  if (!brickDir.existsSync()) {
    stderr.writeln('Error: Brick source directory not found: $brickSourceDir');
    exit(1);
  }

  final templates = <String, String>{};

  void walkDir(Directory dir, String relativePath) {
    for (final entity in dir.listSync()) {
      final name = entity.path.split('/').last;
      // Skip mustache-syntax directories
      if (name.startsWith('{{')) continue;

      if (entity is File) {
        final content = entity.readAsStringSync();
        templates['$relativePath$name'] = content;
      } else if (entity is Directory) {
        walkDir(entity, '$relativePath$name/');
      }
    }
  }

  walkDir(brickDir, '');

  // Generate Dart file using raw triple-quoted strings (r'''..''')
  // to preserve $variable and other Dart-significant syntax in templates.
  final lines = <String>[];
  lines.add('/// Auto-generated from lark_note_app brick templates.');
  lines.add('/// DO NOT EDIT MANUALLY - regenerate with: dart run tools/sync_brick.dart');
  lines.add('final Map<String, String> brickTemplates = {');

  for (final path in templates.keys.toList()..sort()) {
    final content = templates[path]!;
    // Raw triple-quoted strings handle $ and \ naturally.
    // Only ''' (triple single-quote) would break, but templates don't use that.
    lines.add("  r'$path': r'''$content''',");
  }

  lines.add('};');
  lines.add('');

  File(outputFile).writeAsStringSync(lines.join('\n'));
  stdout.writeln('Generated ${templates.length} template entries to $outputFile');
}
