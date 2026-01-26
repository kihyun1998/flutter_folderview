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
- **New Theme Classes**:
  - `FolderNodeTheme`: Complete control over folder appearance including open/closed states
  - `ParentNodeTheme`: Dedicated theme for parent nodes
  - `ChildNodeTheme`: Enhanced theme with selection-specific properties
  - `ExpandIconTheme`: Separate theme for expand/collapse icons

### Examples
- Completely redesigned Theme Demo page with real-time controls for:
  - Icon size, color, padding, margin for all node types
  - Icon-to-text spacing adjustments
  - Font size and text color customization
  - Border radius and line style controls
  - Live preview of theme changes

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
  childTheme: ChildNodeTheme(...),
  expandIconTheme: ExpandIconTheme(...),
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
