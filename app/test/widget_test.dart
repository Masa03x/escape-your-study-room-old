import 'package:escape_your_study_room/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the redesigned flying books challenge intro', (tester) async {
    await tester.pumpWidget(const StudyEscapeApp());

    expect(find.text('Dodge the Flying Books'), findsOneWidget);
    expect(find.text('Start Challenge'), findsOneWidget);
    expect(find.text('Dodge 5 books to escape the room'), findsOneWidget);
  });
}
