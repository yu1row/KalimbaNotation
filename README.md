# KalimbaNotation

MuseScore の音符にカリンバの音名を追加するプラグインです。

公開ページ: https://musescore.org/en/project/kalimba-note-name-notation  
GitHub Releases: https://github.com/yu1row/KalimbaNotation/releases

## 対応バージョン

| ダウンロード zip | 対応 MuseScore |
|------------------|----------------|
| `KalimbaNotation-musescore3-v*.zip` | MuseScore **3.x**（および 4.0–4.3 / Qt5） |
| `KalimbaNotation-musescore4-v*.zip` | MuseScore Studio **4.4 以降**（Qt6） |

MuseScore 4.4 は Qt 6 移行により `QtQuick.Controls 1` が使えなくなったため、4.4 向けは別パッケージで提供しています。

## ダウンロードとインストール

1. [Releases](https://github.com/yu1row/KalimbaNotation/releases) から、お使いの MuseScore に合った zip を入手する
2. 展開してできた `KalimbaNotation` フォルダを Plugins フォルダへコピーする（上書き更新時は、一覧に不要な旧 `.qml` が残っていれば削除する）
3. `KalimbaNotation/fonts/` 内の次のフォントを OS にインストールする
   - KalimbaNotationJ.ttf
   - KalimbaNotationE.ttf
   - KalimbaNotationN.ttf
4. MuseScore のプラグインマネージャーで **Kalimba Notation** のみを有効にする（Helper / I18n / Notation / KalimbaSettings は内部ファイルで、一覧に出ない想定です）

### 起動

- MuseScore 3.x: `プラグイン` → カリンバ音名追加 / Kalimba Notation
- MuseScore Studio 4.4+: `プラグイン` → Kalimba Notation

## 開発者向け（ソース構成）

| パス | 内容 |
|------|------|
| リポジトリ直下の `.qml` | MuseScore 3.x 向けソース |
| [`musescore4/`](musescore4/) | MuseScore Studio 4.4+ 向けソース |
| [`scripts/package-release.ps1`](scripts/package-release.ps1) / [`scripts/package-release.sh`](scripts/package-release.sh) | リリース用 zip 生成 |

### リリース手順

```bash
# 1. main に変更をマージしたうえでタグを打つ
git tag v2.0.0
git push origin v2.0.0

# 2. GitHub Actions が自動で Release を作成し、次の2ファイルを添付する
#    - KalimbaNotation-musescore3-v2.0.0.zip
#    - KalimbaNotation-musescore4-v2.0.0.zip
```

ローカルで zip だけ作る場合:

```powershell
.\scripts\package-release.ps1 -Version 2.0.0
# → dist/ に2つの zip が出力されます
```

## MuseScore 4.4 向けの主な変更点

- `QtQuick.Controls 2` への移行（Qt 6 対応）
- `pluginType: "dialog"` / `title` / `categoryCode` の追加
- `Qt.labs.settings` の明示 import を削除（MuseScore モジュールの Settings を使用）
- `Qt.quit()` を `quit()` に変更

## 翻訳について

MuseScore 3 は `translations/locale_XX.qm` を自動読み込みしますが、**MuseScore 4.x はプラグインの `.qm` を読み込みません**（[musescore/MuseScore#30833](https://github.com/musescore/MuseScore/issues/30833)）。

そのため本プラグインは `I18n.qml` で、UI 言語が日本語のとき組み込み辞書へフォールバックします。MuseScore の表示言語を日本語にしてからプラグインを開いてください。
