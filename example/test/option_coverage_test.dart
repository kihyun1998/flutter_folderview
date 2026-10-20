import 'package:example/app/settings_spec.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/library_options.dart';

/// Library options not yet exposed by the example, each with the issue that
/// owns exposing it. An entry leaves this map in the change that covers it.
const notYetCovered = <String, int>{'NodeTooltipTheme.controller': 133};

/// Every `Class.field` id the example claims to cover.
Set<String> coveredOptions() => {
  for (final group in settingsSpec)
    for (final feature in group.features) ...[
      ...feature.options,
      if (feature.switchId != null) feature.switchId!,
    ],
  ...recipeCoverage,
}.where(_isLibraryId).toSet();

bool _isLibraryId(String id) => RegExp(r'^[A-Z]\w*\.\w+$').hasMatch(id);

void main() {
  final library = libraryOptions('../lib/flutter_folderview.dart');
  final covered = coveredOptions();

  test('every library option is covered or listed as not yet covered', () {
    final unaccounted =
        library
            .where((o) => !covered.contains(o) && !notYetCovered.containsKey(o))
            .toList()
          ..sort();
    expect(unaccounted, isEmpty);
  });

  test('every not-yet-covered entry names a library option', () {
    final stale = notYetCovered.keys.where((o) => !library.contains(o)).toList()
      ..sort();
    expect(stale, isEmpty);
  });

  test('no not-yet-covered entry is already covered', () {
    final done = notYetCovered.keys.where((o) => covered.contains(o)).toList()
      ..sort();
    expect(done, isEmpty);
  });

  test('every Class.field id the example uses names a library option', () {
    final unknown = covered.where((o) => !library.contains(o)).toList()..sort();
    expect(unknown, isEmpty);
  });

  group('optionsInSource', () {
    test('reads public final fields of public classes, across lines', () {
      const source = '''
class Theme {
  final double width;
  final Widget? Function(
    Node<T> node,
  )? resolver;
  final int _private;
  final int initialised = 0;
  static const int constant = 1;

  void build() {
    final local = 1;
  }
}

class _Hidden {
  final int hidden;
}

abstract class Base {
  final String id;
}
''';
      expect(optionsInSource(source), {
        'Theme.width',
        'Theme.resolver',
        'Base.id',
      });
    });

    test('reads every class modifier, enums, comments and name lists', () {
      const source = '''
interface class A {
  final int a;
}

abstract interface class B {
  final int b;
}

mixin class C {
  final int c;
}

enum D {
  one(1);

  const D(this.d);
  final int d;
}

class E {
  final int e; // default = 0
  final int f, g;
  final int h = 1, i = 2;
  final Widget? Function( // resolver = per node
    Node node,
  )? j;
}
''';
      expect(optionsInSource(source), {
        'A.a',
        'B.b',
        'C.c',
        'D.d',
        'E.e',
        'E.f',
        'E.g',
        'E.j',
      });
    });
  });
}
