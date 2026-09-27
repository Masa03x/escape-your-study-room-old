# Escape Your Study Room — Flutter app

Flutter implementation of the **Dodge the Flying Books** feature for the first portfolio iteration.

The feature UI has been rebuilt to match the new Figma Make direction: deep navy backgrounds, purple game UI, green success feedback, Fredoka-style headings, Nunito body text, illustrated books/student characters, segmented progress, a countdown, room scene, pause overlay and completion screen.

## Implemented first-feature flow

1. Challenge preview
2. Safety + movement explanation
3. 3 → 2 → 1 → MOVE countdown
4. Flying-books gameplay
5. 5-dodge segmented progress
6. Pause / resume / restart / leave
7. Completion result

The existing `Challenge` rules and `MovementDetector` remain separate from the visual layer. On iOS/Android the feature uses `sensors_plus`; on desktop/web the same flow can be previewed by tapping the room during the dodge cue.

## Run

```sh
flutter pub get
flutter run
```

For a connected iPhone:

```sh
flutter devices
flutter run -d YOUR_DEVICE_ID
```

## Code map

- `lib/main.dart` — app entry point.
- `lib/core/theme/app_theme.dart` — Figma-based colours and typography.
- `lib/features/dodge_books/challenge.dart` — game rules and movement detector.
- `lib/features/dodge_books/challenge_screen.dart` — feature flow and sensor lifecycle.
- `lib/features/dodge_books/widgets/game_art.dart` — flying book, student and movement illustrations.
- `lib/features/dodge_books/widgets/study_room.dart` — illustrated gameplay room.
- `lib/features/dodge_books/widgets/progress_segments.dart` — reusable 5-step progress component.

## Current scope

This commit focuses on the first portfolio feature rather than building every app screen at once. The Home, Challenge Selection and Settings screens from the Figma Make concept can be added after the Dodge Books feature is tested and improved.

## Checks

```sh
flutter analyze
flutter test
```

The pure game/detector tests in `challenge_test.dart` remain active. The visual widget smoke test is temporarily skipped because the new typography uses runtime Google Fonts. Run the application locally to review visual fidelity.
