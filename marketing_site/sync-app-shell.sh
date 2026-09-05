#!/usr/bin/env bash
# Copies the built Flutter web app into this directory so the "marketing"
# Firebase Hosting target can serve it too (see firebase.json's catch-all
# rewrite to app-shell.html, and the doc comment at the top of index.html).
#
# Run this after `flutter build web --release` and before
# `firebase deploy --only hosting:marketing`. All copied files are
# .gitignore'd here — they're generated, not authored; rerun this script
# instead of committing them.
set -euo pipefail
cd "$(dirname "$0")"

if [ ! -f ../build/web/index.html ]; then
  echo "error: ../build/web/index.html not found — run 'flutter build web --release' first" >&2
  exit 1
fi

cp ../build/web/index.html app-shell.html
for item in main.dart.js flutter.js flutter_bootstrap.js flutter_service_worker.js \
            canvaskit assets manifest.json version.json icons favicon.png social-preview.png; do
  rm -rf "$item"
  cp -r "../build/web/$item" "$item"
done

echo "app-shell.html + Flutter assets synced into marketing_site/"
