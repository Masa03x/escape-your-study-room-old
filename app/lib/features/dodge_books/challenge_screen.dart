import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'challenge.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});
  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final game = Challenge();
  final detector = MovementDetector();
  final clock = Stopwatch()..start();
  StreamSubscription<UserAccelerometerEvent>? subscription;
  Timer? sensorTimeout;
  late final Ticker ticker;
  Duration previous = Duration.zero;
  bool demo = true;
  bool connecting = false;
  int sensorGeneration = 0;
  String? sensorError;

  bool get phoneSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ticker = createTicker((time) {
      final seconds = (time - previous).inMicroseconds / 1000000;
      previous = time;
      if (game.phase == ChallengePhase.playing && !connecting) {
        final wasOpen = game.canDodge;
        setState(() => game.tick(seconds.clamp(0, 0.1)));
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
            'Motion data is unavailable. Check motion access in '
            'your phone settings, retry, or return to demo mode.';
      });
    }

    sensorTimeout = Timer(const Duration(seconds: 5), failed);
    try {
      subscription =
          userAccelerometerEventStream(
            samplingPeriod: const Duration(milliseconds: 40),
          ).listen(
            (event) {
              if (!mounted || generation != sensorGeneration) return;
              sensorTimeout?.cancel();
              sensorTimeout = Timer(const Duration(seconds: 5), failed);
              if (connecting) setState(() => connecting = false);
              if (game.phase != ChallengePhase.playing) return;
              // Ignore and reset outside the opportunity; no stale input can score.
              if (!game.canDodge) {
                detector.reset();
                return;
              }
              if (detector.add(event.y, clock.elapsedMicroseconds / 1000000)) {
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

  void attemptDodge() {
    if (connecting) return;
    setState(() => game.dodge());
    if (game.phase == ChallengePhase.complete) stopSensors();
  }

  void start() {
    setState(() {
      sensorError = null;
      game.start();
      connectSensors();
    });
  }

  void pause() {
    stopSensors();
    setState(game.pause);
  }

  void resume() {
    setState(() {
      sensorError = null;
      game.resume();
      connectSensors();
    });
  }

  void leave() {
    stopSensors();
    setState(() {
      game.phase = ChallengePhase.ready;
      sensorError = null;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed &&
        game.phase == ChallengePhase.playing)
      pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopSensors();
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = game.phase == ChallengePhase.ready;
    final complete = game.phase == ChallengePhase.complete;
    final paused = game.phase == ChallengePhase.paused;
    return PopScope(
      canPop: ready,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) leave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Escape Your Study Room',
            style: TextStyle(fontSize: 18),
          ),
          leading: ready
              ? null
              : IconButton(
                  tooltip: 'Leave challenge',
                  onPressed: leave,
                  icon: const Icon(Icons.close),
                ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ready
                          ? 'YOUR NEXT STUDY BREAK'
                          : complete
                          ? 'BREAK COMPLETE'
                          : 'CHALLENGE 01',
                      style: const TextStyle(
                        color: Color(0xFFB7E58A),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      complete
                          ? 'You escaped the homework!'
                          : 'Dodge the flying books',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (ready) ...[
                      const Text(
                        'Your textbooks have had enough. Dodge five books and take a little movement break.',
                        style: TextStyle(fontSize: 17, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      const _Instruction(
                        number: '1',
                        text: 'Stand with enough space to move comfortably.',
                      ),
                      const _Instruction(
                        number: '2',
                        text: 'For phone mode, hold your phone upright in portrait with both hands at chest height, screen facing you.',
                      ),
                      const _Instruction(
                        number: '3',
                        text: 'When “Dodge now!” appears, lower into a comfortable squat, then stand again. Stop whenever you need.',
                      ),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Demo mode'),
                        subtitle: Text(
                          phoneSupported
                              ? 'Use a button instead of phone movement.'
                              : 'Laptop and simulator preview: use the dodge button.',
                        ),
                        value: demo,
                        onChanged: phoneSupported
                            ? (value) => setState(() => demo = value)
                            : null,
                      ),
                      if (!demo)
                        const Text(
                          'Experimental motion detection. Phone movement does not verify squat technique.',
                          style: TextStyle(color: Colors.amber),
                        ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: start,
                        child: Text(
                          demo ? 'Start demo break' : 'Start movement break',
                        ),
                      ),
                    ] else if (complete) ...[
                      const Icon(
                        Icons.auto_awesome,
                        size: 100,
                        color: Color(0xFFB7E58A),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        demo ? '5 / 5 demo dodges' : '5 / 5 movement dodges',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'The books will recover. Take a breath, put your phone away and continue when you’re ready.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: leave,
                        child: const Text('Finish break'),
                      ),
                    ] else ...[
                      Text(
                        demo
                            ? 'DEMO • button input'
                            : 'PHONE • experimental motion input',
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          '${game.score} / ${Challenge.goal} books dodged',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: game.score / Challenge.goal,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 20),
                      _Room(
                        progress: game.elapsed / Challenge.roundLength,
                        dodged: game.dodged,
                        paused: paused,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        paused
                            ? 'Break paused'
                            : connecting
                            ? 'Connecting to motion sensor…'
                            : game.canDodge
                            ? 'Dodge now!'
                            : game.feedback,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (sensorError != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            sensorError!,
                            style: const TextStyle(color: Colors.amber),
                          ),
                        ),
                      const SizedBox(height: 20),
                      if (demo && !paused)
                        FilledButton.icon(
                          onPressed: game.canDodge ? attemptDodge : null,
                          icon: const Icon(Icons.sports_gymnastics),
                          label: const Text('Demo: dodge book'),
                        ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: paused ? resume : pause,
                        icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                        label: Text(
                          paused ? 'Resume challenge' : 'Pause challenge',
                        ),
                      ),
                      TextButton(
                        onPressed: leave,
                        child: const Text('Leave this break'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Instruction extends StatelessWidget {
  const _Instruction({required this.number, required this.text});
  final String number;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 15, child: Text(number)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 16, height: 1.4)),
        ),
      ],
    ),
  );
}

class _Room extends StatelessWidget {
  const _Room({
    required this.progress,
    required this.dodged,
    required this.paused,
  });
  final double progress;
  final bool dodged;
  final bool paused;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'A book flies across the study room. The character ducks when a dodge counts.',
    child: Container(
      height: 230,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF30434B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            const Positioned(
              left: 22,
              top: 22,
              child: Icon(Icons.window, size: 68, color: Color(0xFF809B9D)),
            ),
            const Positioned(
              right: 20,
              bottom: 35,
              child: Icon(Icons.desk, size: 90, color: Color(0xFFA18E7A)),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(height: 30, color: const Color(0xFF223239)),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              left: 35,
              bottom: dodged ? 18 : 35,
              child: Icon(
                dodged ? Icons.accessibility_new : Icons.person,
                size: dodged ? 58 : 92,
                color: const Color(0xFFB7E58A),
              ),
            ),
            Positioned(
              left: (constraints.maxWidth - 50) * (1 - progress),
              top: 88,
              child: Transform.rotate(
                angle: progress * 5,
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 48,
                  color: Color(0xFFFFCC8A),
                ),
              ),
            ),
            if (paused)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Icon(Icons.pause_circle_outline, size: 70),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
