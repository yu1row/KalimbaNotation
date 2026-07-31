//==============================================================================
//
// SPDX-License-Identifier: GPL-3.0-only
//
// Kalimba Notation plugin (Studio 4.4+) — execute / remove modes
// Notation.qml
//
// Copyright (c) 2022 Yuichiro Nakata
//
// NOTE: Do not write the host application name as one word in this file.
// Legacy plugin discovery treats any .qml containing that word as a plugin.
//
//==============================================================================
import QtQuick

Item {
	function execute() {
		var mode = cmbExecMode.currentIndex
		var score = helper.resolveTargetScore()
		if (!score) {
			return false
		}

		// Remove modes: 2 = staff, 3 = selection
		if (mode === 2 || mode === 3) {
			score.startCmd(i18n.tr("Remove kalimba notations"))
			try {
				var removed = 0
				if (mode === 2) {
					removed = helper.removeNoteNames(cmbScore.currentIndex, cmbPart.currentIndex, cmbStaff.currentIndex, cmbVoice.currentIndex)
				} else {
					removed = helper.removeNoteNamesSelection()
				}
				score.endCmd()
				if (removed === 0) {
					errorDialog.text = i18n.tr("No kalimba notations found to remove.")
					errorDialog.open()
				}
			} catch (e) {
				score.endCmd(true)
				errorDialog.text = "" + e
				errorDialog.open()
				return false
			}
			return true
		}

		// check voice range (add modes only)
		var check = checkVoiceRange()
		if (check != "") {
			errorDialog.text = check
			errorDialog.open()
			return false
		}

		score.startCmd(i18n.tr("Kalimba Notation"))
		try {
			if (mode === 0) {
				helper.addNoteNames(cmbScore.currentIndex, cmbPart.currentIndex, cmbStaff.currentIndex, cmbVoice.currentIndex, cmbNotationType.currentIndex, cmbNotationPlacement.currentIndex)
			} else {
				helper.addNoteNamesSelection(cmbNotationType.currentIndex, cmbNotationPlacement.currentIndex)
			}
			score.endCmd()
		} catch (e2) {
			score.endCmd(true)
			errorDialog.text = "" + e2
			errorDialog.open()
			return false
		}
		return true
	}

	function checkVoiceRange() {
		if (!cbCheckVoiceRange.checked) {
			return ""
		}

		var is17keys = (cmbKeys.currentIndex == 0)
		var ret = ""
		if (cmbExecMode.currentIndex == 0) {
			ret = helper.checkValidVoiceRange(cmbScore.currentIndex, cmbPart.currentIndex, cmbStaff.currentIndex, cmbVoice.currentIndex, is17keys)
		} else {
			ret = helper.checkValidVoiceRangeSelection(is17keys)
		}

		return ret
	}
}
