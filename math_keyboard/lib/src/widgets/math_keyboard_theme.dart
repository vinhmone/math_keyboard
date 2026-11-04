import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:math_keyboard/src/foundation/math_keyboard_semantics.dart';
import 'package:math_keyboard/src/foundation/decimal_separator.dart';

/// The color tiers a [MathKeyboard] key can adopt.
///
/// Each tier groups keys that share a visual role so that a [MathKeyboardStyle]
/// can color them consistently regardless of the concrete key.
enum MathKeyboardKeyTier {
  /// Operators, the decimal separator, parentheses, cursor navigation, and
  /// variable keys.
  neutral,

  /// Digits and typeset function keys such as fractions, roots, and
  /// trigonometric functions.
  function,

  /// Utility keys that change the keyboard mode or delete input, such as the
  /// page toggle and the backspace key.
  utility,

  /// The submit key.
  primary,
}

/// The idle, hover, and pressed background colors of a single key tier.
@immutable
class MathKeyboardKeyStyle {
  /// Constructs a [MathKeyboardKeyStyle].
  const MathKeyboardKeyStyle({
    required this.color,
    required this.hoverColor,
    required this.pressedColor,
  });

  /// The background color in the idle state.
  final Color color;

  /// The background color while the pointer hovers the key.
  final Color hoverColor;

  /// The background color while the key is pressed.
  final Color pressedColor;

  /// Resolves the background color for the given interaction states.
  Color resolve({required bool hovered, required bool pressed}) {
    if (pressed) return pressedColor;
    if (hovered) return hoverColor;
    return color;
  }

  /// Creates a copy of this style with the given fields replaced.
  MathKeyboardKeyStyle copyWith({
    Color? color,
    Color? hoverColor,
    Color? pressedColor,
  }) {
    return MathKeyboardKeyStyle(
      color: color ?? this.color,
      hoverColor: hoverColor ?? this.hoverColor,
      pressedColor: pressedColor ?? this.pressedColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MathKeyboardKeyStyle &&
        other.color == color &&
        other.hoverColor == hoverColor &&
        other.pressedColor == pressedColor;
  }

  @override
  int get hashCode => Object.hash(color, hoverColor, pressedColor);
}

/// Describes the visual appearance of a [MathKeyboard].
///
/// The [fallback] is the built-in default theme, used whenever no
/// [MathKeyboardTheme] is present. Wrap a [MathKeyboard] (or a subtree
/// containing [MathField]s) in a [MathKeyboardTheme] to customize the
/// appearance, for example to inject a design system's tokens.
@immutable
class MathKeyboardStyle {
  /// Constructs a [MathKeyboardStyle].
  const MathKeyboardStyle({
    required this.backgroundColor,
    required this.borderRadius,
    required this.boxShadow,
    required this.padding,
    required this.horizontalPadding,
    required this.rowSpacing,
    required this.keyBorderRadius,
    required this.keyPadding,
    required this.keyHeight,
    required this.baseFontSize,
    required this.maxTextScaleFactor,
    required this.foregroundColor,
    required this.focusBorderColor,
    required this.focusBorderWidth,
    required this.neutralKey,
    required this.functionKey,
    required this.utilityKey,
    required this.primaryKey,
    this.fontFamily,
    this.largeContentViewerEnabled = true,
    this.largeContentViewerThreshold = 1.6,
    this.largeContentLabelScale = 2.5,
  }) : assert(
         maxTextScaleFactor >= 1,
         'maxTextScaleFactor must be >= 1; the ambient text scale is clamped to '
         'this upper bound and clamp() throws when the bound is below 1.',
       );

  /// The background color of the keyboard surface.
  final Color backgroundColor;

  /// The corner radius of the keyboard surface.
  final BorderRadius borderRadius;

  /// The shadow cast by the keyboard surface.
  final List<BoxShadow> boxShadow;

  /// The vertical padding above and below the rows of keys.
  final EdgeInsets padding;

  /// The horizontal inset applied to each row.
  ///
  /// The variables row uses this only on its leading edge so that keys can
  /// bleed off the trailing edge as a scroll affordance.
  final double horizontalPadding;

  /// The vertical gap between rows and the horizontal gap between keys.
  final double rowSpacing;

  /// The corner radius of an individual key.
  final BorderRadius keyBorderRadius;

  /// The padding inside an individual key, around its label.
  final EdgeInsets keyPadding;

  /// The height of a key at the default (1.0) text scale.
  ///
  /// Keys grow with the ambient text scale up to `keyHeight *
  /// [maxTextScaleFactor]` so that labels genuinely enlarge for large-text
  /// users. Set [maxTextScaleFactor] to 1 to keep a strictly fixed height.
  final double keyHeight;

  /// The unscaled font size of key labels.
  ///
  /// The effective size is this value multiplied by the text scale factor,
  /// clamped to [maxTextScaleFactor].
  final double baseFontSize;

  /// The upper bound applied to the ambient text scale factor.
  ///
  /// Defaults to `1`: keys keep a fixed size and large-text accessibility is
  /// provided by the large-content-viewer (long-press a key to magnify it).
  /// Set a higher value (for example `2` for the WCAG 1.4.4 200% target) to
  /// instead grow the keys and labels with the system text size, capped here.
  final double maxTextScaleFactor;

  /// The color of key labels and icons.
  final Color foregroundColor;

  /// The color of the focus ring drawn around a focused key.
  final Color focusBorderColor;

  /// The width of the focus ring drawn around a focused key.
  final double focusBorderWidth;

  /// The optional font family applied to plain-text key labels.
  ///
  /// Typeset (TeX) labels always use the math font. A `null` value keeps the
  /// ambient default.
  final String? fontFamily;

  /// The colors for [MathKeyboardKeyTier.neutral] keys.
  final MathKeyboardKeyStyle neutralKey;

  /// The colors for [MathKeyboardKeyTier.function] keys.
  final MathKeyboardKeyStyle functionKey;

  /// The colors for [MathKeyboardKeyTier.utility] keys.
  final MathKeyboardKeyStyle utilityKey;

  /// The colors for [MathKeyboardKeyTier.primary] keys.
  final MathKeyboardKeyStyle primaryKey;

  /// Whether keys offer a large-content-viewer (long-press to magnify) for
  /// large-text accessibility.
  ///
  /// Defaults to `true`. Set to `false` to remove the long-press magnifier
  /// entirely (for example if a product prefers to grow the keys instead via
  /// [maxTextScaleFactor]).
  final bool largeContentViewerEnabled;

  /// The ambient text scale at or above which the large-content-viewer
  /// magnifier activates on long-press.
  ///
  /// Defaults to `1.6` (160%). Set to `1.0` to make the magnifier available at
  /// every text size. Ignored when [largeContentViewerEnabled] is `false`.
  final double largeContentViewerThreshold;

  /// How much larger the magnified label is rendered in the large-content
  /// popup, relative to the on-key label. Defaults to `2.5`.
  final double largeContentLabelScale;

  /// The upstream built-in dark style.
  ///
  /// [MathKeyboardTheme.styleOf] returns it when no theme supplies a style. A
  /// [MathKeyboard] or [MathField] without an explicit style or a
  /// [MathKeyboardTheme] style does not use it: it resolves its look from its
  /// `themeMode` instead (see [MathKeyboardStyle.resolve]).
  static const MathKeyboardStyle fallback = MathKeyboardStyle(
    backgroundColor: Color(0xFF1E2931),
    borderRadius: BorderRadius.all(Radius.circular(24)),
    boxShadow: [
      BoxShadow(
        color: Color(0x40000000),
        offset: Offset(0, 11),
        blurRadius: 7.5,
      ),
    ],
    padding: EdgeInsets.symmetric(vertical: 16),
    horizontalPadding: 16,
    rowSpacing: 4,
    keyBorderRadius: BorderRadius.all(Radius.circular(12)),
    keyPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    keyHeight: 48,
    baseFontSize: 22,
    // Keys stay fixed by default; large-text accessibility is handled by the
    // large-content-viewer (long-press to magnify). Raise this to grow keys.
    maxTextScaleFactor: 1,
    foregroundColor: Color(0xFFFFFFFF),
    focusBorderColor: Color(0xFF8ABAFE),
    focusBorderWidth: 2,
    // Operator, parenthesis, navigation, and variable keys: darker at rest,
    // lighter on hover/press.
    neutralKey: MathKeyboardKeyStyle(
      color: Color(0xFF2A353C),
      hoverColor: Color(0xFF414B51),
      pressedColor: Color(0xFF414B51),
    ),
    // Digit and typeset-function keys: lighter at rest, darker on hover/press.
    functionKey: MathKeyboardKeyStyle(
      color: Color(0xFF414B51),
      hoverColor: Color(0xFF2A353C),
      pressedColor: Color(0xFF2A353C),
    ),
    // Delete and page-toggle keys: the lightest surface at rest.
    utilityKey: MathKeyboardKeyStyle(
      color: Color(0xFF798085),
      hoverColor: Color(0xFF414B51),
      pressedColor: Color(0xFF414B51),
    ),
    // Submit key: the accent color.
    primaryKey: MathKeyboardKeyStyle(
      color: Color(0xFF0164EC),
      hoverColor: Color(0xFF004BB3),
      pressedColor: Color(0xFF004BB3),
    ),
  );

  /// Builds a style from a light or dark [MathKeyboardColors] palette.
  ///
  /// The geometry (radii, padding, key height, shadow, font size) is the
  /// [fallback]'s; only the colours come from [colors]. Digit and function
  /// keys sit on the keyboard background, operator, navigation and variable
  /// keys plus the delete and page-toggle keys use the accent, and the submit
  /// key uses [primary]. Hover and press blend [MathKeyboardColors.tapOverlay]
  /// over the key at a third of its opacity, as the press ripple did before.
  static MathKeyboardStyle fromColors(
    MathKeyboardColors colors, {
    required Color primary,
  }) {
    MathKeyboardKeyStyle key(Color color) {
      final active = Color.alphaBlend(
        colors.tapOverlay.withValues(alpha: 1 / 3),
        color,
      );
      return MathKeyboardKeyStyle(
        color: color,
        hoverColor: active,
        pressedColor: active,
      );
    }

    return fallback.copyWith(
      backgroundColor: colors.background,
      foregroundColor: colors.foreground,
      focusBorderColor: colors.focus,
      neutralKey: key(colors.accent),
      functionKey: key(colors.background),
      utilityKey: key(colors.accent),
      primaryKey: key(primary),
    );
  }

  /// Resolves the light or dark style for [mode].
  ///
  /// [ThemeMode.system] follows the platform brightness. The submit key takes
  /// the ambient [ColorScheme.secondary].
  static MathKeyboardStyle resolve(BuildContext context, ThemeMode mode) {
    return fromColors(
      MathKeyboardColors.resolve(context, mode),
      primary: Theme.of(context).colorScheme.secondary,
    );
  }

  /// Returns the key style for the given [tier].
  MathKeyboardKeyStyle keyStyle(MathKeyboardKeyTier tier) {
    return switch (tier) {
      MathKeyboardKeyTier.neutral => neutralKey,
      MathKeyboardKeyTier.function => functionKey,
      MathKeyboardKeyTier.utility => utilityKey,
      MathKeyboardKeyTier.primary => primaryKey,
    };
  }

  /// Creates a copy of this style with the given fields replaced.
  MathKeyboardStyle copyWith({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    EdgeInsets? padding,
    double? horizontalPadding,
    double? rowSpacing,
    BorderRadius? keyBorderRadius,
    EdgeInsets? keyPadding,
    double? keyHeight,
    double? baseFontSize,
    double? maxTextScaleFactor,
    Color? foregroundColor,
    Color? focusBorderColor,
    double? focusBorderWidth,
    String? fontFamily,
    MathKeyboardKeyStyle? neutralKey,
    MathKeyboardKeyStyle? functionKey,
    MathKeyboardKeyStyle? utilityKey,
    MathKeyboardKeyStyle? primaryKey,
    bool? largeContentViewerEnabled,
    double? largeContentViewerThreshold,
    double? largeContentLabelScale,
  }) {
    return MathKeyboardStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      padding: padding ?? this.padding,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      rowSpacing: rowSpacing ?? this.rowSpacing,
      keyBorderRadius: keyBorderRadius ?? this.keyBorderRadius,
      keyPadding: keyPadding ?? this.keyPadding,
      keyHeight: keyHeight ?? this.keyHeight,
      baseFontSize: baseFontSize ?? this.baseFontSize,
      maxTextScaleFactor: maxTextScaleFactor ?? this.maxTextScaleFactor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
      focusBorderWidth: focusBorderWidth ?? this.focusBorderWidth,
      fontFamily: fontFamily ?? this.fontFamily,
      neutralKey: neutralKey ?? this.neutralKey,
      functionKey: functionKey ?? this.functionKey,
      utilityKey: utilityKey ?? this.utilityKey,
      primaryKey: primaryKey ?? this.primaryKey,
      largeContentViewerEnabled:
          largeContentViewerEnabled ?? this.largeContentViewerEnabled,
      largeContentViewerThreshold:
          largeContentViewerThreshold ?? this.largeContentViewerThreshold,
      largeContentLabelScale:
          largeContentLabelScale ?? this.largeContentLabelScale,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MathKeyboardStyle &&
        other.backgroundColor == backgroundColor &&
        other.borderRadius == borderRadius &&
        listEquals(other.boxShadow, boxShadow) &&
        other.padding == padding &&
        other.horizontalPadding == horizontalPadding &&
        other.rowSpacing == rowSpacing &&
        other.keyBorderRadius == keyBorderRadius &&
        other.keyPadding == keyPadding &&
        other.keyHeight == keyHeight &&
        other.baseFontSize == baseFontSize &&
        other.maxTextScaleFactor == maxTextScaleFactor &&
        other.foregroundColor == foregroundColor &&
        other.focusBorderColor == focusBorderColor &&
        other.focusBorderWidth == focusBorderWidth &&
        other.fontFamily == fontFamily &&
        other.neutralKey == neutralKey &&
        other.functionKey == functionKey &&
        other.utilityKey == utilityKey &&
        other.primaryKey == primaryKey &&
        other.largeContentViewerEnabled == largeContentViewerEnabled &&
        other.largeContentViewerThreshold == largeContentViewerThreshold &&
        other.largeContentLabelScale == largeContentLabelScale;
  }

  @override
  int get hashCode => Object.hashAll([
    backgroundColor,
    borderRadius,
    Object.hashAll(boxShadow),
    padding,
    horizontalPadding,
    rowSpacing,
    keyBorderRadius,
    keyPadding,
    keyHeight,
    baseFontSize,
    maxTextScaleFactor,
    foregroundColor,
    focusBorderColor,
    focusBorderWidth,
    fontFamily,
    neutralKey,
    functionKey,
    utilityKey,
    primaryKey,
    largeContentViewerEnabled,
    largeContentViewerThreshold,
    largeContentLabelScale,
  ]);
}

/// Provides a [MathKeyboardStyle], [MathKeyboardSemantics], and decimal
/// separator to the [MathKeyboard]s below it in the tree.
///
/// A [MathField] resolves the style, semantics, and decimal separator from the
/// nearest [MathKeyboardTheme] at the time it opens its keyboard and forwards
/// them into the overlay, because the overlay is built in a separate context
/// that cannot read this ancestor.
///
/// Because the values are captured when the keyboard opens, changing the theme
/// while a keyboard is already open does not restyle that open keyboard — the
/// change takes effect the next time the keyboard is shown. This is generally
/// fine for the transient keyboard; close and reopen it to apply a live change.
class MathKeyboardTheme extends InheritedWidget {
  /// Constructs a [MathKeyboardTheme].
  const MathKeyboardTheme({
    super.key,
    this.style,
    this.semantics = MathKeyboardSemantics.fallback,
    this.decimalSeparator,
    required super.child,
  });

  /// The style applied to descendant math keyboards.
  ///
  /// Defaults to `null`, so a theme that only overrides [semantics] (for
  /// localization) need not supply a full style: descendant keyboards then
  /// keep their light/dark look from their `themeMode`.
  final MathKeyboardStyle? style;

  /// The screen-reader strings applied to descendant math keyboards.
  ///
  /// Override this to localize the spoken announcements; defaults to the
  /// English [MathKeyboardSemantics.fallback].
  final MathKeyboardSemantics semantics;

  /// The decimal separator displayed by descendant math fields and keyboards.
  ///
  /// Set this to pin the separator regardless of the locale, e.g. to back a
  /// user-facing setting. It only affects what is displayed and announced; the
  /// TeX reported by `MathField.onChanged` keeps the canonical `.`.
  ///
  /// Defaults to `null`, which resolves the separator from the ambient locale.
  final DecimalSeparator? decimalSeparator;

  /// Returns the [MathKeyboardStyle] from the nearest [MathKeyboardTheme], or
  /// [MathKeyboardStyle.fallback] if there is none.
  static MathKeyboardStyle styleOf(BuildContext context) {
    return maybeStyleOf(context) ?? MathKeyboardStyle.fallback;
  }

  /// Returns the [MathKeyboardStyle] from the nearest [MathKeyboardTheme], or
  /// `null` if there is none or it sets no style.
  ///
  /// Keyboards use this so that, without a themed style, they fall back to
  /// their `themeMode` rather than to [MathKeyboardStyle.fallback].
  static MathKeyboardStyle? maybeStyleOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MathKeyboardTheme>()
        ?.style;
  }

  /// Returns the [MathKeyboardSemantics] from the nearest [MathKeyboardTheme],
  /// or [MathKeyboardSemantics.fallback] if there is none.
  static MathKeyboardSemantics semanticsOf(BuildContext context) {
    final theme = context
        .dependOnInheritedWidgetOfExactType<MathKeyboardTheme>();
    return theme?.semantics ?? MathKeyboardSemantics.fallback;
  }

  /// Returns the decimal separator from the nearest [MathKeyboardTheme], or the
  /// separator of the current locale if there is none.
  static DecimalSeparator decimalSeparatorOf(BuildContext context) {
    final theme = context
        .dependOnInheritedWidgetOfExactType<MathKeyboardTheme>();
    return theme?.decimalSeparator ?? DecimalSeparator.of(context);
  }

  @override
  bool updateShouldNotify(MathKeyboardTheme oldWidget) {
    return oldWidget.style != style ||
        oldWidget.semantics != semantics ||
        oldWidget.decimalSeparator != decimalSeparator;
  }
}

/// The light and dark colour palettes of the math keyboard.
///
/// [MathKeyboardStyle.fromColors] turns a palette into a full
/// [MathKeyboardStyle]. Use [MathKeyboardColors.resolve] to pick the palette
/// for a [ThemeMode].
@immutable
class MathKeyboardColors {
  /// Constructs a [MathKeyboardColors] from the individual surface colors.
  const MathKeyboardColors({
    required this.background,
    required this.accent,
    required this.foreground,
    required this.tapOverlay,
    required this.focus,
  });

  /// Background color of the whole keyboard, and of digit and function keys.
  final Color background;

  /// Color of operator, navigation, variable, delete and page-toggle keys.
  final Color accent;

  /// Color for text, icons, and TeX rendered on the keyboard.
  final Color foreground;

  /// Color blended over a key while it is hovered or pressed.
  ///
  /// On a dark keyboard white brightens keys; on a light keyboard black darkens
  /// them.
  final Color tapOverlay;

  /// Color of the focus ring drawn around a focused key.
  final Color focus;

  /// The dark palette, i.e. the keyboard's original black look.
  factory MathKeyboardColors.dark() => const MathKeyboardColors(
    background: Colors.black,
    accent: Color(0xFF212121), // grey[900]
    foreground: Colors.white,
    tapOverlay: Colors.white,
    focus: Color(0xFF8ABAFE),
  );

  /// The light palette, i.e. a white keyboard with dark text/icons.
  factory MathKeyboardColors.light() => MathKeyboardColors(
    background: Colors.white,
    accent: Colors.grey[300]!,
    foreground: Colors.grey[900]!,
    tapOverlay: Colors.black,
    focus: const Color(0xFF0164EC),
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
          tapOverlay == other.tapOverlay &&
          focus == other.focus;

  @override
  int get hashCode =>
      Object.hash(background, accent, foreground, tapOverlay, focus);
}
