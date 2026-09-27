enum ChallengePhase { ready, playing, paused, complete }

/// Pure game rules, independent of widgets and phone sensors.
class Challenge {
  static const goal = 5;
  static const roundLength = 4.0;
  ChallengePhase phase = ChallengePhase.ready;
  int score = 0;
  double elapsed = 0;
  bool dodged = false;
  String feedback = 'Get ready for the book!';

  bool get canDodge =>
      phase == ChallengePhase.playing &&
      elapsed >= 1 &&
      elapsed <= 3.5 &&
      !dodged;

  void start() {
    phase = ChallengePhase.playing;
    score = 0;
    resetRound();
  }

  void resetRound() {
    elapsed = 0;
    dodged = false;
    feedback = 'Get ready for the book!';
  }

  void tick(double seconds) {
    if (phase != ChallengePhase.playing) return;
    elapsed += seconds;
    if (elapsed >= roundLength) {
      final missed = !dodged;
      resetRound();
      if (missed) feedback = 'That book was keen. Try the next one!';
    }
  }

  bool dodge() {
    if (!canDodge) return false;
    dodged = true;
    score++;
    feedback = 'Nice dodge! Homework avoided.';
    if (score == goal) phase = ChallengePhase.complete;
    return true;
  }

  void pause() {
    if (phase == ChallengePhase.playing) phase = ChallengePhase.paused;
  }

  void resume() {
    if (phase != ChallengePhase.paused) return;
    resetRound();
    phase = ChallengePhase.playing;
  }
}

/// Experimental down/brake pulse detector for an upright portrait phone.
/// Phone motion is only an estimate: it cannot verify a squat or its form.
class MovementDetector {
  double filteredY = 0;
  double? downAt;
  double? quietSince;
  double cooldownUntil = 0;
  bool armed = false;

  void reset() {
    filteredY = 0;
    downAt = null;
    quietSince = null;
    cooldownUntil = 0;
    armed = false;
  }

  bool add(double y, double seconds) {
    if (!y.isFinite || !seconds.isFinite) return false;
    filteredY = filteredY * 0.65 + y * 0.35;
    if (seconds < cooldownUntil) return false;
    if (!armed) {
      if (filteredY.abs() < 0.6) {
        quietSince ??= seconds;
        if (seconds - quietSince! >= 0.3) armed = true;
      } else {
        quietSince = null;
      }
      return false;
    }
    if (downAt == null) {
      if (filteredY < -1.2) downAt = seconds;
      return false;
    }
    final duration = seconds - downAt!;
    if (duration > 1.8) {
      downAt = null;
      armed = false;
      quietSince = null;
      return false;
    }
    if (filteredY > 1.0 && duration >= 0.15) {
      downAt = null;
      quietSince = null;
      armed = false;
      cooldownUntil = seconds + 1.0;
      return true;
    }
    return false;
  }
}
