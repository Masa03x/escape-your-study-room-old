import '../lib/features/dodge_books/challenge.dart';
void check(bool value, String message) { if (!value) throw StateError(message); }
void main() {
  final g = Challenge()..start();
  check(!g.dodge(), 'early movement');
  for(var i=0;i<5;i++) {
    g.tick(1.2); check(g.dodge(), 'valid movement');
    check(!g.dodge(), 'double count');
    if(i<4) g.tick(2.8);
  }
  check(g.phase == ChallengePhase.complete && g.score==5,'completion');
  final p=Challenge()..start()..tick(2)..pause(); p.tick(10);
  check(p.elapsed==2 && !p.dodge(),'paused scoring');
  p.resume(); check(p.elapsed==0 && !p.dodge(),'stale resume');
  final d=MovementDetector(); double t=0; int count=0;
  void feed(double y,int n) {for(var i=0;i<n;i++){if(d.add(y,t))count++;t+=0.04;}}
  feed(0,15); feed(-4,10);feed(4,10);check(count==1,'movement pulse');
  feed(4,30);check(count==1,'sustained movement');
  d.reset();feed(4,10);check(count==1,'stale detector');
  print('PASS: scoring, duplicate rejection, completion, pause/resume, motion pulse, sustained input and reset.');
}
