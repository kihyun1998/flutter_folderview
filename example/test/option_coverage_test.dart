import 'package:example/app/settings_spec.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/library_options.dart';

/// Library options not yet exposed by the example, each with the issue that
/// owns exposing it. An entry leaves this map in the change that covers it.
const notYetCovered = <String, int>{
  'ChildNodeTheme.clickInterval': 84,
  'ChildNodeTheme.height': 84,
  'ChildNodeTheme.highlightColor': 84,
  'ChildNodeTheme.hoverColor': 84,
  'ChildNodeTheme.labelResolver': 84,
  'ChildNodeTheme.margin': 84,
  'ChildNodeTheme.padding': 84,
  'ChildNodeTheme.selectedBackgroundColor': 84,
  'ChildNodeTheme.selectedTextStyle': 84,
  'ChildNodeTheme.selectedTextStyleResolver': 84,
  'ChildNodeTheme.splashColor': 84,
  'ChildNodeTheme.textStyle': 84,
  'ChildNodeTheme.textStyleResolver': 84,
  'ChildNodeTheme.tooltipTheme': 86,
  'ChildNodeTheme.widget': 84,
  'ChildNodeTheme.widgetResolver': 84,
  'ChildNodeTheme.width': 84,
  'ExpandIconTheme.color': 81,
  'ExpandIconTheme.expandedColor': 81,
  'ExpandIconTheme.height': 81,
  'ExpandIconTheme.margin': 81,
  'ExpandIconTheme.padding': 81,
  'ExpandIconTheme.widget': 81,
  'ExpandIconTheme.width': 81,
  'FlutterFolderViewTheme.animationDuration': 79,
  'FlutterFolderViewTheme.childTheme': 84,
  'FlutterFolderViewTheme.expandIconTheme': 81,
  'FlutterFolderViewTheme.folderTheme': 82,
  'FlutterFolderViewTheme.lineTheme': 80,
  'FlutterFolderViewTheme.nodeStyleTheme': 79,
  'FlutterFolderViewTheme.parentTheme': 83,
  'FlutterFolderViewTheme.rowHeight': 79,
  'FlutterFolderViewTheme.rowSpacing': 79,
  'FlutterFolderViewTheme.scrollbarTheme': 85,
  'FlutterFolderViewTheme.spacingTheme': 79,
  'FolderNodeTheme.height': 82,
  'FolderNodeTheme.highlightColor': 82,
  'FolderNodeTheme.hoverColor': 82,
  'FolderNodeTheme.labelResolver': 82,
  'FolderNodeTheme.margin': 82,
  'FolderNodeTheme.openWidget': 82,
  'FolderNodeTheme.openWidgetResolver': 82,
  'FolderNodeTheme.padding': 82,
  'FolderNodeTheme.splashColor': 82,
  'FolderNodeTheme.textStyle': 82,
  'FolderNodeTheme.textStyleResolver': 82,
  'FolderNodeTheme.tooltipTheme': 86,
  'FolderNodeTheme.widget': 82,
  'FolderNodeTheme.widgetResolver': 82,
  'FolderNodeTheme.width': 82,
  'FolderView.blockModifierScroll': 78,
  'FolderView.data': 76,
  'FolderView.expandedNodeIds': 77,
  'FolderView.mode': 76,
  'FolderView.onDoubleNodeTap': 77,
  'FolderView.onNodeTap': 77,
  'FolderView.onScaleChanged': 78,
  'FolderView.onSecondaryNodeTap': 77,
  'FolderView.rowTooltipBuilder': 89,
  'FolderView.rowTooltipTheme': 89,
  'FolderView.scale': 78,
  'FolderView.scaleStep': 78,
  'FolderView.selectedNodeIds': 77,
  'FolderView.theme': 90,
  'FolderViewLineTheme.lineColor': 80,
  'FolderViewLineTheme.lineStyle': 80,
  'FolderViewLineTheme.lineWidth': 80,
  'FolderViewNodeStyleTheme.borderRadius': 79,
  'FolderViewScrollbarTheme.hoverAnimationDuration': 85,
  'FolderViewScrollbarTheme.hoverOpacity': 85,
  'FolderViewScrollbarTheme.nonHoverOpacity': 85,
  'FolderViewScrollbarTheme.radius': 85,
  'FolderViewScrollbarTheme.thickness': 85,
  'FolderViewScrollbarTheme.thumbColor': 85,
  'FolderViewScrollbarTheme.thumbVisibility': 85,
  'FolderViewScrollbarTheme.trackColor': 85,
  'FolderViewScrollbarTheme.trackRadius': 85,
  'FolderViewScrollbarTheme.trackVisibility': 85,
  'FolderViewScrollbarTheme.trackWidth': 85,
  'FolderViewSpacingTheme.contentPadding': 79,
  'FolderViewTheme.data': 90,
  'Node.children': 76,
  'Node.data': 76,
  'Node.id': 76,
  'Node.label': 76,
  'Node.type': 76,
  'NodeTooltipTheme.alignment': 86,
  'NodeTooltipTheme.anchor': 86,
  'NodeTooltipTheme.animation': 88,
  'NodeTooltipTheme.animationCurve': 88,
  'NodeTooltipTheme.animationDuration': 88,
  'NodeTooltipTheme.arrowBaseWidth': 86,
  'NodeTooltipTheme.arrowLength': 86,
  'NodeTooltipTheme.arrowPositionRatio': 86,
  'NodeTooltipTheme.backgroundColor': 87,
  'NodeTooltipTheme.borderColor': 87,
  'NodeTooltipTheme.borderRadius': 87,
  'NodeTooltipTheme.borderWidth': 87,
  'NodeTooltipTheme.boxShadow': 87,
  'NodeTooltipTheme.controller': 88,
  'NodeTooltipTheme.crossAxisOffset': 86,
  'NodeTooltipTheme.direction': 86,
  'NodeTooltipTheme.elevation': 87,
  'NodeTooltipTheme.enableHover': 88,
  'NodeTooltipTheme.enableTap': 88,
  'NodeTooltipTheme.fadeBegin': 88,
  'NodeTooltipTheme.hideOnEmptyMessage': 87,
  'NodeTooltipTheme.interactive': 88,
  'NodeTooltipTheme.message': 87,
  'NodeTooltipTheme.offset': 86,
  'NodeTooltipTheme.onHide': 88,
  'NodeTooltipTheme.onShow': 88,
  'NodeTooltipTheme.padding': 87,
  'NodeTooltipTheme.rotationBegin': 88,
  'NodeTooltipTheme.scaleBegin': 88,
  'NodeTooltipTheme.screenMargin': 86,
  'NodeTooltipTheme.showArrow': 86,
  'NodeTooltipTheme.showDuration': 88,
  'NodeTooltipTheme.slideOffset': 88,
  'NodeTooltipTheme.textStyle': 87,
  'NodeTooltipTheme.tooltipBuilder': 87,
  'NodeTooltipTheme.tooltipBuilderResolver': 87,
  'NodeTooltipTheme.useTooltip': 86,
  'NodeTooltipTheme.waitDuration': 88,
  'ParentNodeTheme.height': 83,
  'ParentNodeTheme.highlightColor': 83,
  'ParentNodeTheme.hoverColor': 83,
  'ParentNodeTheme.labelResolver': 83,
  'ParentNodeTheme.margin': 83,
  'ParentNodeTheme.openWidget': 83,
  'ParentNodeTheme.openWidgetResolver': 83,
  'ParentNodeTheme.padding': 83,
  'ParentNodeTheme.splashColor': 83,
  'ParentNodeTheme.textStyle': 83,
  'ParentNodeTheme.textStyleResolver': 83,
  'ParentNodeTheme.tooltipTheme': 86,
  'ParentNodeTheme.widget': 83,
  'ParentNodeTheme.widgetResolver': 83,
  'ParentNodeTheme.width': 83,
  'RowTooltipTheme.alignment': 89,
  'RowTooltipTheme.animation': 89,
  'RowTooltipTheme.animationCurve': 89,
  'RowTooltipTheme.animationDuration': 89,
  'RowTooltipTheme.crossAxisOffset': 89,
  'RowTooltipTheme.direction': 89,
  'RowTooltipTheme.enableHover': 89,
  'RowTooltipTheme.fadeBegin': 89,
  'RowTooltipTheme.interactive': 89,
  'RowTooltipTheme.offset': 89,
  'RowTooltipTheme.onHide': 89,
  'RowTooltipTheme.onShow': 89,
  'RowTooltipTheme.rotationBegin': 89,
  'RowTooltipTheme.scaleBegin': 89,
  'RowTooltipTheme.screenMargin': 89,
  'RowTooltipTheme.showDuration': 89,
  'RowTooltipTheme.slideOffset': 89,
  'RowTooltipTheme.surface': 89,
  'RowTooltipTheme.waitDuration': 89,
};

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
