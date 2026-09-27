import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/dodge_books/challenge_screen.dart';

void main() => runApp(const StudyEscapeApp());

class StudyEscapeApp extends StatelessWidget {
  const StudyEscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escape Your Study Room',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const ChallengeScreen(),
    );
  }
}
