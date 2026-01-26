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
///   data: FlutterFolderViewTheme<MyDataType>.light(),
///   child: FolderView(...),
/// )
/// ```
class FolderViewTheme<T> extends InheritedWidget {
  /// The theme data to provide to descendants
  final FlutterFolderViewTheme<T> data;

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
  /// final theme = FolderViewTheme.of<MyDataType>(context);
  /// final lineColor = theme.lineTheme.lineColor;
  /// ```
  static FlutterFolderViewTheme<T> of<T>(BuildContext context) {
    final FolderViewTheme<T>? theme =
        context.dependOnInheritedWidgetOfExactType<FolderViewTheme<T>>();
    return theme?.data ?? FlutterFolderViewTheme<T>.light();
  }

  /// Retrieves the [FlutterFolderViewTheme] from the closest [FolderViewTheme] ancestor
  /// without registering a dependency
  ///
  /// This is useful when you just need to read the theme once without
  /// needing to rebuild when the theme changes.
  ///
  /// If there is no [FolderViewTheme] ancestor, returns a default light theme.
  static FlutterFolderViewTheme<T> maybeOf<T>(BuildContext context) {
    final FolderViewTheme<T>? theme =
        context.getInheritedWidgetOfExactType<FolderViewTheme<T>>();
    return theme?.data ?? FlutterFolderViewTheme<T>.light();
  }

  @override
  bool updateShouldNotify(FolderViewTheme oldWidget) {
    return data != oldWidget.data;
  }
}
