# Build two MuseScore plugin zip assets for GitHub Releases.
# Usage:
#   .\scripts\package-release.ps1 [-Version 2.0.0]
param(
    [string]$Version = ""
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

if (-not $Version) {
    try {
        $tag = git describe --tags --abbrev=0 2>$null
        if ($tag) { $Version = $tag -replace '^v', '' }
    } catch {}
}
if (-not $Version) { $Version = "0.0.0-dev" }

$Dist = Join-Path $Root "dist"
$Staging = Join-Path $Dist "staging"
if (Test-Path $Dist) { Remove-Item $Dist -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Staging | Out-Null

function Copy-Fonts([string]$DestPluginRoot) {
    $fonts = Join-Path $DestPluginRoot "fonts"
    New-Item -ItemType Directory -Force -Path $fonts | Out-Null
    Copy-Item (Join-Path $Root "fonts\KalimbaNotationJ.ttf") $fonts
    Copy-Item (Join-Path $Root "fonts\KalimbaNotationE.ttf") $fonts
    Copy-Item (Join-Path $Root "fonts\KalimbaNotationN.ttf") $fonts
}

function New-ZipFromFolder([string]$SourceParent, [string]$FolderName, [string]$ZipPath) {
    $source = Join-Path $SourceParent $FolderName
    if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
    Compress-Archive -Path $source -DestinationPath $ZipPath -CompressionLevel Optimal
}

# ---- MuseScore 3.x / 4.0–4.3 (Qt5) ----
$Ms3 = Join-Path $Staging "ms3\KalimbaNotation"
New-Item -ItemType Directory -Force -Path (Join-Path $Ms3 "translations") | Out-Null
Copy-Item (Join-Path $Root "KalimbaNotation.qml") $Ms3
Copy-Item (Join-Path $Root "Helper.qml") $Ms3
Copy-Item (Join-Path $Root "Notation.qml") $Ms3
Copy-Item (Join-Path $Root "Settings.qml") $Ms3
Copy-Item (Join-Path $Root "I18n.qml") $Ms3
Copy-Item (Join-Path $Root "LICENSE") $Ms3
Copy-Item (Join-Path $Root "translations\locale_ja.qm") (Join-Path $Ms3 "translations")
Copy-Item (Join-Path $Root "translations\locale_ja.ts") (Join-Path $Ms3 "translations")
Copy-Fonts $Ms3
@"
KalimbaNotation for MuseScore 3.x (and 4.0–4.3 / Qt5)
Version: $Version

1. Copy this KalimbaNotation folder into your MuseScore Plugins folder.
2. Install the three fonts in the fonts/ folder (system-wide).
3. Enable the plugin in Plugin Manager.
"@ | Set-Content -Path (Join-Path $Ms3 "INSTALL.txt") -Encoding UTF8

# ---- MuseScore Studio 4.4+ (Qt6) ----
$Ms4 = Join-Path $Staging "ms4\KalimbaNotation"
New-Item -ItemType Directory -Force -Path (Join-Path $Ms4 "translations") | Out-Null
Copy-Item (Join-Path $Root "musescore4\KalimbaNotation.qml") $Ms4
Copy-Item (Join-Path $Root "musescore4\Helper.qml") $Ms4
Copy-Item (Join-Path $Root "musescore4\Notation.qml") $Ms4
Copy-Item (Join-Path $Root "musescore4\KalimbaSettings.qml") $Ms4
Copy-Item (Join-Path $Root "musescore4\I18n.qml") $Ms4
Copy-Item (Join-Path $Root "LICENSE") $Ms4
Copy-Item (Join-Path $Root "musescore4\translations\locale_ja.qm") (Join-Path $Ms4 "translations")
Copy-Item (Join-Path $Root "musescore4\translations\locale_ja.ts") (Join-Path $Ms4 "translations")
Copy-Fonts $Ms4
@"
KalimbaNotation for MuseScore Studio 4.4+ (Qt6)
Version: $Version

1. Copy this KalimbaNotation folder into your MuseScore Plugins folder.
2. Install the three fonts in the fonts/ folder (system-wide).
3. Enable "Kalimba Notation" in Plugin Manager.
"@ | Set-Content -Path (Join-Path $Ms4 "INSTALL.txt") -Encoding UTF8

$Zip3 = Join-Path $Dist "KalimbaNotation-musescore3-v$Version.zip"
$Zip4 = Join-Path $Dist "KalimbaNotation-musescore4-v$Version.zip"
New-ZipFromFolder (Join-Path $Staging "ms3") "KalimbaNotation" $Zip3
New-ZipFromFolder (Join-Path $Staging "ms4") "KalimbaNotation" $Zip4

Remove-Item $Staging -Recurse -Force

Write-Host "Created:"
Write-Host "  $Zip3"
Write-Host "  $Zip4"
