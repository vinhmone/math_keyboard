import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:math_keyboard/src/custom_key_icons/custom_key_icons.dart';
import 'package:math_keyboard/src/widgets/keyboard_button.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Stack(children: [child])),
  );
}

void main() {
  group('MathKeyboard allowedTools', () {
    // Pin a portrait window: the page toggle only exists in the paged portrait
    // layout (the default 800x600 test window is landscape).
    setUp(() {
      final view =
          TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
      view.physicalSize = const Size(400, 800);
      view.devicePixelRatio = 1;
    });
    tearDown(() {
      final view =
          TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    testWidgets('shows the page toggle when function tools are allowed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(MathKeyboard(controller: MathFieldEditingController())),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(CustomKeyIcons.keySymbols), findsOneWidget);
    });

    testWidgets('hides the page toggle when no function tool is allowed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MathKeyboard(
            controller: MathFieldEditingController(),
            // Only basic arithmetic on page 1 – nothing on page 2.
            allowedTools: const {
              MathKeyboardTool.add,
              MathKeyboardTool.subtract,
              MathKeyboardTool.multiply,
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(CustomKeyIcons.keySymbols), findsNothing);
    });

    testWidgets(
      'keeps the page toggle when at least one page-2 tool is allowed',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            MathKeyboard(
              controller: MathFieldEditingController(),
              allowedTools: const {MathKeyboardTool.sin},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(CustomKeyIcons.keySymbols), findsOneWidget);
      },
    );

    testWidgets('builds with an empty allowlist (digits + structural only)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MathKeyboard(
            controller: MathFieldEditingController(),
            allowedTools: const {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Digits are always present.
      expect(find.text('7'), findsOneWidget);
      // No page toggle since page 2 has no allowed tools.
      expect(find.byIcon(CustomKeyIcons.keySymbols), findsNothing);
    });
  });

  group('MathKeyboard allowedTools in landscape', () {
    Future<SemanticsHandle> pumpLandscape(
      WidgetTester tester, {
      required Set<MathKeyboardTool> allowedTools,
      List<String> variables = const [],
    }) async {
      final handle = tester.ensureSemantics();
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _wrap(
          MathKeyboard(
            controller: MathFieldEditingController(),
            allowedTools: allowedTools,
            variables: variables,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return handle;
    }

    testWidgets('drops the empty formula column when no function is allowed', (
      tester,
    ) async {
      final handle = await pumpLandscape(tester, allowedTools: const {});

      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Formula'), findsNothing);
      expect(find.bySemanticsLabel('Variables'), findsNothing);
      expect(find.bySemanticsLabel('Numbers'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_return), findsOneWidget);
      // The numbers take the width the formula column used to hold.
      final keyboardWidth = tester.getSize(find.byType(MathKeyboard)).width;
      expect(
        tester.getSize(find.bySemanticsLabel('Numbers')).width,
        greaterThan(keyboardWidth * 0.75),
      );

      handle.dispose();
    });

    testWidgets('keeps the variables when no function is allowed', (
      tester,
    ) async {
      final handle = await pumpLandscape(
        tester,
        allowedTools: const {},
        variables: const ['x'],
      );

      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Formula'), findsNothing);
      expect(find.bySemanticsLabel('Variables'), findsOneWidget);
      expect(find.bySemanticsLabel('Numbers'), findsOneWidget);

      // Screen readers reach the variables before the numbers.
      final labels = <String>[];
      void visit(SemanticsNode node) {
        labels.add(node.label);
        node
            .debugListChildrenInOrder(DebugSemanticsDumpOrder.traversalOrder)
            .forEach(visit);
      }

      visit(tester.getSemantics(find.bySemanticsLabel('Math keyboard')));
      expect(labels, containsAll(['Variables', 'Numbers']));
      expect(labels.indexOf('Variables'), lessThan(labels.indexOf('Numbers')));

      handle.dispose();
    });

    // MathField always passes variables (π and e), so this is the case every
    // landscape field with a function-free allowlist produces.
    for (final size in const [Size(568, 320), Size(640, 360), Size(800, 400)]) {
      testWidgets(
        'a MathField keyboard keeps its height without functions at $size',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          Future<double> keyboardHeight(Set<MathKeyboardTool>? tools) async {
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: MathField(
                    key: UniqueKey(),
                    autofocus: true,
                    allowedTools: tools,
                  ),
                ),
              ),
            );
            // Advance past the keyboard slide-in animation.
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 300));
            expect(tester.takeException(), isNull);
            return tester
                .getSize(
                  find
                      .descendant(
                        of: find.byType(MathKeyboard),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .height;
          }

          final withFunctions = await keyboardHeight(null);
          final withoutFunctions = await keyboardHeight(const {});
          expect(withoutFunctions, withFunctions);

          await tester.pumpWidget(const SizedBox());
        },
      );
    }

    testWidgets('shows only the allowed functions', (tester) async {
      final handle = await pumpLandscape(
        tester,
        allowedTools: const {MathKeyboardTool.sin, MathKeyboardTool.add},
      );

      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Formula'), findsOneWidget);
      expect(find.bySemanticsLabel('sine'), findsOneWidget);
      expect(find.bySemanticsLabel('cosine'), findsNothing);
      // The number section is filtered too: + stays, × and ( go.
      expect(find.widgetWithText(KeyboardButton, '+'), findsOneWidget);
      expect(find.widgetWithText(KeyboardButton, '×'), findsNothing);
      expect(find.widgetWithText(KeyboardButton, '('), findsNothing);
      expect(find.widgetWithText(KeyboardButton, '7'), findsOneWidget);

      handle.dispose();
    });
  });

  group('numberOnly validation & formatting', () {
    MathFieldEditingController numberController() =>
        MathFieldEditingController()..numberOnly = true;

    String type(MathFieldEditingController controller, String keys) {
      for (final key in keys.split('')) {
        controller.addLeaf(key);
      }
      return controller.currentEditingValue(placeholderWhenEmpty: false);
    }

    test('adds a leading zero for a bare decimal', () {
      expect(type(numberController(), '.5'), '0.5');
    });

    test('blocks a second decimal point', () {
      expect(type(numberController(), '5..5'), '5.5');
    });

    test('blocks a second minus', () {
      expect(type(numberController(), '--5'), '-5');
    });

    test('strips redundant leading zeros', () {
      expect(type(numberController(), '007'), '7');
    });

    test('re-formats to well-formed after a deletion', () {
      final controller = numberController();
      type(controller, '0.5'); // cursor at end: 0.5|
      controller.goBack(); // 0.|5
      controller.goBack(); // 0|.5  (cursor right after the leading zero)
      controller.goBack(deleteMode: true); // delete the `0` -> `.5` -> `0.5`
      expect(
        controller.currentEditingValue(placeholderWhenEmpty: false),
        '0.5',
      );
    });
  });

  group('MathKeyboard light/dark theme', () {
    Color backgroundOf(WidgetTester tester) {
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(MathKeyboard),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      return (box.decoration as BoxDecoration).color!;
    }

    Future<Color> keyboardBackground(
      WidgetTester tester, {
      ThemeMode themeMode = ThemeMode.system,
      Brightness platformBrightness = Brightness.light,
      MathKeyboardStyle? themeStyle,
    }) async {
      tester.platformDispatcher.platformBrightnessTestValue =
          platformBrightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final keyboard = MathKeyboard(
        controller: MathFieldEditingController(),
        themeMode: themeMode,
      );
      await tester.pumpWidget(
        _wrap(
          themeStyle == null
              ? keyboard
              : MathKeyboardTheme(style: themeStyle, child: keyboard),
        ),
      );
      await tester.pumpAndSettle();
      return backgroundOf(tester);
    }

    testWidgets('light and dark modes give different backgrounds', (
      tester,
    ) async {
      final light = await keyboardBackground(
        tester,
        themeMode: ThemeMode.light,
      );
      final dark = await keyboardBackground(tester, themeMode: ThemeMode.dark);

      expect(light, MathKeyboardColors.light().background);
      expect(dark, MathKeyboardColors.dark().background);
      expect(light, isNot(dark));
    });

    testWidgets('system mode follows the platform brightness', (tester) async {
      expect(
        await keyboardBackground(tester, platformBrightness: Brightness.dark),
        MathKeyboardColors.dark().background,
      );
      expect(
        await keyboardBackground(tester, platformBrightness: Brightness.light),
        MathKeyboardColors.light().background,
      );
    });

    testWidgets('a MathKeyboardTheme style overrides the theme mode', (
      tester,
    ) async {
      final background = await keyboardBackground(
        tester,
        themeMode: ThemeMode.light,
        themeStyle: MathKeyboardStyle.fallback,
      );

      expect(background, MathKeyboardStyle.fallback.backgroundColor);
    });

    testWidgets('a semantics-only MathKeyboardTheme keeps the theme mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MathKeyboardTheme(
            child: MathKeyboard(
              controller: MathFieldEditingController(),
              themeMode: ThemeMode.light,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(backgroundOf(tester), MathKeyboardColors.light().background);
    });

    testWidgets(
      'an open MathField keyboard follows a live platform brightness change',
      (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue =
            Brightness.light;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MathField(autofocus: true, themeMode: ThemeMode.system),
            ),
          ),
        );
        // Advance past the keyboard slide-in animation. (No pumpAndSettle: the
        // field's cursor blinks forever.)
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(backgroundOf(tester), MathKeyboardColors.light().background);

        // The OS switches to dark while the keyboard is open.
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        await tester.pump();

        expect(backgroundOf(tester), MathKeyboardColors.dark().background);

        await tester.pumpWidget(const SizedBox());
      },
    );
  });

  group('nested MathKeyboardTheme', () {
    final outerStyle = MathKeyboardStyle.fallback.copyWith(
      backgroundColor: const Color(0xFF123456),
    );
    final outerSemantics = MathKeyboardSemantics.fallback.copyWith(
      submitLabel: 'Gửi',
    );

    testWidgets('a semantics-only inner theme keeps the outer style', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MathKeyboardTheme(
            style: outerStyle,
            child: MathKeyboardTheme(
              semantics: outerSemantics,
              child: MathKeyboard(
                controller: MathFieldEditingController(),
                themeMode: ThemeMode.light,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(MathKeyboard),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(
        (box.decoration as BoxDecoration).color,
        outerStyle.backgroundColor,
      );
    });

    testWidgets('an inner theme keeps the outer semantics and separator', (
      tester,
    ) async {
      late MathKeyboardSemantics semantics;
      late DecimalSeparator separator;
      late MathKeyboardStyle? style;
      await tester.pumpWidget(
        _wrap(
          MathKeyboardTheme(
            semantics: outerSemantics,
            decimalSeparator: DecimalSeparator.comma,
            child: MathKeyboardTheme(
              style: outerStyle,
              child: Builder(
                builder: (context) {
                  semantics = MathKeyboardTheme.semanticsOf(context);
                  separator = MathKeyboardTheme.decimalSeparatorOf(context);
                  style = MathKeyboardTheme.maybeStyleOf(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(semantics, outerSemantics);
      expect(separator, DecimalSeparator.comma);
      expect(style, outerStyle);
    });

    testWidgets('the nearest theme that sets a value wins', (tester) async {
      late DecimalSeparator separator;
      late MathKeyboardStyle? style;
      await tester.pumpWidget(
        _wrap(
          MathKeyboardTheme(
            style: MathKeyboardStyle.fallback,
            decimalSeparator: DecimalSeparator.comma,
            child: MathKeyboardTheme(
              style: outerStyle,
              decimalSeparator: DecimalSeparator.dot,
              child: Builder(
                builder: (context) {
                  separator = MathKeyboardTheme.decimalSeparatorOf(context);
                  style = MathKeyboardTheme.maybeStyleOf(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(separator, DecimalSeparator.dot);
      expect(style, outerStyle);
    });

    testWidgets('a change to an outer theme rebuilds an inner dependent', (
      tester,
    ) async {
      MathKeyboardStyle? style;
      // One inner subtree instance, so the Builder rebuilds only through its
      // dependency on the outer theme.
      final inner = MathKeyboardTheme(
        child: Builder(
          builder: (context) {
            style = MathKeyboardTheme.maybeStyleOf(context);
            return const SizedBox();
          },
        ),
      );

      await tester.pumpWidget(
        MathKeyboardTheme(style: MathKeyboardStyle.fallback, child: inner),
      );
      expect(style, MathKeyboardStyle.fallback);

      await tester.pumpWidget(
        MathKeyboardTheme(style: outerStyle, child: inner),
      );
      expect(style, outerStyle);
    });
  });
}
