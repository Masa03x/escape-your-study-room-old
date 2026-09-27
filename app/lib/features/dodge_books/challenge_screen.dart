import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/theme/app_theme.dart';
import 'challenge.dart';
import 'widgets/game_art.dart';
import 'widgets/progress_segments.dart';
import 'widgets/study_room.dart';

enum ChallengeView { intro, countdown, game, complete }

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final game = Challenge();
  final detector = MovementDetector();
  final sensorClock = Stopwatch()..start();

  StreamSubscription<UserAccelerometerEvent>? subscription;
  Timer? sensorTimeout;
  Timer? countdownTimer;
  late final Ticker ticker;
  Duration previous = Duration.zero;

  ChallengeView view = ChallengeView.intro;
  int countdown = 3;
  bool showMove = false;
  bool connecting = false;
  int sensorGeneration = 0;
  String? sensorError;
  double sessionSeconds = 0;

  bool get phoneSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  bool get demo => !phoneSupported;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ticker = createTicker((time) {
      final seconds = (time - previous).inMicroseconds / 1000000;
      previous = time;
      if (view == ChallengeView.game &&
          game.phase == ChallengePhase.playing &&
          !connecting) {
        final wasOpen = game.canDodge;
        final delta = seconds.clamp(0.0, 0.1).toDouble();
        setState(() {
          game.tick(delta);
          sessionSeconds += delta;
        });
        if (wasOpen && !game.canDodge) detector.reset();
      }
    })..start();
  }

  void stopSensors() {
    sensorGeneration++;
    subscription?.cancel();
    subscription = null;
    sensorTimeout?.cancel();
    sensorTimeout = null;
    connecting = false;
    detector.reset();
  }

  void connectSensors() {
    stopSensors();
    if (demo) return;
    connecting = true;
    final generation = sensorGeneration;

    void failed() {
      if (!mounted || generation != sensorGeneration) return;
      stopSensors();
      setState(() {
        game.pause();
        sensorError =
            'Motion data is unavailable. Check Motion & Fitness access, then resume.';
      });
    }

    sensorTimeout = Timer(const Duration(seconds: 5), failed);
    try {
      subscription = userAccelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 40),
      ).listen(
        (event) {
          if (!mounted || generation != sensorGeneration) return;
          sensorTimeout?.cancel();
          sensorTimeout = Timer(const Duration(seconds: 5), failed);
          if (connecting) setState(() => connecting = false);
          if (game.phase != ChallengePhase.playing) return;
          if (!game.canDodge) {
            detector.reset();
            return;
          }
          if (detector.add(event.y, sensorClock.elapsedMicroseconds / 1000000)) {
            attemptDodge();
          }
        },
        onError: (Object error) => failed(),
        onDone: failed,
        cancelOnError: true,
      );
    } catch (_) {
      failed();
    }
  }

  void beginCountdown() {
    countdownTimer?.cancel();
    setState(() {
      sensorError = null;
      view = ChallengeView.countdown;
      countdown = 3;
      showMove = false;
    });

    var ticks = 0;
    countdownTimer = Timer.periodic(const Duration(milliseconds: 850), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      ticks++;
      if (ticks < 3) {
        setState(() => countdown = 3 - ticks);
      } else if (ticks == 3) {
        setState(() => showMove = true);
      } else {
        timer.cancel();
        startGame();
      }
    });
  }

  void startGame() {
    setState(() {
      game.start();
      sessionSeconds = 0;
      view = ChallengeView.game;
      sensorError = null;
    });
    connectSensors();
  }

  void attemptDodge() {
    if (connecting || game.phase != ChallengePhase.playing) return;
    final counted = game.dodge();
    if (!counted) {
      if (mounted) setState(() {});
      return;
    }
    setState(() {});
    if (game.phase == ChallengePhase.complete) {
      stopSensors();
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        if (!mounted) return;
        setState(() => view = ChallengeView.complete);
      });
    }
  }

  void pause() {
    stopSensors();
    setState(game.pause);
  }

  void resume() {
    setState(() {
      sensorError = null;
      game.resume();
    });
    connectSensors();
  }

  void restart() {
    stopSensors();
    beginCountdown();
  }

  void leave() {
    countdownTimer?.cancel();
    stopSensors();
    setState(() {
      game.phase = ChallengePhase.ready;
      view = ChallengeView.intro;
      sessionSeconds = 0;
      sensorError = null;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed &&
        view == ChallengeView.game &&
        game.phase == ChallengePhase.playing) {
      pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    countdownTimer?.cancel();
    stopSensors();
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: view == ChallengeView.intro,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) leave();
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: switch (view) {
            ChallengeView.intro => _buildIntro(),
            ChallengeView.countdown => _buildCountdown(),
            ChallengeView.game => _buildGame(),
            ChallengeView.complete => _buildComplete(),
          },
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      key: const ValueKey('intro'),
      color: AppColors.bgDark,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                  child: Row(
                    children: [
                      _SquareButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'CHALLENGE PREVIEW',
                        style: AppText.body(
                          size: 12,
                          color: AppColors.textMuted,
                          weight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 6, 22, 18),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 126,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.red.withValues(alpha: 0.05),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.red.withValues(alpha: 0.18),
                                      blurRadius: 42,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const FlyingBook(
                                width: 100,
                                title: 'ADVANCED MATHS',
                                rotation: -0.10,
                                showMotionLines: false,
                              ),
                              Positioned(
                                top: 10,
                                right: 55,
                                child: Text('✦', style: AppText.heading(size: 18)),
                              ),
                              Positioned(
                                left: 45,
                                top: 30,
                                child: Text('★', style: AppText.heading(size: 13, color: AppColors.orange)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: _cardDecoration(radius: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dodge the Flying Books',
                                style: AppText.heading(size: 24),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                'Books have revolted. Squat down in real life when a book flies toward you to dodge it.',
                                style: AppText.body(size: 13, height: 1.5),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                decoration: BoxDecoration(
                                  color: AppColors.green.withValues(alpha: 0.09),
                                  border: Border.all(color: AppColors.green.withValues(alpha: 0.27)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Text('🎯', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Goal', style: AppText.heading(size: 14, color: AppColors.green)),
                                        Text(
                                          'Dodge 5 books to escape the room',
                                          style: AppText.body(size: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.purple.withValues(alpha: 0.09),
                                  border: Border.all(color: AppColors.purple.withValues(alpha: 0.20)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const MovementMiniDiagram(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.08),
                            border: Border.all(color: AppColors.orange.withValues(alpha: 0.20)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('⚠️', style: TextStyle(fontSize: 15)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Make sure you have enough space to squat safely.',
                                  style: AppText.body(
                                    size: 11,
                                    color: AppColors.orangeLight,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (demo) ...[
                          const SizedBox(height: 9),
                          Text(
                            'Laptop preview: tap the game room when the dodge cue appears.',
                            textAlign: TextAlign.center,
                            style: AppText.body(size: 10.5, color: AppColors.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
                  child: _PrimaryButton(
                    key: const Key('start-challenge'),
                    label: '🚀  Start Challenge',
                    color: AppColors.green,
                    onPressed: beginCountdown,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    final label = showMove ? 'MOVE!' : '$countdown';
    return Container(
      key: const ValueKey('countdown'),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [Color(0xFF3B0F87), AppColors.bgDeepest],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: FloatingSparkles()),
            Positioned(
              top: 50,
              left: -18,
              child: Opacity(
                opacity: 0.28,
                child: Transform.rotate(
                  angle: -0.28,
                  child: const FlyingBook(
                    width: 76,
                    bookColor: AppColors.blue,
                    spineColor: AppColors.blueDark,
                    title: 'HISTORY',
                    emotion: BookEmotion.scared,
                    showMotionLines: false,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 35,
              right: -18,
              child: Opacity(
                opacity: 0.28,
                child: const FlyingBook(
                  width: 68,
                  bookColor: AppColors.purple,
                  spineColor: AppColors.purpleDark,
                  title: 'ESSAY',
                  emotion: BookEmotion.scared,
                  rotation: 0.24,
                  showMotionLines: false,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 184,
                    height: 184,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.purpleLight.withValues(alpha: 0.22), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.38),
                          blurRadius: 60,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Container(
                      width: 150,
                      height: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.purpleLight.withValues(alpha: 0.32), width: 2),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (child, animation) => ScaleTransition(
                          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
                          child: FadeTransition(opacity: animation, child: child),
                        ),
                        child: Text(
                          label,
                          key: ValueKey(label),
                          style: AppText.heading(
                            size: showMove ? 54 : 92,
                            shadows: [
                              Shadow(color: AppColors.purpleLight.withValues(alpha: 0.9), blurRadius: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    showMove ? 'DODGE THE CHAOS' : 'GET READY TO SQUAT...',
                    style: AppText.body(
                      size: 13,
                      color: AppColors.textMuted,
                      weight: FontWeight.w900,
                      letterSpacing: 3.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame() {
    final paused = game.phase == ChallengePhase.paused;
    final nearEnd = game.score >= 4;
    final roundProgress = (game.elapsed / Challenge.roundLength).clamp(0.0, 1.0);
    final status = paused
        ? 'Break paused'
        : connecting
        ? 'Connecting to motion sensor…'
        : game.canDodge
        ? 'SQUAT NOW!'
        : nearEnd
        ? 'Almost out! Keep squatting!'
        : 'Squat to dodge the next book!';

    return Container(
      key: const ValueKey('game'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: nearEnd
              ? const [Color(0xFF0A1A12), AppColors.bgDeepest]
              : const [AppColors.bgDark, AppColors.bgDeepest],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Stack(
              children: [
                Column(
                  children: [
                    _GameHud(
                      score: game.score,
                      seconds: sessionSeconds,
                      onPause: paused ? resume : pause,
                      paused: paused,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: StudyRoom(
                              roundProgress: roundProgress,
                              score: game.score,
                              dodged: game.dodged,
                              paused: paused,
                              onDemoTap: demo && !paused ? attemptDodge : null,
                            ),
                          ),
                          if (game.dodged && !paused)
                            Positioned(
                              top: 18,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.green.withValues(alpha: 0.95),
                                        AppColors.green.withValues(alpha: 0.72),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.green.withValues(alpha: 0.35),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '✓ Nice dodge! That book almost got you.',
                                    style: AppText.heading(size: 13, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.bgDeepest.withValues(alpha: 0.98)],
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('📱', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  status,
                                  style: AppText.body(
                                    size: 12,
                                    color: game.canDodge ? AppColors.orangeLight : nearEnd ? AppColors.green : AppColors.textSoft,
                                    weight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (sensorError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              sensorError!,
                              textAlign: TextAlign.center,
                              style: AppText.body(size: 10.5, color: AppColors.orangeLight),
                            ),
                          ],
                          if (demo) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Preview mode · tap the room during the dodge cue',
                              style: AppText.body(size: 9.5, color: AppColors.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (paused)
                  Positioned.fill(
                    child: _PauseOverlay(
                      score: game.score,
                      onResume: resume,
                      onRestart: restart,
                      onLeave: leave,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComplete() {
    return Container(
      key: const ValueKey('complete'),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.4),
          radius: 0.9,
          colors: [Color(0xFF0A2E14), AppColors.bgDeepest],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Stack(
              children: [
                const Positioned.fill(child: FloatingSparkles(green: true)),
                Column(
                  children: [
                    const SizedBox(height: 28),
                    Container(
                      width: 92,
                      height: 92,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.green, AppColors.greenLight],
                        ),
                        boxShadow: [
                          BoxShadow(color: AppColors.green.withValues(alpha: 0.38), blurRadius: 42),
                        ],
                      ),
                      child: const Text('🏃', style: TextStyle(fontSize: 46)),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'You Escaped!',
                      style: AppText.heading(
                        size: 36,
                        shadows: [
                          Shadow(color: AppColors.green.withValues(alpha: 0.55), blurRadius: 38),
                        ],
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '“You defeated your homework.\nFor now.”',
                      textAlign: TextAlign.center,
                      style: AppText.body(
                        size: 13,
                        fontStyle: FontStyle.italic,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 22),
                      padding: const EdgeInsets.fromLTRB(20, 17, 20, 15),
                      decoration: _cardDecoration(
                        radius: 20,
                        borderColor: AppColors.green.withValues(alpha: 0.28),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'CHALLENGE COMPLETE',
                            style: AppText.heading(
                              size: 13,
                              color: AppColors.textMuted,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: _Stat(value: '5/5', label: 'Books Dodged', color: AppColors.green)),
                              const _StatDivider(),
                              Expanded(child: _Stat(value: _formatTime(sessionSeconds), label: 'Time', color: AppColors.orange)),
                              const _StatDivider(),
                              const Expanded(child: _Stat(value: '★★★', label: 'Rating', color: AppColors.purpleLight, smallValue: true)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const ProgressSegments(current: 5),
                          const SizedBox(height: 15),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              DefeatedBook(width: 50),
                              SizedBox(width: 6),
                              DefeatedBook(width: 44, bookColor: AppColors.blue, spineColor: AppColors.blueDark),
                              SizedBox(width: 6),
                              DefeatedBook(width: 46, bookColor: AppColors.purple, spineColor: AppColors.purpleDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                      child: Column(
                        children: [
                          _PrimaryButton(
                            key: const Key('back-to-study'),
                            label: '📖  Back to Studying',
                            color: AppColors.green,
                            onPressed: leave,
                          ),
                          const SizedBox(height: 10),
                          _GhostButton(
                            label: 'Another Challenge →',
                            onPressed: leave,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration({double radius = 16, Color? borderColor}) {
    return BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.border),
    );
  }

  static String _formatTime(double seconds) {
    final total = seconds.round();
    final minutes = total ~/ 60;
    final remainder = total % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }
}

class _GameHud extends StatelessWidget {
  const _GameHud({
    required this.score,
    required this.seconds,
    required this.onPause,
    required this.paused,
  });

  final int score;
  final double seconds;
  final VoidCallback onPause;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgDeepest.withValues(alpha: 0.98), AppColors.bgDeepest.withValues(alpha: 0.82)],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SquareButton(
                icon: paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                onPressed: onPause,
              ),
              Column(
                children: [
                  Text(
                    'BOOKS DODGED',
                    style: AppText.heading(
                      size: 12,
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$score',
                          style: AppText.heading(
                            size: 29,
                            color: score >= 4 ? AppColors.green : AppColors.text,
                          ),
                        ),
                        TextSpan(text: ' / 5', style: AppText.heading(size: 18, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: 46,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _ChallengeScreenState._formatTime(seconds),
                  style: AppText.heading(size: 12.5, color: AppColors.orange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressSegments(current: score),
        ],
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({
    required this.score,
    required this.onResume,
    required this.onRestart,
    required this.onLeave,
  });

  final int score;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDeepest.withValues(alpha: 0.78),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 300,
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            const BoxShadow(color: Colors.black54, blurRadius: 70, offset: Offset(0, 24)),
            BoxShadow(color: AppColors.purple.withValues(alpha: 0.14), blurRadius: 28),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⏸', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 4),
            Text('Paused', style: AppText.heading(size: 25)),
            const SizedBox(height: 4),
            Text('The books are waiting...', style: AppText.body(size: 12, color: AppColors.textMuted)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text('Progress', style: AppText.body(size: 11.5, color: AppColors.textMuted)),
                  const SizedBox(width: 12),
                  Expanded(child: ProgressSegments(current: score, height: 6)),
                  const SizedBox(width: 9),
                  Text('$score/5', style: AppText.heading(size: 13, color: AppColors.green)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _PrimaryButton(label: '▶  Resume', color: AppColors.green, onPressed: onResume),
            const SizedBox(height: 9),
            _GhostButton(label: '↺  Restart Challenge', onPressed: onRestart),
            const SizedBox(height: 8),
            _GhostButton(label: '✕  Leave Challenge', color: AppColors.red, onPressed: onLeave),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.purple,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.78)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.34), blurRadius: 24, offset: const Offset(0, 6)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(label, style: AppText.heading(size: 18, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onPressed, this.color = AppColors.textSoft});
  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: const BorderSide(color: AppColors.border, width: 1.4),
          backgroundColor: Colors.white.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppText.body(size: 14, weight: FontWeight.w800),
        ),
        child: Text(label),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 19),
        color: AppColors.textSoft,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.bgCard,
          disabledBackgroundColor: AppColors.bgCard,
          disabledForegroundColor: AppColors.textMuted,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color, this.smallValue = false});
  final String value;
  final String label;
  final Color color;
  final bool smallValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppText.heading(size: smallValue ? 20 : 27, color: color)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: AppText.body(size: 9.5, color: AppColors.textMuted)),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: AppColors.border);
  }
}
