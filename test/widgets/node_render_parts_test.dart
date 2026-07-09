import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/widgets/node_render_parts.dart';
import 'package:just_tooltip/just_tooltip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final node = Node<String>(id: 'n', label: 'n', type: NodeType.child);

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: child))),
      );

  group('wrapWithNodeTooltip', () {
    testWidgets('returns the child unchanged when tooltips are disabled',
        (tester) async {
      await pump(
        tester,
        wrapWithNodeTooltip<String>(
          child: const Text('content'),
          tooltipTheme: const NodeTooltipTheme<String>(useTooltip: false),
          node: node,
        ),
      );
      expect(find.byType(JustTooltip), findsNothing);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('wraps in a JustTooltip when enabled with a message',
        (tester) async {
      await pump(
        tester,
        wrapWithNodeTooltip<String>(
          child: const Text('content'),
          tooltipTheme:
              const NodeTooltipTheme<String>(useTooltip: true, message: 'hi'),
          node: node,
        ),
      );
      expect(find.byType(JustTooltip), findsOneWidget);
    });

    testWidgets('returns child when enabled but there is no content',
        (tester) async {
      await pump(
        tester,
        wrapWithNodeTooltip<String>(
          child: const Text('content'),
          tooltipTheme: const NodeTooltipTheme<String>(useTooltip: true),
          node: node,
        ),
      );
      expect(find.byType(JustTooltip), findsNothing);
    });

    testWidgets('uses tooltipBuilderResolver when provided', (tester) async {
      await pump(
        tester,
        wrapWithNodeTooltip<String>(
          child: const Text('content'),
          tooltipTheme: NodeTooltipTheme<String>(
            useTooltip: true,
            tooltipBuilderResolver: (n) => (context) => const Text('tip'),
          ),
          node: node,
        ),
      );
      expect(find.byType(JustTooltip), findsOneWidget);
    });

    testWidgets('anchors to the child rect when anchor is left unset',
        (tester) async {
      await pump(
        tester,
        wrapWithNodeTooltip<String>(
          child: const Text('content'),
          tooltipTheme:
              const NodeTooltipTheme<String>(useTooltip: true, message: 'hi'),
          node: node,
        ),
      );
      final tooltip = tester.widget<JustTooltip>(find.byType(JustTooltip));
      expect(tooltip.anchor, TooltipAnchor.child);
    });

    testWidgets('forwards anchor to the JustTooltip it builds', (tester) async {
      await pump(
        tester,
        wrapWithNodeTooltip<String>(
          child: const Text('content'),
          tooltipTheme: const NodeTooltipTheme<String>(
            useTooltip: true,
            message: 'hi',
            anchor: TooltipAnchor.pointer,
          ),
          node: node,
        ),
      );
      final tooltip = tester.widget<JustTooltip>(find.byType(JustTooltip));
      expect(tooltip.anchor, TooltipAnchor.pointer);
    });

    testWidgets('forwards anchor on the tooltipBuilder path too',
        (tester) async {
      await pump(
        tester,
        wrapWithNodeTooltip<String>(
          child: const Text('content'),
          tooltipTheme: NodeTooltipTheme<String>(
            useTooltip: true,
            anchor: TooltipAnchor.pointer,
            tooltipBuilder: (context) => const Text('tip'),
          ),
          node: node,
        ),
      );
      final tooltip = tester.widget<JustTooltip>(find.byType(JustTooltip));
      expect(tooltip.anchor, TooltipAnchor.pointer);
      expect(tooltip.message, isNull);
    });
  });

  group('NodeIconBox', () {
    testWidgets('renders an empty spacer when the icon is null',
        (tester) async {
      await pump(
        tester,
        const NodeIconBox(
          iconWidget: null,
          width: 20,
          height: 20,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          emptyWidth: 30,
          scale: 1.0,
        ),
      );
      expect(find.byType(FittedBox), findsNothing);
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('renders the icon without a FittedBox at scale 1',
        (tester) async {
      await pump(
        tester,
        const NodeIconBox(
          iconWidget: Icon(Icons.star),
          width: 20,
          height: 20,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          emptyWidth: 30,
          scale: 1.0,
        ),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byType(FittedBox), findsNothing);
    });

    testWidgets('wraps the icon in a FittedBox when scale != 1',
        (tester) async {
      await pump(
        tester,
        const NodeIconBox(
          iconWidget: Icon(Icons.star),
          width: 20,
          height: 20,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          emptyWidth: 30,
          scale: 2.0,
        ),
      );
      expect(find.byType(FittedBox), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
