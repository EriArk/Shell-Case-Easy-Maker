import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/app/case_maker_app.dart';

void main() {
  testWidgets('workspace shell shows semantic enclosure UI', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    expect(find.text('Shell Case Easy Maker'), findsOneWidget);
    expect(find.text('main_enclosure'), findsWidgets);
    expect(find.text('Custom Button Board'), findsWidgets);

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    expect(find.text('120 x 70 x 28 mm'), findsOneWidget);
  });

  testWidgets('selecting a feature updates contextual inspector', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    expect(find.text('width'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('USB-C'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('USB-C').first);
    await tester.pumpAndSettle();

    expect(find.text('width'), findsOneWidget);
    expect(find.text('front_usb_c'), findsWidgets);
  });

  testWidgets('editing enclosure width updates semantic inspector', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('enclosure-param-width')),
      '150',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('150 x 70 x 28 mm'), findsOneWidget);
  });
}
