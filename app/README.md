# Escape Your Study Room — Flutter app

First coded prototype for [issue #4](https://github.com/Masa03x/escape-your-study-room/issues/4). Includes instructions, animated books, a five-dodge goal, progress, pause/resume, leaving and completion.

## Run on your Mac

From the repository root:

```sh
cd app
bash tool/setup.sh
flutter run -d chrome
```

The setup script generates the standard iOS, Android and web runners without overwriting the feature source, adds the iOS motion description, and fetches dependencies. Commit the generated runners and `pubspec.lock` after setup.

Demo mode uses a clearly labelled button and does not require sensors. It is enabled by default. Use this first to review the flow.

## Run on your iPhone

```sh
flutter devices
flutter run -d YOUR_DEVICE_ID
```

Replace `YOUR_DEVICE_ID` with the ID shown by `flutter devices`. Physical iPhone builds need Xcode signing set up for your Apple account. Turn Demo mode off on the instructions screen to try phone motion. Simulators may not provide motion data; use Demo mode there.

Hold the phone upright in portrait at chest height, screen towards you. Stand still briefly at the start of each dodge cue, then lower comfortably. The initial detector looks for a downward acceleration pulse followed by braking. It estimates phone movement only and can be fooled by hand movement. Thresholds, phone position and timing need real-device testing before describing this as reliable squat detection.

If sensor data is missing or stops arriving, the game pauses with a retry message. Backgrounding also pauses it; resume starts a fresh book opportunity.

## Code map

- `lib/main.dart`: app entry point and theme.
- `lib/features/dodge_books/challenge.dart`: game rules and experimental motion detector.
- `lib/features/dodge_books/challenge_screen.dart`: screens, animation, lifecycle and sensor connection.
- `test/`: game, detector and demo-flow tests.

## Checks

```sh
flutter analyze
flutter test
flutter build web
```

## Sensor reference

Uses `sensors_plus` 7.1.0 and its gravity-filtered `userAccelerometerEventStream`. See https://pub.dev/packages/sensors_plus and https://pub.dev/documentation/sensors_plus/latest/sensors_plus/userAccelerometerEventStream.html . The setup script adds `NSMotionUsageDescription` to iOS as required by the package.

## Still to test

The concept has not been user-tested yet. Test phone movement accuracy, false detections, comfort, timing and screen visibility on a physical phone. The first goal of five dodges and current movement thresholds are prototype assumptions.

## Validation in the coding environment

Dart formatting and a direct Dart check of scoring, duplicate rejection, completion, pause/resume, a motion pulse, sustained input and detector reset passed. Full Flutter setup was blocked by automatic approval review after an attempted cloud metadata endpoint access. Flutter analysis, widget tests and platform builds have NOT run. Run the checks above on your Mac before treating this draft as verified.
