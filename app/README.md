# Escape Your Study Room — Flutter app

This folder contains the first implemented feature for the individual Mobile App Development project:

**Dodge the Flying Books**

Current feature flow:

1. Challenge preview
2. 3-2-1 countdown
3. Flying-books gameplay
4. Squat/movement detection
5. Pause, resume and restart
6. 5/5 completion screen

## Project structure

```text
app/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   └── theme/
│   │       └── app_theme.dart
│   └── features/
│       └── dodge_books/
│           ├── challenge.dart
│           ├── challenge_screen.dart
│           └── widgets/
│               ├── game_art.dart
│               ├── progress_segments.dart
│               └── study_room.dart
├── test/
│   └── challenge_test.dart
├── analysis_options.yaml
├── pubspec.yaml
└── pubspec.lock
```

## First local setup

The repository stores the app source and dependencies, but generated Flutter platform folders are intentionally not tracked yet.

From the repository root:

```bash
cd app
flutter create . --project-name escape_your_study_room
flutter pub get
flutter analyze
flutter test
```

Then run the app with a connected device:

```bash
flutter devices
flutter run -d <device-id>
```

On iOS/Android the feature uses `sensors_plus` for movement input. On desktop/web, the interface can be used for visual development and testing without presenting simulated input as real sensor detection.
