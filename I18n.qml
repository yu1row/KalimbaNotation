//==============================================================================
//
// SPDX-License-Identifier: GPL-3.0-only
// MuseScore-CLA-applies
//
// MuseScore
// Kalimba Notation plugin — translation helper
// I18n.qml
//
// Copyright (c) 2022 Yuichiro Nakata
//
//==============================================================================
import QtQuick 2.0

/**
 * MuseScore 3 loads translations/locale_XX.qm automatically.
 * MuseScore 4.x currently does NOT load plugin .qm files
 * (see musescore/MuseScore#30833). This helper uses qsTr first,
 * then falls back to an embedded Japanese dictionary when needed.
 */
Item {
	readonly property var ja: ({
		"Kalimba Notation": "カリンバ音名追加",
		"This plugin adds named or numbered score for kalimba from notes.": "音符に対応するカリンバの音名／数字を追加するプラグイン。",
		"The version of MuseScore must be %1 or higher.": "MuseScore のバージョンは %1 かそれ以上である必要があります。",
		"Execution mode": "実行モード",
		"Add notations for selected staff": "選択した譜表に音名を追加",
		"Add notations for selected range": "選択した範囲に音名を追加",
		"Target settings": "対象設定",
		"Score": "スコア",
		"Part": "パート",
		"Staff": "譜表",
		"Voice": "声部",
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
		"Default": "初期値",
		"Cancel": "キャンセル",
		"OK": "OK",
		"Error": "エラー",
		"There was a note out of range\n(Measure = %1)": "音域外の音符がありました\n（%1小節目）"
	})

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

		// .qm not loaded, or translation missing → use embedded JA dictionary
		if (result === source && isJapanese() && ja.hasOwnProperty(source)) {
			return ja[source]
		}
		return result
	}
}
