import 'package:flutter/widgets.dart';

import '../models/node.dart';
import 'node_tooltip_theme.dart';

/// Read-only view of the theme fields an *expandable* tier (Folder / Parent)
/// renderer needs.
///
/// `FolderNodeTheme` and `ParentNodeTheme` implement this so a single
/// `ExpandableNodeRenderer` can consume either without switching on tier. It is
/// intentionally **read-only** (getters only): it therefore does not run into
/// the `copyWith` / `lerp` / `scale` self-type limitation that keeps those
/// classes un-unified — see ADR-0005. Reading is shareable; writing is not.
abstract interface class ExpandableNodeThemeView<T> {
  Widget? get widget;
  Widget? Function(Node<T> node)? get widgetResolver;
  Widget? get openWidget;
  Widget? Function(Node<T> node)? get openWidgetResolver;
  double get width;
  double get height;
  EdgeInsets get padding;
  EdgeInsets get margin;
  String? Function(Node<T> node)? get labelResolver;
  Color? get hoverColor;
  Color? get splashColor;
  Color? get highlightColor;
  NodeTooltipTheme<T>? get tooltipTheme;
}
