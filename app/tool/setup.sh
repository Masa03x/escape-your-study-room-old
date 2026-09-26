#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v flutter >/dev/null || { echo 'Install Flutter and add it to PATH first.'; exit 1; }
command -v python3 >/dev/null || { echo 'Python 3 is needed to configure the iOS motion description.'; exit 1; }
# Without --overwrite, Flutter preserves the existing feature source and tests.
flutter create --no-pub --platforms=ios,android,web --project-name escape_your_study_room --org com.masa .
python3 - <<'PY'
import plistlib
from pathlib import Path
p = Path('ios/Runner/Info.plist')
data = plistlib.loads(p.read_bytes())
data['NSMotionUsageDescription'] = 'Phone movement is used to control the book-dodging study break.'
p.write_bytes(plistlib.dumps(data, sort_keys=False))
PY
flutter pub get
printf '\nSetup complete. Run: flutter run -d chrome\n'
