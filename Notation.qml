//==============================================================================
//
// SPDX-License-Identifier: GPL-3.0-only
// MuseScore-CLA-applies
//
// MuseScore
// Kalimba Notation plugin for MuseScore
// Notation.qml
//
// Copyright (c) 2022 Yuichiro Nakata
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License version 3 as
// published by the Free Software Foundation.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//==============================================================================
import QtQuick 2.0

Item {
	function execute() {
		helper.setCurrentScore()

		// check voice range
		var check = checkVoiceRange()
		if (check != "") {
			errorDialog.text = check
			errorDialog.open()
			return false
		}
		
		// add notations
		curScore.startCmd()
		if (cmbExecMode.currentIndex == 0) {
			helper.addNoteNames(cmbScore.currentIndex, cmbPart.currentIndex, cmbStaff.currentIndex, cmbVoice.currentIndex, cmbNotationType.currentIndex, cmbNotationPlacement.currentIndex)
		} else {
			helper.addNoteNamesSelection(cmbNotationType.currentIndex, cmbNotationPlacement.currentIndex)
		}
		curScore.endCmd()
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
