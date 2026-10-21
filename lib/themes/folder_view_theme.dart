import 'package:flutter/widgets.dart';

import 'flutter_folder_view_theme.dart';

/// An InheritedWidget that provides a [FlutterFolderViewTheme] to its descendants
///
/// Use [FolderViewTheme.of(context)] to access the theme from anywhere
/// in the widget tree below this widget.
///
/// `T` must be the data type of the `FolderView<T>` below it. The lookup is by
/// exact type, so an untyped `FolderViewTheme(data: FlutterFolderViewTheme.dark())`
/// is a `FolderViewTheme<dynamic>`, which a `FolderView<String>` does not find:
/// it falls back to [FlutterFolderViewTheme.light]. In debug builds that miss
/// is reported once through [debugPrint].
///
/// Example:
/// ```dart
/// FolderViewTheme<MyDataType>(
///   data: FlutterFolderViewTheme<MyDataType>.dark(),
///   child: FolderView<MyDataType>(...),
/// )
/// ```
class FolderViewTheme<T> extends InheritedWidget {
  /// The theme data to provide to descendants
  final FlutterFolderViewTheme<T> data;

  /// Creates a [FolderViewTheme] that provides [data] to its descendants
  const FolderViewTheme({super.key, required this.data, required super.child});

  /// Retrieves the [FlutterFolderViewTheme] from the closest [FolderViewTheme] ancestor
  ///
  /// If there is no `FolderViewTheme<T>` ancestor, returns a default light
  /// theme. In debug builds, a `FolderViewTheme` of another type above
  /// [context] is reported once through [debugPrint].
  ///
  /// Example:
  /// ```dart
  /// final theme = FolderViewTheme.of<MyDataType>(context);
  /// final lineColor = theme.lineTheme.lineColor;
  /// ```
  static FlutterFolderViewTheme<T> of<T>(BuildContext context) {
    final FolderViewTheme<T>? theme = context
        .dependOnInheritedWidgetOfExactType<FolderViewTheme<T>>();
    if (theme == null) _debugReportTypeMismatch<T>(context);
    return theme?.data ?? FlutterFolderViewTheme<T>.light();
  }

  /// Retrieves the [FlutterFolderViewTheme] from the closest [FolderViewTheme] ancestor
  /// without registering a dependency
  ///
  /// This is useful when you just need to read the theme once without
  /// needing to rebuild when the theme changes.
  ///
  /// If there is no `FolderViewTheme<T>` ancestor, returns a default light
  /// theme, and reports a mismatched type in debug as [of] does.
  static FlutterFolderViewTheme<T> maybeOf<T>(BuildContext context) {
    final FolderViewTheme<T>? theme = context
        .getInheritedWidgetOfExactType<FolderViewTheme<T>>();
    if (theme == null) _debugReportTypeMismatch<T>(context);
    return theme?.data ?? FlutterFolderViewTheme<T>.light();
  }

  static final Set<Type> _debugReportedTypes = {};

  /// Forgets which mismatches were reported, so each is reported again.
  @visibleForTesting
  static void debugResetTypeMismatchWarnings() => _debugReportedTypes.clear();

  /// In debug, reports a `FolderViewTheme` of a type other than `T` above
  /// [context], once per `T`.
  static void _debugReportTypeMismatch<T>(BuildContext context) {
    assert(() {
      if (_debugReportedTypes.contains(T)) return true;
      FolderViewTheme<dynamic>? found;
      context.visitAncestorElements((element) {
        final widget = element.widget;
        if (widget is FolderViewTheme) {
          found = widget;
          return false;
        }
        return true;
      });
      if (found != null) {
        _debugReportedTypes.add(T);
        debugPrint(
          'FolderViewTheme.of<$T> found no FolderViewTheme<$T>, but a '
          '${found.runtimeType} is above it, so it fell back to '
          'FlutterFolderViewTheme<$T>.light(). The lookup is by exact type: '
          'write the type argument, FolderViewTheme<$T>(…) or '
          'FlutterFolderViewTheme<$T>.dark().',
        );
      }
      return true;
    }());
  }

  @override
  bool updateShouldNotify(FolderViewTheme oldWidget) {
    return data != oldWidget.data;
  }
}
