# Tier-theme boilerplate is not extracted to a shared base

`FolderNodeTheme`, `ParentNodeTheme`, and `ChildNodeTheme` share most of their
surface: 13 common fields (`widget`, `widgetResolver`, `width`, `height`,
`padding`, `margin`, `textStyle`, `textStyleResolver`, `labelResolver`,
`hoverColor`, `splashColor`, `highlightColor`, `tooltipTheme`). `FolderNodeTheme`
and `ParentNodeTheme` are byte-for-byte identical (common fields + `openWidget`
/ `openWidgetResolver`); `ChildNodeTheme` adds `selectedTextStyle`,
`selectedTextStyleResolver`, `selectedBackgroundColor`, and `clickInterval`.

An architecture review proposed folding the common surface into a shared base to
stop the contract being maintained in triplicate.

## Decision

Keep the three concrete classes as they are. Do **not** introduce a shared base
class for tier themes.

## Why

The duplication that actually hurts lives in the `copyWith`, `lerp`, and `scale`
method bodies — each lists every field. In Dart these **cannot be inherited**:

- `copyWith` / `lerp` / `scale` return the concrete type, and Dart has no
  self-type, so a base cannot return the subtype.
- Their named parameters differ per tier (`selected*` vs `open*`), and an
  override cannot add or change named parameters.

A base class can therefore only share the **field declarations**. Adding a
common field would still require editing `copyWith` × 3, `lerp` × 3, and
`scale` × 3 — roughly 75% of the effort remains. Applying the deletion test to
such a base: removing it leaves the method-body complexity intact in all three
classes, so it does not concentrate complexity — a shallow abstraction.

## Alternatives considered

- **Inheritance base (field declarations only)** — non-breaking, but low ROI
  (removes ~25% of the edit surface) while adding a class hierarchy. Rejected as
  not worth the indirection.
- **Code generation (`freezed`)** — would generate `copyWith` / `lerp` / `==`
  and genuinely remove the duplication, but adds a `build_runner` dependency and
  changes the public shape of these classes (breaking). Out of scope for a
  cleanup; revisit only as part of a deliberate breaking release.

## Revisit when

- The project adopts `freezed` / code generation for other reasons, or
- A future Dart gains a self-type / augmentation mechanism that lets
  `copyWith`-style methods be inherited without losing the concrete return type.

Until then, treat the triplication as an accepted cost. A change to the shared
contract must be applied to all three classes by hand.
