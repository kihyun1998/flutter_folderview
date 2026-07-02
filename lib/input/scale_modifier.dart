import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Whether the platform-appropriate modifier key (Ctrl on Windows/Linux,
/// Cmd on macOS) is currently pressed.
///
/// On Windows/Linux only [HardwareKeyboard.isControlPressed] is checked — this
/// avoids the "sticky Windows-key" bug where pressing the Windows key sets
/// [HardwareKeyboard.isMetaPressed] to `true` but the subsequent key-up is
/// never delivered to the Flutter app, leaving the flag stuck.
bool isScaleModifierPressed() {
  if (defaultTargetPlatform == TargetPlatform.macOS) {
    return HardwareKeyboard.instance.isMetaPressed;
  }
  return HardwareKeyboard.instance.isControlPressed;
}
