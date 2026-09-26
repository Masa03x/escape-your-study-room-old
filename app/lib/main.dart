import 'package:flutter/material.dart';

import 'features/dodge_books/challenge_screen.dart';

void main() => runApp(const StudyEscapeApp());

class StudyEscapeApp extends StatelessWidget {
  const StudyEscapeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Escape Your Study Room',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFB7E58A),
        brightness: Brightness.dark,
        surface: const Color(0xFF202C32),
      ),
      scaffoldBackgroundColor: const Color(0xFF142027),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(180, 54),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    home: const ChallengeScreen(),
  );
}
