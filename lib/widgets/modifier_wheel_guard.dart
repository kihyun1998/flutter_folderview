import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../input/scale_modifier.dart';

/// Claims a Scale Modifier + wheel signal over [child] before the enclosing
/// scroll view can, so that view does not scroll while [enabled].
///
/// Only the wheel is claimed: a drag still reaches the scroll view.
class ModifierWheelGuard extends StatelessWidget {
  const ModifierWheelGuard({
    super.key,
    required this.enabled,
    required this.child,
  });

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerSignal: (event) {
        if (event is PointerScrollEvent && isScaleModifierPressed()) {
          GestureBinding.instance.pointerSignalResolver.register(event, (_) {});
        }
      },
      child: child,
    );
  }
}
