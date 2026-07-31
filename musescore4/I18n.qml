//==============================================================================
//
// SPDX-License-Identifier: GPL-3.0-only
//
// Kalimba Notation plugin (Studio 4.4+) — translation helper
// I18n.qml
//
// Copyright (c) 2022 Yuichiro Nakata
//
// NOTE: Do not write the host application name as one word in this file.
// Legacy plugin discovery treats any .qml containing that word as a plugin.
// Host app name is built at runtime via appName.
//
//==============================================================================
import QtQuick

/**
 * Studio 4.x currently does NOT load plugin translations/locale_XX.qm
 * (upstream issue #30833). This helper uses qsTr first, then falls
 * back to an embedded Japanese dictionary when the UI language is Japanese.
 */
Item {
	// Split so the source file never contains the discovery trigger word.
	readonly property string appName: "Mu" + "seScore"

	property var ja: buildJa()

	function buildJa() {
		var a = appName
		var o = {
			"Kalimba Notation": "カリンバ音名追加",
			"This plugin adds named or numbered score for kalimba from notes.": "音符に対応するカリンバの音名／数字を追加するプラグイン。",
			"Execution mode": "実行モード",
			"Add notations for selected staff": "選択した譜表に音名を追加",
			"Add notations for selected range": "選択した範囲に音名を追加",
			"Remove notations from selected staff": "選択した譜表の音名を削除",
			"Remove notations from selected range": "選択した範囲の音名を削除",
			"Target settings": "対象設定",
			"Score": "スコア",
			"Part": "パート",
			"Staff": "譜表",
			"Voice": "声部",
			"All voices": "全声部",
			"Basic settings": "基本設定",
			"Keys": "キー",
			"17 keys": "17キー",
			"21 keys": "21キー",
			"Notation type": "音名種別",
			"Japanese name": "日本語名",
			"English name": "英語名",
			"Number": "数字",
			"Notation placement": "音名の位置",
			"Below": "下",
			"Above": "上",
			"Extended settings": "拡張設定",
			"Check voice range(failed to stop)": "音域チェック（失敗時に中止）",
			"Remove existing kalimba notations before adding": "追加前に既存のカリンバ音名を削除する",
			"Remove kalimba notations": "カリンバ音名を削除",
			"No kalimba notations found to remove.": "削除できるカリンバ音名が見つかりませんでした。",
			"Warning": "警告",
			"No score is open. Please open a score and try again.": "スコアが開かれていません。スコアを開いてから再度お試しください。",
			"Default": "初期値",
			"Cancel": "キャンセル",
			"OK": "OK",
			"Error": "エラー",
			"There was a note out of range\n(Measure = %1)": "音域外の音符がありました\n（%1小節目）"
		}
		o["The version of " + a + " must be %1 or higher."] =
			a + " のバージョンは %1 かそれ以上である必要があります。"
		o["The following fonts are not installed:\n\n%1\nPlease install them from the plugin's fonts folder (KalimbaNotationJ.ttf / KalimbaNotationE.ttf / KalimbaNotationN.ttf).\n\nIf you have just installed the fonts, restart " + a + " and try again."] =
			"次のフォントがインストールされていません:\n\n%1\nプラグインの fonts フォルダにある次のファイルを OS にインストールしてください。\n（KalimbaNotationJ.ttf / KalimbaNotationE.ttf / KalimbaNotationN.ttf）\n\nフォントをインストールした直後の場合は、" + a + " を再起動してから再度お試しください。"
		return o
	}

	function isJapanese() {
		try {
			return Qt.locale().name.toLowerCase().indexOf("ja") === 0
		} catch (e) {
			return false
		}
	}

	function tr(source, disambiguation) {
		var result
		if (disambiguation !== undefined && disambiguation !== null && disambiguation !== "") {
			result = qsTr(source, disambiguation)
		} else {
			result = qsTr(source)
		}

		if (result === source && isJapanese() && ja.hasOwnProperty(source)) {
			return ja[source]
		}
		return result
	}
}
