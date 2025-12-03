import 'package:flutter/widgets.dart';

/// Theme data for text styles in FolderView
@immutable
class FolderViewTextTheme {
  /// Default text style for all nodes
  final TextStyle? textStyle;

  /// Text style for selected nodes
  final TextStyle? selectedTextStyle;

  /// Text style for Folder type nodes
  final TextStyle? folderTextStyle;

  /// Text style for Parent type nodes
  final TextStyle? parentTextStyle;

  /// Text style for Child type nodes
  final TextStyle? childTextStyle;

  /// Creates a [FolderViewTextTheme]
  const FolderViewTextTheme({
    this.textStyle,
    this.selectedTextStyle,
    this.folderTextStyle,
    this.parentTextStyle,
    this.childTextStyle,
  });

  /// Creates a copy of this theme with the given fields replaced with new values
  FolderViewTextTheme copyWith({
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
    TextStyle? folderTextStyle,
    TextStyle? parentTextStyle,
    TextStyle? childTextStyle,
  }) {
    return FolderViewTextTheme(
      textStyle: textStyle ?? this.textStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      folderTextStyle: folderTextStyle ?? this.folderTextStyle,
      parentTextStyle: parentTextStyle ?? this.parentTextStyle,
      childTextStyle: childTextStyle ?? this.childTextStyle,
    );
  }

  /// Linearly interpolate between two [FolderViewTextTheme]s
  static FolderViewTextTheme lerp(
    FolderViewTextTheme? a,
    FolderViewTextTheme? b,
    double t,
  ) {
    if (a == null && b == null) {
      return const FolderViewTextTheme();
    }
    if (a == null) return b!;
    if (b == null) return a;

    return FolderViewTextTheme(
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      selectedTextStyle:
          TextStyle.lerp(a.selectedTextStyle, b.selectedTextStyle, t),
      folderTextStyle: TextStyle.lerp(a.folderTextStyle, b.folderTextStyle, t),
      parentTextStyle: TextStyle.lerp(a.parentTextStyle, b.parentTextStyle, t),
      childTextStyle: TextStyle.lerp(a.childTextStyle, b.childTextStyle, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FolderViewTextTheme &&
        other.textStyle == textStyle &&
        other.selectedTextStyle == selectedTextStyle &&
        other.folderTextStyle == folderTextStyle &&
        other.parentTextStyle == parentTextStyle &&
        other.childTextStyle == childTextStyle;
  }

  @override
  int get hashCode => Object.hash(
        textStyle,
        selectedTextStyle,
        folderTextStyle,
        parentTextStyle,
        childTextStyle,
      );

  @override
  String toString() {
    return 'FolderViewTextTheme('
        'textStyle: $textStyle, '
        'selectedTextStyle: $selectedTextStyle, '
        'folderTextStyle: $folderTextStyle, '
        'parentTextStyle: $parentTextStyle, '
        'childTextStyle: $childTextStyle'
        ')';
  }
}
