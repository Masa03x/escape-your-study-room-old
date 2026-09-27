import 'package:flutter_test/flutter_test.dart';
import 'package:escape_your_study_room/main.dart';

void main() {
  testWidgets(
    'new Figma-style challenge flow smoke test',
    (tester) async {
      await tester.pumpWidget(const StudyEscapeApp());
      expect(find.text('Dodge the Flying Books'), findsOneWidget);
      expect(find.text('🚀  Start Challenge'), findsOneWidget);
    },
    skip: 'Visual smoke test needs runtime Google Fonts; run it locally with Flutter after pub get.',
  );
}
