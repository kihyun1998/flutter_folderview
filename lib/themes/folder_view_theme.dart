import 'package:flutter/widgets.dart';

import 'flutter_folder_view_theme.dart';

/// An InheritedWidget that provides a [FlutterFolderViewTheme] to its descendants
///
/// Use [FolderViewTheme.of(context)] to access the theme from anywhere
/// in the widget tree below this widget.
///
/// Example:
/// ```dart
/// FolderViewTheme(
///   data: FlutterFolderViewTheme.light(),
///   child: FolderView(...),
/// )
/// ```
class FolderViewTheme extends InheritedWidget {
  /// The theme data to provide to descendants
  final FlutterFolderViewTheme data;

  /// Creates a [FolderViewTheme] that provides [data] to its descendants
  const FolderViewTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Retrieves the [FlutterFolderViewTheme] from the closest [FolderViewTheme] ancestor
  ///
  /// If there is no [FolderViewTheme] ancestor, returns a default light theme.
  ///
  /// Example:
  /// ```dart
  /// final theme = FolderViewTheme.of(context);
  /// final lineColor = theme.lineTheme.lineColor;
  /// ```
  static FlutterFolderViewTheme of(BuildContext context) {
    final FolderViewTheme? theme =
        context.dependOnInheritedWidgetOfExactType<FolderViewTheme>();
    return theme?.data ?? FlutterFolderViewTheme.light();
  }

  /// Retrieves the [FlutterFolderViewTheme] from the closest [FolderViewTheme] ancestor
  /// without registering a dependency
  ///
  /// This is useful when you just need to read the theme once without
  /// needing to rebuild when the theme changes.
  ///
  /// If there is no [FolderViewTheme] ancestor, returns a default light theme.
  static FlutterFolderViewTheme maybeOf(BuildContext context) {
    final FolderViewTheme? theme =
        context.getInheritedWidgetOfExactType<FolderViewTheme>();
    return theme?.data ?? FlutterFolderViewTheme.light();
  }

  @override
  bool updateShouldNotify(FolderViewTheme oldWidget) {
    return data != oldWidget.data;
  }
}
