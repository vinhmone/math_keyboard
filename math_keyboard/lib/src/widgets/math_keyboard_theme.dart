import 'package:flutter/material.dart';

/// The set of colors used to paint the math keyboard's surfaces.
///
/// Two named palettes are provided out of the box via [MathKeyboardColors.dark]
/// and [MathKeyboardColors.light]. Use [MathKeyboardColors.resolve] to obtain a
/// concrete palette from a [ThemeMode].
@immutable
class MathKeyboardColors {
  /// Constructs a [MathKeyboardColors] from the individual surface colors.
  const MathKeyboardColors({
    required this.background,
    required this.accent,
    required this.foreground,
    required this.separator,
    required this.tapOverlay,
  });

  /// Background color of the whole keyboard.
  final Color background;

  /// Color used for the variable bar background, navigation buttons, and
  /// highlighted buttons (e.g. the page toggle).
  final Color accent;

  /// Color for text, icons, and TeX rendered on the keyboard.
  final Color foreground;

  /// Color of the divider between variables in the variable bar.
  final Color separator;

  /// Color of the press/hover ripple overlay on buttons.
  ///
  /// This is composited with a fractional opacity, so on a dark keyboard white
  /// brightens buttons while on a light keyboard black darkens them.
  final Color tapOverlay;

  /// The dark palette, i.e. the keyboard's original black look.
  factory MathKeyboardColors.dark() => const MathKeyboardColors(
        background: Colors.black,
        accent: Color(0xFF212121), // grey[900]
        foreground: Colors.white,
        separator: Colors.white,
        tapOverlay: Colors.white,
      );

  /// The light palette, i.e. a white keyboard with dark text/icons.
  factory MathKeyboardColors.light() => MathKeyboardColors(
        background: Colors.white,
        accent: Colors.grey[300]!,
        foreground: Colors.grey[900]!,
        separator: Colors.grey[400]!,
        tapOverlay: Colors.black,
      );

  /// Resolves a [ThemeMode] to a concrete palette.
  ///
  /// [ThemeMode.system] resolves using the ambient platform brightness.
  static MathKeyboardColors resolve(BuildContext context, ThemeMode mode) {
    final brightness = switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
    return brightness == Brightness.dark
        ? MathKeyboardColors.dark()
        : MathKeyboardColors.light();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MathKeyboardColors &&
          runtimeType == other.runtimeType &&
          background == other.background &&
          accent == other.accent &&
          foreground == other.foreground &&
          separator == other.separator &&
          tapOverlay == other.tapOverlay;

  @override
  int get hashCode =>
      Object.hash(background, accent, foreground, separator, tapOverlay);
}

/// Inherited widget that exposes the current [MathKeyboardColors] to the
/// keyboard's descendants.
///
/// This lets widgets like the buttons read the palette without threading it
/// through every constructor.
class MathKeyboardColorsProvider extends InheritedWidget {
  /// Constructs a [MathKeyboardColorsProvider].
  const MathKeyboardColorsProvider({
    super.key,
    required this.colors,
    required super.child,
  });

  /// The palette exposed to descendants.
  final MathKeyboardColors colors;

  /// Returns the palette from the closest [MathKeyboardColorsProvider] ancestor.
  ///
  /// Falls back to the dark palette so that a bare button used outside of a
  /// [MathKeyboardColorsProvider] keeps its original look.
  static MathKeyboardColors of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<MathKeyboardColorsProvider>()
          ?.colors ??
      MathKeyboardColors.dark();

  @override
  bool updateShouldNotify(MathKeyboardColorsProvider oldWidget) =>
      colors != oldWidget.colors;
}
