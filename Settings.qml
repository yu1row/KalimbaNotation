//==============================================================================
//
// SPDX-License-Identifier: GPL-3.0-only
// MuseScore-CLA-applies
//
// MuseScore
// Kalimba Notation plugin for MuseScore
// Settings.qml
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
import Qt.labs.settings 1.0

Settings {
	category: "KalimbaNotation"

	// ********************************************************************************
	// Properties
	// ********************************************************************************
	property bool initialized
	property int  execModeIndex          : 0
	property int  keysIndex              : 0
	property int  notationTypeIndex      : 0
	property int  notationPlacementIndex : 0
	property bool isCheckVoiceRange      : true

	// ********************************************************************************
	// Functions
	// ********************************************************************************

	// ------------------------------------------------------------
	// [Summary]
	//   Reset all settings
	// ------------------------------------------------------------
	function reset() {
		initialized            = true
		execModeIndex          = 0
		keysIndex              = 0
		notationTypeIndex      = 0
		notationPlacementIndex = 0
		isCheckVoiceRange      = true
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Save the plugin settings
	// ------------------------------------------------------------
	function save() {
		execModeIndex          = cmbExecMode.currentIndex
		keysIndex              = cmbKeys.currentIndex
		notationTypeIndex      = cmbNotationType.currentIndex
		notationPlacementIndex = cmbNotationPlacement.currentIndex
		isCheckVoiceRange      = cbCheckVoiceRange.checked
	}

	// ------------------------------------------------------------
	// [Summary]
	//   Load the plugin settings
	// ------------------------------------------------------------
	function load() {
		if (!initialized) { reset() }
		cmbExecMode.currentIndex          = execModeIndex
		cmbKeys.currentIndex              = keysIndex
		cmbNotationType.currentIndex      = notationTypeIndex
		cmbNotationPlacement.currentIndex = notationPlacementIndex
		cbCheckVoiceRange.checked         = isCheckVoiceRange
	}
}
