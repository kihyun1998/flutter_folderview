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
