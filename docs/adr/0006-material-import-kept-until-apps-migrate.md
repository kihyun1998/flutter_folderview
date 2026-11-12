# The legacy Material import is kept until apps migrate

Flutter 3.50 deprecates `package:flutter/material.dart` in favour of
`package:material_ui/material_ui.dart`. `flutter analyze` treats the resulting
`deprecated_member_use` infos as failures, so CI on `stable` went red on every
PR, each info this import (PR #197, run 43128194093). The package job reported
75: its `flutter analyze` also covers `example/`, so that is the package's 47
and the example's 28, which the example job reported again. This package keeps the legacy import for now.

**This is the maintainer's judgement** (#198, 2026-11-12), made on the
measurement below. It is not a derivation: a stronger technical argument does
not reopen it by itself. Moving to `material_ui` is deferred, not rejected.

## Decision

- Keep `import 'package:flutter/material.dart';` in `lib/`, `test/`,
  `benchmark/` and the example.
- Put `// ignore: deprecated_member_use` on the line above each such import, so
  `flutter analyze` passes on 3.50 while every other deprecation is still
  reported. The diagnostic is not turned off in `analysis_options.yaml`.
- The SDK floor does not move, and CI keeps running on `stable`.
- An app that has migrated to `material_ui` wraps `FolderView`, or a subtree
  containing it, in `MaterialUiCompatibilityBridge` (README, Theming).

## What it was decided on

Measured in a scratch project on Flutter 3.47.1 with `material_ui` 1.11.0,
2026-11-12. Under a `package:flutter/material.dart`
`MaterialApp(theme: ThemeData(brightness: dark, textTheme: bodyMedium 31))`:

| Lookup under that app | brightness | bodyMedium size |
|---|---|---|
| `material_ui`'s `Theme.of(context)` | light | 14 (default) |
| `flutter/material`'s `Theme.of(context)` | dark | 31 |

The two libraries' `Theme` and `ThemeData` are distinct types. `lib/` calls
`Theme.of(context)` for the base text style, the scrollbars and the tier
renderers' default colours. Moving `lib/` to `material_ui` would make
`FolderView` silently ignore the theme of every app that has not migrated.

`MaterialUiCompatibilityBridge` (`material_ui` 1.11.0,
`lib/src/migration_utility.dart`) maps a migrated app's theme **down** to the
legacy `Theme`: platform, visual density, colour scheme and text theme. It does
nothing in the other direction, and it is itself `@Deprecated` as a temporary
utility. Keeping the legacy import leaves an unmigrated app working with no
change, and costs a migrated app one wrapper.

Read, not measured: `material_ui` 1.11.0 requires Dart `^3.13.0` and Flutter
`>=3.47.0` (its `pubspec.yaml`), against this package's floor of 3.32. As read
for #198, Flutter has not stated when the legacy library will be removed
(https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui,
https://flutter.dev/blog/whats-new-in-flutter-3-50).

## Alternatives considered

- **Migrate `lib/` to `material_ui` now.** Not chosen: an unmigrated app
  would lose its theme in `FolderView` with no error, and the floor would rise
  from Flutter 3.32 to 3.47.
- **Pin CI to Flutter 3.47.** Not chosen: CI would stop building on the
  current stable, so a new deprecation or breakage there would go unseen.
- **Turn `deprecated_member_use` off in `analysis_options.yaml`.** Not chosen:
  it would also hide deprecations that have nothing to do with this import.

## What this does not cover

It decides the import line only. A future deprecation inside the legacy
library (a widget or field, not the library) is reported as before and decided
on its own.

## Revisit when

- Flutter schedules the removal of `package:flutter/material.dart`, or
- the maintainer's apps migrate to `material_ui`, or
- `MaterialUiCompatibilityBridge` is removed or gains the other direction.

Until then, a new file that imports `package:flutter/material.dart` carries the
same ignore line above the import.
