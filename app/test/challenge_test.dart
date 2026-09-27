import 'package:flutter_test/flutter_test.dart';
import 'package:escape_your_study_room/features/dodge_books/challenge.dart';

void main() {
  test('only one score per active book, and never outside the window', () {
    final game = Challenge()..start();
    expect(game.dodge(), false);
    game.tick(1.2);
    expect(game.dodge(), true);
    expect(game.dodge(), false);
    expect(game.score, 1);
    game.tick(2.8);
    expect(game.dodge(), false);
  });
  test('pause freezes time; resume starts a fresh opportunity', () {
    final game = Challenge()
      ..start()
      ..tick(2)
      ..pause();
    game.tick(10);
    expect(game.elapsed, 2);
    expect(game.dodge(), false);
    game.resume();
    expect(game.elapsed, 0);
    expect(game.dodge(), false);
  });
  test('five distinct dodges complete the game and stop scoring', () {
    final game = Challenge()..start();
    for (var i = 0; i < 5; i++) {
      game.tick(1.2);
      expect(game.dodge(), true);
      game.tick(2.8);
    }
    expect(game.phase, ChallengePhase.complete);
    expect(game.score, 5);
    expect(game.dodge(), false);
  });
  test('noise and sustained acceleration do not trigger a movement', () {
    final detector = MovementDetector();
    for (var i = 0; i < 100; i++) {
      expect(detector.add(i.isEven ? 0.1 : -0.1, i * 0.04), false);
    }
    for (var i = 100; i < 200; i++) {
      expect(detector.add(-4, i * 0.04), false);
    }
  });
  test('one down/brake pulse counts once and reset rejects stale braking', () {
    final detector = MovementDetector();
    var time = 0.0;
    var detections = 0;
    void samples(double value, int count) {
      for (var i = 0; i < count; i++) {
        if (detector.add(value, time)) detections++;
        time += 0.04;
      }
    }

    samples(0, 15);
    samples(-4, 10);
    samples(4, 10);
    expect(detections, 1);
    samples(4, 30);
    expect(detections, 1);
    detector.reset();
    samples(4, 10);
    expect(detections, 1);
  });
}
