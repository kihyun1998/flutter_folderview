import 'package:flutter/widgets.dart';

/// Theme data for icon styles in FolderView
@immutable
class FolderViewIconTheme {
  /// Size of all icons in the folder view
  final double iconSize;

  /// Default color for all icons
  final Color? iconColor;

  /// Color for icons when the node is selected
  final Color? selectedIconColor;

  /// Icon for folders in collapsed state
  final IconData? folderIcon;

  /// Icon for folders in expanded state
  final IconData? folderOpenIcon;

  /// Icon for parent nodes
  final IconData? parentIcon;

  /// Icon for parent nodes in expanded state (optional, defaults to parentIcon)
  final IconData? parentOpenIcon;

  /// Icon for child nodes (leaf nodes)
  final IconData? childIcon;

  /// Icon for expand/collapse control (will be rotated for animation)
  final IconData? expandIcon;

  /// Creates a [FolderViewIconTheme]
  const FolderViewIconTheme({
    this.iconSize = 20.0,
    this.iconColor,
    this.selectedIconColor,
    this.folderIcon,
    this.folderOpenIcon,
    this.parentIcon,
    this.parentOpenIcon,
    this.childIcon,
    this.expandIcon,
  });

  /// Creates a copy of this theme with the given fields replaced with new values
  FolderViewIconTheme copyWith({
    double? iconSize,
    Color? iconColor,
    Color? selectedIconColor,
    IconData? folderIcon,
    IconData? folderOpenIcon,
    IconData? parentIcon,
    IconData? parentOpenIcon,
    IconData? childIcon,
    IconData? expandIcon,
  }) {
    return FolderViewIconTheme(
      iconSize: iconSize ?? this.iconSize,
      iconColor: iconColor ?? this.iconColor,
      selectedIconColor: selectedIconColor ?? this.selectedIconColor,
      folderIcon: folderIcon ?? this.folderIcon,
      folderOpenIcon: folderOpenIcon ?? this.folderOpenIcon,
      parentIcon: parentIcon ?? this.parentIcon,
      parentOpenIcon: parentOpenIcon ?? this.parentOpenIcon,
      childIcon: childIcon ?? this.childIcon,
      expandIcon: expandIcon ?? this.expandIcon,
    );
  }

  /// Linearly interpolate between two [FolderViewIconTheme]s
  static FolderViewIconTheme lerp(
    FolderViewIconTheme? a,
    FolderViewIconTheme? b,
    double t,
  ) {
    if (a == null && b == null) {
      return const FolderViewIconTheme();
    }
    if (a == null) return b!;
    if (b == null) return a;

    return FolderViewIconTheme(
      iconSize: (a.iconSize + (b.iconSize - a.iconSize) * t),
      iconColor: Color.lerp(a.iconColor, b.iconColor, t),
      selectedIconColor:
          Color.lerp(a.selectedIconColor, b.selectedIconColor, t),
      folderIcon: t < 0.5 ? a.folderIcon : b.folderIcon,
      folderOpenIcon: t < 0.5 ? a.folderOpenIcon : b.folderOpenIcon,
      parentIcon: t < 0.5 ? a.parentIcon : b.parentIcon,
      parentOpenIcon: t < 0.5 ? a.parentOpenIcon : b.parentOpenIcon,
      childIcon: t < 0.5 ? a.childIcon : b.childIcon,
      expandIcon: t < 0.5 ? a.expandIcon : b.expandIcon,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FolderViewIconTheme &&
        other.iconSize == iconSize &&
        other.iconColor == iconColor &&
        other.selectedIconColor == selectedIconColor &&
        other.folderIcon == folderIcon &&
        other.folderOpenIcon == folderOpenIcon &&
        other.parentIcon == parentIcon &&
        other.parentOpenIcon == parentOpenIcon &&
        other.childIcon == childIcon &&
        other.expandIcon == expandIcon;
  }

  @override
  int get hashCode => Object.hash(
        iconSize,
        iconColor,
        selectedIconColor,
        folderIcon,
        folderOpenIcon,
        parentIcon,
        parentOpenIcon,
        childIcon,
        expandIcon,
      );

  @override
  String toString() {
    return 'FolderViewIconTheme('
        'iconSize: $iconSize, '
        'iconColor: $iconColor, '
        'selectedIconColor: $selectedIconColor, '
        'folderIcon: $folderIcon, '
        'folderOpenIcon: $folderOpenIcon, '
        'parentIcon: $parentIcon, '
        'parentOpenIcon: $parentOpenIcon, '
        'childIcon: $childIcon, '
        'expandIcon: $expandIcon'
        ')';
  }
}
