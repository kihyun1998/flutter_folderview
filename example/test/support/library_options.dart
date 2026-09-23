import 'dart:io';

/// Every public option of `flutter_folderview`, as `Class.field`: the public
/// `final` instance fields of each public class in a library file the barrel
/// exports.
///
/// [barrelPath] is the package barrel; exports are resolved relative to it.
/// `package:` exports and names hidden by a `show` clause are skipped.
Set<String> libraryOptions(String barrelPath) {
  final barrel = File(barrelPath);
  final options = <String>{};
  final export = RegExp(
    r'''^export\s+'([^']+)'(?:\s+show\s+([^;]+))?;''',
    multiLine: true,
  );
  for (final match in export.allMatches(barrel.readAsStringSync())) {
    final uri = match.group(1)!;
    if (uri.startsWith('package:')) continue;
    final shown = match.group(2)?.split(',').map((s) => s.trim()).toSet();
    final file = File('${barrel.parent.path}/$uri');
    for (final option in optionsInSource(file.readAsStringSync())) {
      final className = option.split('.').first;
      if (shown == null || shown.contains(className)) options.add(option);
    }
  }
  return options;
}

/// The public `final` instance fields of each public top-level class in
/// [source], as `Class.field`. A declaration may span several lines.
Set<String> optionsInSource(String source) {
  final options = <String>{};
  final classStart = RegExp(
    r'^(?:abstract\s+|final\s+|base\s+|sealed\s+)*class\s+(\w+)',
  );
  final fieldName = RegExp(r'(\w+)\s*;\s*$');
  String? currentClass;
  final lines = source.split(RegExp(r'\r?\n'));
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final start = classStart.firstMatch(line);
    if (start != null) {
      currentClass = start.group(1);
      continue;
    }
    if (line.startsWith('}')) {
      currentClass = null;
      continue;
    }
    if (currentClass == null || currentClass.startsWith('_')) continue;
    if (!line.startsWith('  final ')) continue;

    var declaration = line;
    while (!declaration.contains(';') && i + 1 < lines.length) {
      declaration += ' ${lines[++i].trim()}';
    }
    if (declaration.contains('=')) continue;
    final name = fieldName.firstMatch(declaration)?.group(1);
    if (name != null && !name.startsWith('_')) {
      options.add('$currentClass.$name');
    }
  }
  return options;
}
