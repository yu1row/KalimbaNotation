# musescore.org 公開ページ修正案

対象: https://musescore.org/en/project/kalimba-note-name-notation

編集時はサイト上の **Description（本文）** と **API compatibility**、必要なら **Download** リンク先を更新してください。  
Download は GitHub Releases の最新版（または特定タグ）を指すのがよいです。  
例: `https://github.com/yu1row/KalimbaNotation/releases/latest`

---

## 英語本文案（サイト掲載用・推奨）

```text
This plugin adds kalimba note names (17 or 21 keys) to your MuseScore score.

Supported notation styles:
- Japanese names
- English names
- Numbering

## Which download should I use?

GitHub Releases provide two zip packages. Choose the one that matches your MuseScore version:

- KalimbaNotation-musescore3-v*.zip
  → MuseScore 3.x (also usable on MuseScore 4.0–4.3 / Qt5)
- KalimbaNotation-musescore4-v*.zip
  → MuseScore Studio 4.4 and later (Qt6)

Download: https://github.com/yu1row/KalimbaNotation/releases

## Installation

1. Download the correct zip for your MuseScore version.
2. Extract it and copy the KalimbaNotation folder into your MuseScore Plugins folder.
3. Install the three fonts from KalimbaNotation/fonts/ on your system:
   - KalimbaNotationJ.ttf
   - KalimbaNotationE.ttf
   - KalimbaNotationN.ttf
4. Restart MuseScore (if needed), open Plugin Manager, and enable Kalimba Notation.
5. Run it from the Plugins menu.

Source code: https://github.com/yu1row/KalimbaNotation
```

### メタデータ案

| 項目 | 現状 | 修正案 |
|------|------|--------|
| API compatibility | 3.x のみ | **3.x** と **4.x** の両方（4.4+ は musescore4 パッケージ） |
| Plugin categories | Notes & Rests | 変更なしで可 |
| Code repository | （既存） | `https://github.com/yu1row/KalimbaNotation` |
| Documentation | （空または既存） | README または本ページの Installation 節 |
| License | （既存） | GPL-3.0（リポジトリ LICENSE に準拠） |

> 注: musescore.org の「4.x」チェックが 4.0–4.3 と 4.4+ を区別できない場合でも、本文で zip の選び方を明記すれば利用者は迷いにくくなります。

---

## 英語・短文案（欄が狭い場合）

```text
Adds kalimba note names (Japanese / English / numbers) for 17- or 21-key kalimba.

Two downloads on GitHub Releases:
- musescore3 zip → MuseScore 3.x (and 4.0–4.3)
- musescore4 zip → MuseScore Studio 4.4+

Install the included fonts, then enable the plugin in Plugin Manager.
https://github.com/yu1row/KalimbaNotation/releases
```

---

## 日本語参考訳（サイトが英語のため掲載は英語案を使用）

このプラグインは、楽譜の音符にカリンバ（17鍵 / 21鍵）の音名を追加します。

対応する表記:
- 日本語名
- 英語名
- 番号

### ダウンロードの選び方

GitHub Releases に zip が2種類あります。お使いの MuseScore に合わせて選んでください。

- `KalimbaNotation-musescore3-v*.zip` … MuseScore 3.x（4.0–4.3 / Qt5 でも利用可）
- `KalimbaNotation-musescore4-v*.zip` … MuseScore Studio 4.4 以降（Qt6）

配布元: https://github.com/yu1row/KalimbaNotation/releases

### インストール

1. バージョンに合った zip をダウンロードする  
2. 展開し、`KalimbaNotation` フォルダを Plugins フォルダへコピーする  
3. `KalimbaNotation/fonts/` の3フォントを OS にインストールする  
4. プラグインマネージャーで有効化し、Plugins メニューから実行する  

---

## 現状本文との差分ポイント

| 項目 | 現状 | 修正後 |
|------|------|--------|
| 文法 | "This plugin **add** note names" | "**adds**" |
| 対応バージョン | 3.x のみの印象 | 3.x と 4.4+ を明記し、zip を分ける |
| 入手先 | Download の扱いが不明瞭になりやすい | GitHub Releases の URL とファイル名規則を記載 |
| フォント | 未記載 | 必須の3フォントを明記 |
| インストール手順 | なし | 手順を追加 |
