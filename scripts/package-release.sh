#!/usr/bin/env bash
# Build two MuseScore plugin zip assets for GitHub Releases.
# Usage:
#   ./scripts/package-release.sh [version]
# Example:
#   ./scripts/package-release.sh 2.0.0
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  VERSION="$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || true)"
fi
if [[ -z "$VERSION" ]]; then
  VERSION="0.0.0-dev"
fi

DIST="$ROOT/dist"
STAGING="$DIST/staging"
rm -rf "$DIST"
mkdir -p "$STAGING"

copy_fonts() {
  local dest="$1/fonts"
  mkdir -p "$dest"
  cp "$ROOT/fonts/KalimbaNotationJ.ttf" "$dest/"
  cp "$ROOT/fonts/KalimbaNotationE.ttf" "$dest/"
  cp "$ROOT/fonts/KalimbaNotationN.ttf" "$dest/"
}

# ---- MuseScore 3.x / 4.0–4.3 (Qt5) ----
MS3="$STAGING/ms3/KalimbaNotation"
mkdir -p "$MS3/translations"
cp "$ROOT/KalimbaNotation.qml" "$MS3/"
cp "$ROOT/Helper.qml" "$MS3/"
cp "$ROOT/Notation.qml" "$MS3/"
cp "$ROOT/Settings.qml" "$MS3/"
cp "$ROOT/I18n.qml" "$MS3/"
cp "$ROOT/LICENSE" "$MS3/"
cp "$ROOT/translations/locale_ja.qm" "$MS3/translations/"
cp "$ROOT/translations/locale_ja.ts" "$MS3/translations/"
copy_fonts "$MS3"
cat > "$MS3/INSTALL.txt" <<EOF
KalimbaNotation for MuseScore 3.x (and 4.0–4.3 / Qt5)
Version: ${VERSION}

1. Copy this KalimbaNotation folder into your MuseScore Plugins folder.
2. Install the three fonts in the fonts/ folder (system-wide).
3. Enable the plugin in Plugin Manager.
EOF

# ---- MuseScore Studio 4.4+ (Qt6) ----
MS4="$STAGING/ms4/KalimbaNotation"
mkdir -p "$MS4/translations"
cp "$ROOT/musescore4/KalimbaNotation.qml" "$MS4/"
cp "$ROOT/musescore4/Helper.qml" "$MS4/"
cp "$ROOT/musescore4/Notation.qml" "$MS4/"
cp "$ROOT/musescore4/KalimbaSettings.qml" "$MS4/"
cp "$ROOT/musescore4/I18n.qml" "$MS4/"
cp "$ROOT/LICENSE" "$MS4/"
cp "$ROOT/musescore4/translations/locale_ja.qm" "$MS4/translations/"
cp "$ROOT/musescore4/translations/locale_ja.ts" "$MS4/translations/"
copy_fonts "$MS4"
cat > "$MS4/INSTALL.txt" <<EOF
KalimbaNotation for MuseScore Studio 4.4+ (Qt6)
Version: ${VERSION}

1. Copy this KalimbaNotation folder into your MuseScore Plugins folder.
2. Install the three fonts in the fonts/ folder (system-wide).
3. Enable "Kalimba Notation" in Plugin Manager.
EOF

ZIP3="$DIST/KalimbaNotation-musescore3-v${VERSION}.zip"
ZIP4="$DIST/KalimbaNotation-musescore4-v${VERSION}.zip"

(
  cd "$STAGING/ms3"
  zip -r "$ZIP3" KalimbaNotation >/dev/null
)
(
  cd "$STAGING/ms4"
  zip -r "$ZIP4" KalimbaNotation >/dev/null
)

rm -rf "$STAGING"

echo "Created:"
echo "  $ZIP3"
echo "  $ZIP4"
