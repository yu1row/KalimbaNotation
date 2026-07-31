//==============================================================================
//
// SPDX-License-Identifier: GPL-3.0-only
//
// Kalimba Notation plugin (Studio 4.4+) — score helpers
// Helper.qml
//
// Copyright (c) 2022 Yuichiro Nakata
//
// NOTE: This file must NOT contain the substring "Mu" + "seScore".
// Legacy plugin discovery treats any .qml containing that word as a plugin.
// Element / Cursor / Placement enums are injected from the main plugin file.
//
//==============================================================================
import QtQuick

Item {
	// Injected from KalimbaNotation.qml (host plugin enums)
	property var elementTypes
	property var cursorTypes
	property var placementTypes

	property var valid_keys_21 : [53 , 55 , 57 , 59 , 60 , 62 , 64 , 65 , 67 , 69 , 71 , 72 , 74 , 76 , 77 , 79 , 81 , 83 , 84 , 86 , 88]
	property var key_text_21   : ["H", "I", "J", "K", "C", "D", "E", "F", "G", "A", "B", "c", "d", "e", "f", "g", "a", "b", "1", "2", "3"]
	property var font_face     : "KalimbaNotationJ"
	property var font_place    : 1
	// Invisible marker + readable id so we can find/remove later (also match by fontFace).
	readonly property string notationTag: "\u200B"          // zero-width space prefix
	readonly property string notationId: "KalimbaNotation"

	// ------------------------------------------------------------
	// [Summary]
	//   Check the host application version
	// [Arguments]
	//   requiredVersion: Required version("x.x.x")
	// [Return]
	//   pass the check: true
	// ------------------------------------------------------------
	function checkHostVersion(requiredVersion) {
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
	//   Check whether a font family is installed on the system
	// ------------------------------------------------------------
	function isFontInstalled(family) {
		try {
			var families = Qt.fontFamilies()
			var target = ("" + family).toLowerCase()
			for (var i = 0; i < families.length; i++) {
				if (("" + families[i]).toLowerCase() === target) {
					return true
				}
			}
		} catch (e) {}
		return false
	}

	function getRequiredKalimbaFonts() {
		return ["KalimbaNotationJ", "KalimbaNotationE", "KalimbaNotationN"]
	}

	function getMissingKalimbaFonts() {
		var required = getRequiredKalimbaFonts()
		var missing = []
		for (var i = 0; i < required.length; i++) {
			if (!isFontInstalled(required[i])) {
				missing.push(required[i])
			}
		}
		return missing
	}

	// Returns warning message, or "" if all fonts are present
	function getMissingFontsMessage() {
		var missing = getMissingKalimbaFonts()
		if (missing.length === 0) {
			return ""
		}
		var list = ""
		for (var i = 0; i < missing.length; i++) {
			list += "• " + missing[i] + "\n"
		}
		return i18n.tr("The following fonts are not installed:\n\n%1\nPlease install them from the plugin's fonts folder (KalimbaNotationJ.ttf / KalimbaNotationE.ttf / KalimbaNotationN.ttf).\n\nIf you have just installed the fonts, restart " + i18n.appName + " and try again.").arg(list)
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
		var mode = cmbExecMode.currentIndex
		// 0: add staff, 1: add range, 2: remove staff, 3: remove range
		grpTargetSettings.visible = (mode === 0 || mode === 2)
		grpBasicSettings.visible = (mode === 0 || mode === 1)
		grpExtendedSettings.visible = (mode === 0 || mode === 1)

		ensureScoreModel()
		refreshPartModel()
		refreshStaffModel()
	}

	function listEquals(a, b) {
		if (!a || !b || a.length !== b.length) {
			return false
		}
		for (var i = 0; i < a.length; i++) {
			if (a[i] !== b[i]) {
				return false
			}
		}
		return true
	}

	function ensureScoreModel() {
		var scoreNames = getScoreNameList()
		if (listEquals(cmbScore.model, scoreNames)) {
			return
		}
		var prevScore = cmbScore.currentIndex
		cmbScore.model = scoreNames
		if (scoreNames.length === 0) {
			cmbScore.currentIndex = -1
		} else if (0 <= prevScore && prevScore < scoreNames.length) {
			cmbScore.currentIndex = prevScore
		} else {
			cmbScore.currentIndex = 0
		}
	}

	function refreshPartModel() {
		var partNames = getPartNameList(cmbScore.currentIndex)
		if (listEquals(cmbPart.model, partNames)) {
			return
		}
		var prevPart = cmbPart.currentIndex
		cmbPart.model = partNames
		if (partNames.length === 0) {
			cmbPart.currentIndex = -1
		} else if (0 <= prevPart && prevPart < partNames.length) {
			cmbPart.currentIndex = prevPart
		} else {
			cmbPart.currentIndex = 0
		}
	}

	function refreshStaffModel() {
		var staves = []
		var nStaves = getStaffCount(cmbScore.currentIndex, cmbPart.currentIndex)
		for (var i = 0; i < nStaves; i++) {
			staves.push(i + 1)
		}
		if (listEquals(cmbStaff.model, staves)) {
			return
		}
		var curStaff = cmbStaff.currentIndex
		cmbStaff.model = staves
		if (0 <= curStaff && curStaff < staves.length) {
			cmbStaff.currentIndex = curStaff
		} else if (staves.length > 0) {
			cmbStaff.currentIndex = 0
		}
	}

	function getOpenScoreCount() {
		try {
			if (typeof scores !== "undefined" && scores && scores.length > 0) {
				return scores.length
			}
		} catch (e) {}
		return curScore ? 1 : 0
	}

	function getScoreAt(index) {
		try {
			if (typeof scores !== "undefined" && scores && scores.length > 0) {
				if (0 <= index && index < scores.length) {
					return scores[index]
				}
				return null
			}
		} catch (e) {}
		return (index === 0) ? curScore : null
	}

	function getScoreNameList() {
		var list = []
		var n = getOpenScoreCount()
		for (var i = 0; i < n; i++) {
			var s = getScoreAt(i)
			var name = ""
			if (s) {
				try { name = s.scoreName } catch (e1) {}
				if (!name) {
					try { name = s.name } catch (e2) {}
				}
			}
			if (!name) {
				name = i18n.tr("Score") + " " + (i + 1)
			}
			list.push(name)
		}
		return list
	}

	function getPartNameList(scoreIndex) {
		var list = []
		var score = getScoreAt(scoreIndex)
		if (!score) {
			return list
		}
		try {
			var parts = score.parts
			if (!parts) {
				return list
			}
			for (var i = 0; i < parts.length; i++) {
				var p = parts[i]
				var name = ""
				try { name = p.longName } catch (e1) {}
				if (!name) {
					try { name = p.partName } catch (e2) {}
				}
				if (!name) {
					try { name = p.shortName } catch (e3) {}
				}
				if (!name) {
					name = i18n.tr("Part") + " " + (i + 1)
				}
				list.push(name)
			}
		} catch (e) {}
		return list
	}

	function selectCurrentScoreInCombo() {
		var names = getScoreNameList()
		cmbScore.model = names
		var idx = 0
		try {
			if (typeof scores !== "undefined" && scores && curScore) {
				idx = getIndexByValue(scores, curScore)
				if (idx < 0) {
					idx = 0
				}
			}
		} catch (e) {
			idx = 0
		}
		if (names.length > 0) {
			cmbScore.currentIndex = Math.min(idx, names.length - 1)
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
	//   Resolve the score object selected in the UI (no score switching).
	// ------------------------------------------------------------
	function resolveTargetScore() {
		var mode = cmbExecMode.currentIndex
		// Selection-based modes use the current score
		if (mode === 1 || mode === 3) {
			return curScore
		}
		var score = getScoreAt(cmbScore.currentIndex)
		return score ? score : curScore
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Kept for API compatibility. MS4 dialogs must not call next-score.
	// ------------------------------------------------------------
	function setCurrentScore() {
		// Studio 4.x: cmd("next-score") + Score.is() can hang forever.
		// Callers should use resolveTargetScore() and score.startCmd/endCmd.
		return
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Voice combo: 0 = all voices, 1..4 = voice 1..4 → host voice 0..3
	// ------------------------------------------------------------
	function getSelectedVoiceIndices(voiceComboIndex) {
		var idx = (voiceComboIndex !== undefined) ? voiceComboIndex : cmbVoice.currentIndex
		if (idx <= 0) {
			return [0, 1, 2, 3]
		}
		return [idx - 1]
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Check voice range
	// [Arguments]
	//   scoreIndex: Index of target score
	//   partIndex : Index of target part
	//   staffIndex: Index of staff in the part(usually may be 0 or 1)
	//   voiceComboIndex: Combo index (0 = all, 1..4 = voice)
	//   is17keys  : 17 keys kalimba = true, 21 keys kalimba = false
	// [Return]
	//   error message or empty string
	// ------------------------------------------------------------
	function checkValidVoiceRange(scoreIndex, partIndex, staffIndex, voiceComboIndex, is17keys) {
		var score = getScoreAt(scoreIndex)
		if (!score) {
			return ""
		}
		var voices = getSelectedVoiceIndices(voiceComboIndex)
		var staffIdx = getStaffIndexInAllStaves(scoreIndex, partIndex, staffIndex)
		var cursor = score.newCursor()
		cursor.filter = Segment.All
		cursor.staffIdx = staffIdx

		for (var v = 0; v < voices.length; v++) {
			cursor.voice = voices[v]
			cursor.rewind(cursorTypes.SCORE_START)
			var guard = 0
			while (cursor.segment && guard < 100000) {
				guard++
				var e = cursor.element
				if (checkValidVoiceRangeSub(e, is17keys, false) == false) {
					return i18n.tr("There was a note out of range\n(Measure = %1)").arg(getMeasureNumber(score, cursor.measure))
				}
				if (!cursor.next()) {
					break
				}
			}
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
		if (!score) {
			return ""
		}
		var cursor = score.newCursor()
		cursor.filter = Segment.All

		for (var nStaff = 0; nStaff < score.nstaves; nStaff++) {
			for (var nVoice = 0; nVoice < 4; nVoice++) {
				cursor.staffIdx = nStaff
				cursor.voice = nVoice
				cursor.rewind(cursorTypes.SCORE_START)
				var guard = 0
				while (cursor.segment && guard < 100000) {
					guard++
					var e = cursor.element
					if (checkValidVoiceRangeSub(e, is17keys, true) == false) {
						return i18n.tr("There was a note out of range\n(Measure = %1)").arg(getMeasureNumber(score, cursor.measure))
					}
					if (!cursor.next()) {
						break
					}
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
		if (e && e.type == elementTypes.CHORD) {
			if (e.type == elementTypes.CHORD && 0 < e.notes.length) {
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
			case 0: font_place = placementTypes.BELOW; break;
			case 1: font_place = placementTypes.ABOVE; break;
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
	function addNoteNames(scoreIndex, partIndex, staffIndex, voiceComboIndex, fontFaceIndex, fontPlaceIndex) {
		setFontSettings(fontFaceIndex, fontPlaceIndex)
		var score = getScoreAt(scoreIndex)
		if (!score) {
			return
		}
		removeBeforeAddIfNeeded(scoreIndex, partIndex, staffIndex, voiceComboIndex, false)
		var staffIdx = getStaffIndexInAllStaves(scoreIndex, partIndex, staffIndex)
		var voices = getSelectedVoiceIndices(voiceComboIndex)
		var cursor = score.newCursor()
		cursor.filter = Segment.All
		cursor.staffIdx = staffIdx

		var pending = []
		for (var v = 0; v < voices.length; v++) {
			cursor.voice = voices[v]
			cursor.rewind(cursorTypes.SCORE_START)
			var guard = 0
			while (cursor.segment && guard < 100000) {
				guard++
				var text = getNoteText(cursor.element, false)
				if (text) {
					pending.push({ voice: voices[v], tick: cursor.tick, text: text })
				}
				if (!cursor.next()) {
					break
				}
			}
		}

		for (var i = 0; i < pending.length; i++) {
			cursor.voice = pending[i].voice
			cursor.rewindToTick(pending[i].tick)
			cursor.add(pending[i].text)
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
		if (!score) {
			return
		}
		removeBeforeAddIfNeeded(0, 0, 0, 0, true)
		var cursor = score.newCursor()
		cursor.filter = Segment.All

		var pending = []
		for (var nStaff = 0; nStaff < score.nstaves; nStaff++) {
			for (var nVoice = 0; nVoice < 4; nVoice++) {
				cursor.staffIdx = nStaff
				cursor.voice = nVoice
				cursor.rewind(cursorTypes.SCORE_START)
				var guard = 0
				while (cursor.segment && guard < 100000) {
					guard++
					var text = getNoteText(cursor.element, true)
					if (text) {
						pending.push({
							staffIdx: nStaff,
							voice: nVoice,
							tick: cursor.tick,
							text: text
						})
					}
					if (!cursor.next()) {
						break
					}
				}
			}
		}

		for (var i = 0; i < pending.length; i++) {
			cursor.staffIdx = pending[i].staffIdx
			cursor.voice = pending[i].voice
			cursor.rewindToTick(pending[i].tick)
			cursor.add(pending[i].text)
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
		if (e && e.type == elementTypes.CHORD) {
			if (e.type == elementTypes.CHORD && 0 < e.notes.length) {
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
			var text = newElement(elementTypes.STAFF_TEXT)
			text.fontFace = font_face
			text.placement = font_place
			// Tag: ZWSP prefix + fontFace identify our notations for deletion
			text.text = notationTag + noteText
			try { text.autoplace = true } catch (e1) {}
			return text
		} else {
			return null
		}
	}

	function isKalimbaNotationText(el) {
		if (!el) {
			return false
		}
		try {
			if (el.type != elementTypes.STAFF_TEXT) {
				return false
			}
		} catch (e0) {
			return false
		}

		var face = ""
		try { face = el.fontFace } catch (e1) {}
		if (face === "KalimbaNotationJ" || face === "KalimbaNotationE" || face === "KalimbaNotationN") {
			return true
		}

		var t = ""
		try { t = el.text } catch (e2) {}
		if (!t) {
			return false
		}
		// Tagged (ZWSP prefix) or legacy plain kalimba glyph-only texts are handled via fontFace above
		return t.indexOf(notationTag) === 0
	}

	function collectKalimbaTextsFromSegment(segment, staffIdx) {
		var found = []
		if (!segment) {
			return found
		}
		var annotations = null
		try { annotations = segment.annotations } catch (e) { return found }
		if (!annotations) {
			return found
		}
		for (var i = 0; i < annotations.length; i++) {
			var el = annotations[i]
			if (!isKalimbaNotationText(el)) {
				continue
			}
			if (staffIdx >= 0) {
				try {
					var track = el.track
					if (typeof track === "number" && Math.floor(track / 4) !== staffIdx) {
						continue
					}
				} catch (e2) {}
			}
			found.push(el)
		}
		return found
	}

	function removeNoteNames(scoreIndex, partIndex, staffIndex, voiceComboIndex) {
		var score = getScoreAt(scoreIndex)
		if (!score) {
			return 0
		}
		var staffIdx = getStaffIndexInAllStaves(scoreIndex, partIndex, staffIndex)
		var voices = getSelectedVoiceIndices(voiceComboIndex)
		var cursor = score.newCursor()
		cursor.filter = Segment.All
		cursor.staffIdx = staffIdx

		var toRemove = []
		for (var v = 0; v < voices.length; v++) {
			cursor.voice = voices[v]
			cursor.rewind(cursorTypes.SCORE_START)
			var guard = 0
			while (cursor.segment && guard < 100000) {
				guard++
				var found = collectKalimbaTextsFromSegment(cursor.segment, staffIdx)
				for (var i = 0; i < found.length; i++) {
					toRemove.push(found[i])
				}
				if (!cursor.next()) {
					break
				}
			}
		}

		// Deduplicate
		var unique = []
		for (var a = 0; a < toRemove.length; a++) {
			var exists = false
			for (var b = 0; b < unique.length; b++) {
				try {
					if (unique[b].is(toRemove[a])) {
						exists = true
						break
					}
				} catch (e4) {
					if (unique[b] === toRemove[a]) {
						exists = true
						break
					}
				}
			}
			if (!exists) {
				unique.push(toRemove[a])
			}
		}

		for (var j = 0; j < unique.length; j++) {
			removeElement(unique[j])
		}
		return unique.length
	}

	function removeNoteNamesSelection() {
		var score = curScore
		if (!score) {
			return 0
		}
		var cursor = score.newCursor()
		cursor.filter = Segment.All
		var toRemove = []

		for (var nStaff = 0; nStaff < score.nstaves; nStaff++) {
			for (var nVoice = 0; nVoice < 4; nVoice++) {
				cursor.staffIdx = nStaff
				cursor.voice = nVoice
				cursor.rewind(cursorTypes.SCORE_START)
				var guard = 0
				while (cursor.segment && guard < 100000) {
					guard++
					// Remove tagged texts in segments that contain a selected note
					var hasSelectedNote = false
					var e = cursor.element
					if (e && e.type == elementTypes.CHORD && e.notes) {
						for (var ni = 0; ni < e.notes.length; ni++) {
							if (e.notes[ni].selected) {
								hasSelectedNote = true
								break
							}
						}
					}
					if (hasSelectedNote) {
						var found = collectKalimbaTextsFromSegment(cursor.segment, nStaff)
						for (var i = 0; i < found.length; i++) {
							toRemove.push(found[i])
						}
					}
					if (!cursor.next()) {
						break
					}
				}
			}
		}

		// Deduplicate by object identity
		var unique = []
		for (var a = 0; a < toRemove.length; a++) {
			var exists = false
			for (var b = 0; b < unique.length; b++) {
				try {
					if (unique[b].is(toRemove[a])) {
						exists = true
						break
					}
				} catch (e4) {
					if (unique[b] === toRemove[a]) {
						exists = true
						break
					}
				}
			}
			if (!exists) {
				unique.push(toRemove[a])
			}
		}

		for (var j = 0; j < unique.length; j++) {
			removeElement(unique[j])
		}
		return unique.length
	}

	function removeBeforeAddIfNeeded(scoreIndex, partIndex, staffIndex, voiceIndex, selectionMode) {
		if (!cbRemoveExisting || !cbRemoveExisting.checked) {
			return
		}
		if (selectionMode) {
			removeNoteNamesSelection()
		} else {
			removeNoteNames(scoreIndex, partIndex, staffIndex, voiceIndex)
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
		var score = getScoreAt(scoreIndex)
		if (!score) {
			return 0
		}
		try {
			var part = score.parts[partIndex]
			if (!part) {
				return score.nstaves || 0
			}
			var cursor = score.newCursor()
			var count = 0
			for (var i = 0; i < score.nstaves; i++) {
				cursor.staffIdx = i
				cursor.rewind(cursorTypes.SCORE_START)
				if (cursor.element && cursor.element.staff && part.is(cursor.element.staff.part)) {
					count++
				}
			}
			return count > 0 ? count : (score.nstaves || 0)
		} catch (e) {
			return score.nstaves || 0
		}
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
		var score = getScoreAt(scoreIndex)
		if (!score) {
			return []
		}
		var cursor = score.newCursor()
		var staves = []
		for (var i = 0; i < score.nstaves; i++) {
			cursor.staffIdx = i
			cursor.rewind(cursorTypes.SCORE_START)
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
		var score = getScoreAt(scoreIndex)
		if (!score) {
			return staffIndex >= 0 ? staffIndex : 0
		}
		try {
			var part = score.parts[partIndex]
			if (!part) {
				return staffIndex >= 0 ? staffIndex : 0
			}
			var cursor = score.newCursor()
			for (var i = 0; i < score.nstaves; i++) {
				cursor.staffIdx = i
				cursor.rewind(cursorTypes.SCORE_START)
				if (cursor.element && cursor.element.staff && part.is(cursor.element.staff.part)) {
					return i + staffIndex
				}
			}
		} catch (e) {}
		return staffIndex >= 0 ? staffIndex : 0
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
			cursor.rewind(cursorTypes.SCORE_START)
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
		if (!score || !measure) {
			return 0
		}
		var cursor = score.newCursor()
		cursor.filter = Segment.All
		cursor.staffIdx = 0
		cursor.voice = 0
		cursor.rewind(cursorTypes.SCORE_START)
		var measureCount = 0
		var guard = 0
		while (cursor.segment && guard < 100000) {
			guard++
			if (measure.is(cursor.measure)) {
				return measureCount + 1
			}
			measureCount++
			if (!cursor.nextMeasure()) {
				break
			}
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
