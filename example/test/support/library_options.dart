import 'dart:io';

/// Every public option of `flutter_folderview`, as `Class.field`: the public
/// `final` instance fields of each public class in a library file the barrel
/// exports.
///
/// [barrelPath] is the package barrel; exports are resolved relative to it,
/// and `package:` exports are skipped. A `show` clause is not applied, so every
/// class in an exported file counts.
Set<String> libraryOptions(String barrelPath) {
  final barrel = File(barrelPath);
  final export = RegExp(r'''^export\s+'([^']+)'[^;]*;''', multiLine: true);
  return {
    for (final match in export.allMatches(barrel.readAsStringSync()))
      if (!match.group(1)!.startsWith('package:'))
        ...optionsInSource(
          File('${barrel.parent.path}/${match.group(1)}').readAsStringSync(),
        ),
  };
}

/// The public `final` instance fields of each public top-level class or enum
/// in [source], as `Class.field`. A declaration may span several lines and
/// may declare several names.
Set<String> optionsInSource(String source) {
  final options = <String>{};
  final typeStart = RegExp(
    r'^(?:(?:abstract|base|final|interface|mixin|sealed)\s+)*(?:class|enum)\s+(\w+)',
  );
  final lineComment = RegExp(r'\s*//.*$');
  String? currentType;
  final lines = source.split(RegExp(r'\r?\n'));
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final start = typeStart.firstMatch(line);
    if (start != null) {
      currentType = start.group(1);
      continue;
    }
    if (line.startsWith('}')) {
      currentType = null;
      continue;
    }
    if (currentType == null || currentType.startsWith('_')) continue;
    if (!line.startsWith('  final ')) continue;

    var declaration = line.replaceFirst(lineComment, '');
    while (!declaration.contains(';') && i + 1 < lines.length) {
      declaration += ' ${lines[++i].replaceFirst(lineComment, '').trim()}';
    }
    declaration = declaration.substring(0, declaration.indexOf(';'));
    if (declaration.contains('=')) continue;
    for (final name in _declaredNames(declaration)) {
      if (!name.startsWith('_')) options.add('$currentType.$name');
    }
  }
  return options;
}

/// The names in a `final Type a, b` declaration: the last identifier of each
/// comma-separated part, splitting only outside brackets.
Iterable<String> _declaredNames(String declaration) sync* {
  final lastIdentifier = RegExp(r'(\w+)\s*$');
  var depth = 0;
  var partStart = 0;
  for (var i = 0; i <= declaration.length; i++) {
    final char = i < declaration.length ? declaration[i] : ',';
    if ('<([{'.contains(char)) depth++;
    if ('>)]}'.contains(char)) depth--;
    if (char == ',' && depth == 0) {
      final name = lastIdentifier.firstMatch(
        declaration.substring(partStart, i),
      );
      if (name != null) yield name.group(1)!;
      partStart = i + 1;
    }
  }
}
