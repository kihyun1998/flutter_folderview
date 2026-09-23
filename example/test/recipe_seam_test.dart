import 'dart:io';

import 'package:example/app/destinations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

/// Import prefixes a file shown in the Code pane may use.
const allowedImports = [
  'dart:',
  'package:flutter/',
  'package:flutter_folderview/',
];

const recipesDir = 'lib/recipes';

/// The imports and exports in [source] that fall outside [allowedImports].
List<String> disallowedImports(String source) =>
    RegExp(r'''^\s*(?:import|export)\s+(['"])(.+?)\1''', multiLine: true)
        .allMatches(source)
        .map((m) => m.group(2)!)
        .where((uri) => !allowedImports.any(uri.startsWith))
        .toList();

List<File> recipeFiles() {
  final dir = Directory(recipesDir);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
}

/// The `source` of every destination the example registers.
List<String> registeredSources() {
  final destinations = FolderViewDestinations();
  final sources = destinations.all
      .whereType<StageDestination>()
      .map((d) => d.source)
      .whereType<String>()
      .toList();
  destinations.dispose();
  return sources;
}

void main() {
  test(
    'every recipe file imports only Flutter, flutter_folderview and dart:',
    () {
      final violations = {
        for (final file in recipeFiles())
          if (disallowedImports(file.readAsStringSync()).isNotEmpty)
            file.path: disallowedImports(file.readAsStringSync()),
      };
      expect(violations, isEmpty);
    },
  );

  test('lib/recipes holds at least one recipe', () {
    expect(recipeFiles(), isNotEmpty);
  });

  test('every Code pane source is an existing file under lib/recipes', () {
    for (final source in registeredSources()) {
      expect(source, startsWith('$recipesDir/'));
      expect(File(source).existsSync(), isTrue, reason: source);
    }
  });

  test('every recipe file is registered as a Code pane source', () {
    final registered = registeredSources().toSet();
    final unregistered = recipeFiles()
        .map((f) => f.path.replaceAll(r'\', '/'))
        .where((path) => !registered.contains(path))
        .toList();
    expect(unregistered, isEmpty);
  });

  testWidgets('every Code pane source loads from the asset bundle', (
    tester,
  ) async {
    for (final source in registeredSources()) {
      final text = await tester.runAsync(() => rootBundle.loadString(source));
      expect(text, File(source).readAsStringSync(), reason: source);
    }
  });

  group('disallowedImports', () {
    test('passes Flutter, flutter_folderview and dart: imports', () {
      const source = '''
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart' show Node;
''';
      expect(disallowedImports(source), isEmpty);
    });

    test('flags the shell, the example and relative imports', () {
      const source = '''
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:example/app/destinations.dart';
import '../app/every_setting.dart';
export 'package:window_manager/window_manager.dart';
''';
      expect(disallowedImports(source), [
        'package:flutter_example_template/flutter_example_template.dart',
        'package:example/app/destinations.dart',
        '../app/every_setting.dart',
        'package:window_manager/window_manager.dart',
      ]);
    });

    test('flags a wrapped show clause and a double-quoted import', () {
      const source = '''
import 'package:example/app/destinations.dart'
    show FolderViewDestinations;
import "package:flutter_example_template/flutter_example_template.dart";
import "package:flutter/material.dart";
''';
      expect(disallowedImports(source), [
        'package:example/app/destinations.dart',
        'package:flutter_example_template/flutter_example_template.dart',
      ]);
    });
  });
}
