//==============================================================================
//
// SPDX-License-Identifier: GPL-3.0-only
//
// Kalimba Notation plugin (Studio 4.4+) - settings component
// KalimbaSettings.qml
//
// Copyright (c) 2022 Yuichiro Nakata
//
// NOTE: Do not write the host application name as one word in this file.
// Legacy plugin discovery treats any .qml containing that word as a plugin.
// Persistence is provided by Settings in KalimbaNotation.qml (property aliases).
//
//==============================================================================
import QtQuick

Item {
	property bool initialized
	property int  execModeIndex          : 0
	property int  keysIndex              : 0
	property int  notationTypeIndex      : 0
	property int  notationPlacementIndex : 0
	property int  voiceIndex             : 0
	property bool isCheckVoiceRange      : true

	function reset() {
		initialized            = true
		execModeIndex          = 0
		keysIndex              = 0
		notationTypeIndex      = 0
		notationPlacementIndex = 0
		voiceIndex             = 0
		isCheckVoiceRange      = true
	}

	function save() {
		execModeIndex          = cmbExecMode.currentIndex
		keysIndex              = cmbKeys.currentIndex
		notationTypeIndex      = cmbNotationType.currentIndex
		notationPlacementIndex = cmbNotationPlacement.currentIndex
		voiceIndex             = cmbVoice.currentIndex
		isCheckVoiceRange      = cbCheckVoiceRange.checked
	}

	function load() {
		if (!initialized) { reset() }
		cmbExecMode.currentIndex          = execModeIndex
		cmbKeys.currentIndex              = keysIndex
		cmbNotationType.currentIndex      = notationTypeIndex
		cmbNotationPlacement.currentIndex = notationPlacementIndex
		cmbVoice.currentIndex             = voiceIndex
		cbCheckVoiceRange.checked         = isCheckVoiceRange
	}
}
