//==============================================================================
//
// SPDX-License-Identifier: GPL-3.0-only
// MuseScore-CLA-applies
//
// MuseScore
// Kalimba Notation plugin for MuseScore
// Helper.qml
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
import MuseScore 3.0

Item {
	property var valid_keys_21 : [53 , 55 , 57 , 59 , 60 , 62 , 64 , 65 , 67 , 69 , 71 , 72 , 74 , 76 , 77 , 79 , 81 , 83 , 84 , 86 , 88]
	property var key_text_21   : ["H", "I", "J", "K", "C", "D", "E", "F", "G", "A", "B", "c", "d", "e", "f", "g", "a", "b", "1", "2", "3"]
	property var font_face     : "KalimbaNotationJ"
	property var font_place    : 1

	// ------------------------------------------------------------
	// [Summary]
	//   Check the version of MuseScore
	// [Arguments]
	//   requiredVersion: Required version("x.x.x")
	// [Return]
	//   pass the check: true
	// ------------------------------------------------------------
	function checkMuseScoreVersion(requiredVersion) {
		var vers = requiredVersion.split(".")
		if (vers.length == 3) {
			var mvers = [mscoreMajorVersion, mscoreMinorVersion, mscoreUpdateVersion]
			for (var i=0; i<vers.length; i++) {
				if (Number(vers[i]) < mvers[i]) { return true  }
				if (Number(vers[i]) > mvers[i]) { return false }
			}
			return true
		}
		return false
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Get index of value in model
	// [Arguments]
	//   model: Search target
	//   value: Search value in model
	// [Return]
	//   index (not found: -1)
	// ------------------------------------------------------------
	function getIndexByValue(model, value) {

		if (typeof value !== "undefined") {
			for (var i=0; i<model.length; i++) {
				if (value.is(curScore) && value.is(model[i])) {
					return i
				} else if (value === model[i]) {
					return i
				}
			}
		}
		return -1
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Returns index of selected radio button
	// [Arguments]
	//   repeat: Repeat component
	// [Return]
	//   index
	// ------------------------------------------------------------
	function getRadioSelectedIndex(repeat) {
		for (var i=0; i<repeat.count; i++) {
			if (repeat.itemAt(i).checked) { return i }
		}
		return -1
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Refresh window according to selection status
	// ------------------------------------------------------------
	function refreshWindow() {
	
		// Update visible for target settings
		grpTargetSettings.visible = (cmbExecMode.currentIndex == 0)

		// Update staves model
		var staves = []
		var nStaves  = getStaffCount(cmbScore.currentIndex, cmbPart.currentIndex)
		var curStaff = cmbStaff.currentIndex
		for (var i=0; i<nStaves; i++) {
			staves.push(i + 1)
		}
		cmbStaff.model = staves
		if (0 <= curStaff && curStaff < staves.length) {
			cmbStaff.currentIndex = curStaff
		}

		// Refresh window size
		if (window.visible) {
			var xtmp = window.x
			window.x = xtmp - 1
			window.x = xtmp
		}
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Conver MIDI note number to note name
	// [Arguments]
	//   number:     MIDI note number
	//   showOctave: Add octave number to note name
	// [Return]
	//   note name
	// ------------------------------------------------------------
	function midiNoteToName(number, showOctave) {
		number -= 21
		var notes = ["A%1", "Bb%1/A#%1", "B%1", "C%1", "Db%1/C#%1", "D%1", "Eb%1/D#%1", "E%1", "F%1", "Gb%1/F#%1", "G%1", "Ab%1/G#%1"]
		var octave = parseInt(number / 12 + 1)
		var name = notes[number % 12]
		return name.arg(showOctave ? octave : "")
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Set the curScore object to selected score
	// ------------------------------------------------------------
	function setCurrentScore() {
		var target = scores[cmbScore.currentIndex]
		while (!curScore.is(target)) {
			cmd("next-score")
		}
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Check voice range
	// [Arguments]
	//   scoreIndex: Index of target score
	//   partIndex : Index of target part
	//   staffIndex: Index of staff in the part(usually may be 0 or 1)
	//   voiceIndex: Index of voice(0 to 3)
	//   is17keys  : 17 keys kalimba = true, 21 keys kalimba = false
	// [Return]
	//   error message or empty string
	// ------------------------------------------------------------
	function checkValidVoiceRange(scoreIndex, partIndex, staffIndex, voiceIndex, is17keys) {
		var score = scores[scoreIndex]
		var part = score.parts[partIndex]
		var tmpSelection = []
		var cursor = score.newCursor()
		cursor.filter = Segment.All
		cursor.staffIdx = getStaffIndexInAllStaves(cmbScore.currentIndex, cmbPart.currentIndex, cmbStaff.currentIndex)
		cursor.voice = voiceIndex
		cursor.rewind(Cursor.SCORE_START)
		while (cursor.segment) {
			var e = cursor.element
			if (checkValidVoiceRangeSub(e, is17keys, false) == false) {
				return qsTr("There was a note out of range\n(Measure = %1)").arg(getMeasureNumber(score, cursor.measure))
			}
			cursor.next()
		}
		return ""
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Check voice range for selection
	// [Arguments]
	//   is17keys : 17 keys kalimba = true, 21 keys kalimba = false
	// [Return]
	//   error message or empty string
	// ------------------------------------------------------------
	function checkValidVoiceRangeSelection(is17keys) {
		var score = curScore
		var cursor = score.newCursor()
		cursor.filter = Segment.All

		for (var nStaff=0; nStaff<score.nstaves; nStaff++) {
			for (var nVoice=0; nVoice<4; nVoice++) {
				cursor.staffIdx = nStaff
				cursor.voice = nVoice
				cursor.rewind(Cursor.SCORE_START)
				while (cursor.segment) {
					var e = cursor.element
					if (checkValidVoiceRangeSub(e, is17keys, true) == false) {
						return qsTr("There was a note out of range\n(Measure = %1)").arg(getMeasureNumber(score, cursor.measure))
					}
					cursor.next()
				}
			}
		}
		return ""
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Sub function for that check voice range
	// [Arguments]
	//   is17keys    : 17 keys kalimba = true, 21 keys kalimba = false
	//   selectedOnly: Ingore not selected
	// [Return]
	//   no error: true
	// ------------------------------------------------------------
	function checkValidVoiceRangeSub(e, is17keys, selectedOnly) {
		if (e && e.type == Element.CHORD) {
			if (e.type == Element.CHORD && 0 < e.notes.length) {
				for (var i in e.notes) {
					var note = e.notes[i]
					if (!selectedOnly || note.selected) {
						var isValid = false
						for (var j=(is17keys ? 4 : 0); j<valid_keys_21.length; j++) {
							if (note.pitch == valid_keys_21[j]) {
								isValid = true
								break
							}
						}
						if (isValid == false) {
							return false
						}
					}
				}
			}
		}
		return true
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Set font options of notations
	// [Arguments]
	//   fontFaceIndex : Index of font face(0 to 2)
	//   fontPlaceIndex: Index of text place(0: below, 1: above)
	//   staffIndex: Index of staff in the part(usually may be 0 or 1)
	// ------------------------------------------------------------
	function setFontSettings(fontFaceIndex, fontPlaceIndex) {
		switch (fontFaceIndex) {
			case 0: font_face = "KalimbaNotationJ"; break;
			case 1: font_face = "KalimbaNotationE"; break;
			case 2: font_face = "KalimbaNotationN"; break;
		}
		switch (fontPlaceIndex) {
			case 0: font_place = 1; break; // below
			case 1: font_place = 0; break; // above
		}
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Add notations
	// [Arguments]
	//   scoreIndex:     Index of target score
	//   partIndex :     Index of target part
	//   staffIndex:     Index of staff in the part(usually may be 0 or 1)
	//   voiceIndex:     Index of voice(0 to 3)
	//   fontFaceIndex:  Index of font face(0 to 2)
	//   fontPlaceIndex: Index of text place(0: below, 1: above)
	// ------------------------------------------------------------
	function addNoteNames(scoreIndex, partIndex, staffIndex, voiceIndex, fontFaceIndex, fontPlaceIndex) {
		setFontSettings(fontFaceIndex, fontPlaceIndex)
		var score = scores[scoreIndex]
		var part = score.parts[partIndex]
		var cursor = score.newCursor()
		cursor.filter = Segment.All
		cursor.staffIdx = getStaffIndexInAllStaves(cmbScore.currentIndex, cmbPart.currentIndex, cmbStaff.currentIndex)
		cursor.voice = voiceIndex
		cursor.rewind(Cursor.SCORE_START)

		while (cursor.segment) {
			var text = getNoteText(cursor.element, false)
			if (text) {
				cursor.add(text)
			}
			cursor.next()
		}
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Add notations for selection
	// [Arguments]
	//   fontFaceIndex:  Index of font face(0 to 2)
	//   fontPlaceIndex: Index of text place(0: below, 1: above)
	// ------------------------------------------------------------
	function addNoteNamesSelection(fontFaceIndex, fontPlaceIndex) {
		setFontSettings(fontFaceIndex, fontPlaceIndex)
		var score = curScore
		var cursor = score.newCursor()
		cursor.filter = Segment.All

		for (var nStaff=0; nStaff<score.nstaves; nStaff++) {
			for (var nVoice=0; nVoice<4; nVoice++) {
				cursor.staffIdx = nStaff
				cursor.voice = nVoice
				cursor.rewind(Cursor.SCORE_START)
				while (cursor.segment) {
					var text = getNoteText(cursor.element, true)
					if (text) {
						cursor.add(text)
					}
					cursor.next()
				}
			}
		}
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Get note text
	// [Arguments]
	//   e           : Target element
	//   selectedOnly: Ingore not selected
	// [Return]
	//   note text or null
	// ------------------------------------------------------------
	function getNoteText(e, selectedOnly) {
		var noteText = ""
		if (e && e.type == Element.CHORD) {
			if (e.type == Element.CHORD && 0 < e.notes.length) {
				for (var i in e.notes) {
					var note = e.notes[i]
					if ((!selectedOnly || note.selected) && !note.tieBack) {
						if (noteText != "") {
							noteText = "\n" + noteText
						}
						noteText = getNoteTextSub(note.pitch) + noteText
					}
				}
			}
		}

		if (noteText != "") {
			var text = newElement(Element.STAFF_TEXT)
			text.fontFace = font_face
			text.placement = font_place
			text.text = noteText
			return text
		} else {
			return null
		}
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Sub function for note text
	// [Arguments]
	//   pitch: MIDI note number
	// [Return]
	//   note text or empty string
	// ------------------------------------------------------------
	function getNoteTextSub(pitch) {
		for (var i in valid_keys_21) {
			if (pitch == valid_keys_21[i]) {
				return key_text_21[i]
			}
		}
		return ""
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Get staves count of the target part
	// [Arguments]
	//   scoreIndex: Index of target score
	//   partIndex : Index of target part
	// [Return]
	//   staves count
	// ------------------------------------------------------------
	function getStaffCount(scoreIndex, partIndex) {
		var score = scores[scoreIndex]
		var part  = score.parts[partIndex]
		var cursor = score.newCursor()
		var count = 0
		for (var i=0; i<score.nstaves; i++) {
			cursor.staffIdx = i
			cursor.rewind(Cursor.SCORE_START)
			if (cursor.element) {
				if (part.is(cursor.element.staff.part)) {
					count++
				}
			}
		}
		return count
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Get staff object array in the target score
	// [Arguments]
	//   scoreIndex: Index of target score
	// [Return]
	//   staff array
	// ------------------------------------------------------------
	function getStaves(scoreIndex) {
		var score = scores[scoreIndex]
		var cursor = score.newCursor()
		var staves = []
		for (var i=0; i<score.nstaves; i++) {
			cursor.staffIdx = i
			cursor.rewind(Cursor.SCORE_START)
			if (cursor.element) {
				staves.push(cursor.element.staff)
			}
		}
		return staves
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Get staff index of all score staves from specified part and index
	// [Arguments]
	//   scoreIndex: Index of target score
	//   partIndex : Index of target part
	//   staffIndex: Index of staff in the part(usually may be 0 or 1)
	// [Return]
	//   staff index of all score staves
	// ------------------------------------------------------------
	function getStaffIndexInAllStaves(scoreIndex, partIndex, staffIndex) {
		var score = scores[scoreIndex]
		var part  = score.parts[partIndex]
		var cursor = score.newCursor()
		for (var i=0; i<score.nstaves; i++) {
			cursor.staffIdx = i
			cursor.rewind(Cursor.SCORE_START)
			if (cursor.element && part.is(cursor.element.staff.part)) {
				return i + staffIndex
			}
		}
		return -1
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Get staff index of all score staves from specified staff object
	// [Arguments]
	//   staff: Target object
	// [Return]
	//   staff index of all score staves
	// ------------------------------------------------------------
	function getStaffIndex(staff) {
		var part = staff.part
		var score = null
		for (var i in scores) {
			var tmpScore = scores[i]
			for (var j in tmpScore.parts) {
				if (part.is(tmpScore.parts[j])) {
					score = tmpScore
					break
				}
			}
			if (score != null) {
				break
			}
		}

		var cursor = score.newCursor()
		for (var i=0; i<score.nstaves; i++) {
			cursor.staffIdx = i
			cursor.rewind(Cursor.SCORE_START)
			if (cursor.element) {
				if (staff.is(cursor.element.staff) && part.is(cursor.element.staff.part)) {
					return i
				}
			}
		}
		return -1
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Get measure number from measure object
	// [Arguments]
	//   score   : Score object
	//   measure : Measure object
	// [Return]
	//   measure number or 0
	// ------------------------------------------------------------
	function getMeasureNumber(score, measure) {
		var cursor = score.newCursor()
		cursor.filter = Segment.All
		cursor.staffIdx = 0
		cursor.voice = 0
		cursor.rewind(Cursor.SCORE_START)
		var measureCount = 0
		while (cursor.segment) {
			if (measure.is(cursor.measure)) {
				return measureCount + 1
			}
			measureCount++
			cursor.nextMeasure()
		}
		return 0
	}

	// ------------------------------------------------------------
	// [Summary]
	//   For debug
	// ------------------------------------------------------------
	function debug() {
		txtDebug.text += "debug\n"
	}
}
