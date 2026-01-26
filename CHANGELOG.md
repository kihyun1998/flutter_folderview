## 0.2.1

### Features
- **Interaction Color Theming**: Added `hoverColor`, `splashColor`, and `highlightColor` properties to all node themes
  - `FolderNodeTheme`, `ParentNodeTheme`, and `ChildNodeTheme` now support customizable interaction colors
  - Colors fall back to Material theme defaults when not specified
  - Theme demo updated with interactive color pickers for all interaction colors
- **Tooltip Support**: Added comprehensive tooltip theming for all node types
  - New `NodeTooltipTheme` class with configurable position, style, and behavior
  - Added `tooltipTheme` property to `FolderNodeTheme`, `ParentNodeTheme`, and `ChildNodeTheme`
  - Support for both static messages and rich formatted content via `richMessage`
  - Dynamic tooltip content through `richMessageResolver` function based on node data
  - Customizable positioning (top/bottom), colors, margins, and wait duration
- **Configurable Row Height**: Added `rowHeight` property to `FlutterFolderViewTheme`
  - Centralized row height configuration (default: 40.0)
  - Replaces hardcoded height values in `NodeWidget` and `SizeService`
  - Consistent height calculation across all components

### Refactoring
- **Simplified Spacing Control**: Removed `iconToTextSpacing` property from all node themes
  - Icon-to-text spacing is now controlled via icon `margin.right` for better consistency
  - Reduced API surface and eliminated redundant spacing configuration

## 0.2.0

### BREAKING CHANGES
- **Theme System Refactor**: Migrated from unified `FolderViewTextTheme` and `FolderViewIconTheme` to node-type specific themes
  - Replaced `textTheme` and `iconTheme` with `folderTheme`, `parentTheme`, `childTheme`, and `expandIconTheme`
  - Old theme classes (`FolderViewTextTheme`, `FolderViewIconTheme`) have been removed
  - `FlutterFolderViewTheme` constructor now requires new theme parameters

### Features
- **Granular Widget Control**: Each node type now accepts custom `Widget?` instead of hardcoded `Icon` widgets
  - Added `widget` property for all node types
  - Added `openWidget` property for folder nodes (displayed when expanded)
  - Widgets are automatically wrapped in `SizedBox` with controllable `width` and `height`
- **Individual Spacing Control**:
  - Added `padding` and `margin` properties for each widget type (folder, parent, child, expand icon)
  - Added `iconToTextSpacing` property per node type for precise spacing control
- **Enhanced Child Node Theming**:
  - `selectedTextStyle` and `selectedBackgroundColor` are now exclusive to `ChildNodeTheme`
  - Clearer separation of selection styling from other node types
  - Added `clickInterval` property for configurable double-click detection (default: 300ms)
- **New Theme Classes**:
  - `FolderNodeTheme`: Complete control over folder appearance including open/closed states
  - `ParentNodeTheme`: Dedicated theme for parent nodes
  - `ChildNodeTheme`: Enhanced theme with selection-specific properties
  - `ExpandIconTheme`: Separate theme for expand/collapse icons
- **Interaction Customization**:
  - Added `animationDuration` property to `FlutterFolderViewTheme` for configurable expand/collapse animation speed (default: 200ms)
  - Click interval only applies to child nodes; folder/parent nodes use immediate single-click behavior
- **Theme Resolver Functions**: Dynamic styling based on node data
  - Added `widgetResolver` to all node themes for data-driven widget selection
  - Added `textStyleResolver` to all node themes for data-driven text styling
  - Added `selectedTextStyleResolver` to `ChildNodeTheme` for dynamic selected state styling
  - Added `openWidgetResolver` to `FolderNodeTheme` and `ParentNodeTheme` for expanded state customization
  - Resolver functions receive `Node<T>` and can access `node.data` for conditional styling
  - If resolver returns `null`, falls back to default theme properties
- **Generic Type Support**: All theme classes now support generic type parameter `<T>`
  - `FlutterFolderViewTheme<T>`, `FolderNodeTheme<T>`, `ParentNodeTheme<T>`, `ChildNodeTheme<T>`
  - Type-safe access to `node.data` in resolver functions
  - `FolderView<T>` and `FolderViewTheme<T>` support custom data types

### Examples
- Completely redesigned Theme Demo page with real-time controls for:
  - Icon size, color, padding, margin for all node types
  - Icon-to-text spacing adjustments
  - Font size and text color customization
  - Border radius and line style controls
  - Interaction controls: click interval (100-1000ms) and animation duration (50-800ms)
  - Double-click demonstration with visual feedback
  - Live preview of theme changes
- New Resolver Demo page demonstrating dynamic theme resolution:
  - Custom `FileData` class with `enabled` and `isImportant` properties
  - Icon changes based on node data (disabled = red block icon, important = yellow star icon)
  - Text style changes based on node data (disabled = grey strikethrough, important = bold blue)
  - Real-world example of conditional styling using resolver functions

### Migration Guide
Replace old theme usage:
```dart
// Before
FlutterFolderViewTheme(
  iconTheme: FolderViewIconTheme(...),
  textTheme: FolderViewTextTheme(...),
)

// After
FlutterFolderViewTheme(
  folderTheme: FolderNodeTheme(
    widget: Icon(Icons.folder),
    openWidget: Icon(Icons.folder_open),
    width: 20, height: 20,
    padding: EdgeInsets.zero,
    margin: EdgeInsets.zero,
    iconToTextSpacing: 8,
    textStyle: TextStyle(...),
  ),
  parentTheme: ParentNodeTheme(...),
  childTheme: ChildNodeTheme(
    widget: Icon(Icons.insert_drive_file),
    clickInterval: 300, // milliseconds for double-click detection
    ...
  ),
  expandIconTheme: ExpandIconTheme(...),
  animationDuration: 200, // milliseconds for expand/collapse animation
)
```

Using theme resolvers for dynamic styling:
```dart
// Define custom data type
class FileData {
  final bool enabled;
  final bool isImportant;
}

// Create theme with resolver functions
FlutterFolderViewTheme<FileData>(
  childTheme: ChildNodeTheme<FileData>(
    widget: Icon(Icons.insert_drive_file, color: Colors.grey),
    // Widget resolver: change icon based on node data
    widgetResolver: (node) {
      if (node.data?.enabled == false) {
        return Icon(Icons.block, color: Colors.red);
      }
      if (node.data?.isImportant == true) {
        return Icon(Icons.star, color: Colors.amber);
      }
      return null; // Use default widget
    },
    // Text style resolver: change style based on node data
    textStyleResolver: (node) {
      if (node.data?.enabled == false) {
        return TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough);
      }
      if (node.data?.isImportant == true) {
        return TextStyle(color: Colors.blue, fontWeight: FontWeight.bold);
      }
      return null; // Use default textStyle
    },
  ),
)

// Use with typed nodes
FolderView<FileData>(
  data: [
    Node<FileData>(
      id: '1',
      label: 'Important File',
      type: NodeType.child,
      data: FileData(enabled: true, isImportant: true),
    ),
  ],
)
```

## 0.1.2

### Bug Fixes
- Fixed scroll position being reset when expanding/collapsing nodes by removing contentHeight from SyncedScrollControllers key

## 0.1.1

### Bug Fixes
- Fixed scroll position calculation when switching between view modes or expanding/collapsing nodes by adding dynamic key based on mode and content height

### Examples
- Added large dataset demo page with 500 nodes (10 folders × 5 parents × 10 children) for performance testing

## 0.1.0

### Initial Release

#### Features
- **Dual View Modes**: Support for both Tree and Folder view modes
- **Node Types**: Three node types (Folder, Parent, Child) for flexible hierarchy representation
- **Line Styles**: Multiple line styles (Connector, Scope, None) for visual tree structure
- **Rich Theming**: Comprehensive theming system including:
  - Icon theme with customizable icons and colors
  - Text theme for different node types
  - Line theme for tree connectors
  - Scrollbar theme
  - Spacing theme
  - Node style theme with border customization
- **Interactive Features**:
  - Node selection support
  - Tap, double-tap, and secondary tap handlers
  - Expand/collapse animations
- **Smart Scrolling**: Synchronized horizontal and vertical scrolling with custom scrollbars
- **Depth-based Indentation**: Proper indentation for nested nodes at any depth level

#### Bug Fixes
- Correct indent and line positioning for nested nodes based on depth level
