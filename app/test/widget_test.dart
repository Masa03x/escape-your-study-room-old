import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:escape_your_study_room/main.dart';

void main() {
  testWidgets('demo can finish five dodges and return to instructions', (
    tester,
  ) async {
    await tester.pumpWidget(const StudyEscapeApp());
    await tester.ensureVisible(find.text('Start demo break'));
    await tester.tap(find.text('Start demo break'));
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      for (var frame = 0; frame < 15; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.ensureVisible(find.text('Demo: dodge book'));
      await tester.tap(find.text('Demo: dodge book'));
      await tester.pump();
      if (i < 4) {
        for (var frame = 0; frame < 26; frame++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
    }
    expect(find.text('You escaped the homework!'), findsOneWidget);
    await tester.ensureVisible(find.text('Finish break'));
    await tester.tap(find.text('Finish break'));
    await tester.pump();
    expect(find.text('Start demo break'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
