//==============================================================================
//
// SPDX-License-Identifier: GPL-3.0-only
// MuseScore-CLA-applies
//
// MuseScore
// Kalimba Notation plugin for MuseScore
// KalimbaNotation.qml
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
import QtQuick.Window 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import MuseScore 3.0

MuseScore {
	version:    "1.0.00"
	menuPath:   "Plugins." + i18n.tr("Kalimba Notation")
	description: i18n.tr("This plugin adds named or numbered score for kalimba from notes.")

	// ********************************************************************************
	// External objects
	// ********************************************************************************
	I18n      { id: i18n }
	Settings  { id: settings }
	Helper    { id: helper }
	Notation  { id: notation }
	ScoreView { id: scoreview }

	// ********************************************************************************
	// Events
	// ********************************************************************************
	onRun: {
		var requiredVersion = "3.0.5"
		if (helper.checkMuseScoreVersion(requiredVersion) == false) {
			errorDialog.text = i18n.tr("The version of MuseScore must be %1 or higher.").arg(requiredVersion)
			errorDialog.open()
		} else if (!curScore) {
			Qt.quit()
		} else {
			settings.load()
			window.visible = true
			cmbScore.currentIndex =  helper.getIndexByValue(scores, curScore)
		}
	}

	// ********************************************************************************
	// UI
	// ********************************************************************************
	property int margin: 11
	Window {
		id: window
		title: i18n.tr("Kalimba Notation")
		minimumWidth:  mainLayout.implicitWidth  + 2 * margin
		minimumHeight: mainLayout.implicitHeight + 2 * margin
		maximumWidth:  mainLayout.implicitWidth  + 2 * margin
		maximumHeight: mainLayout.implicitHeight + 2 * margin
		flags: Qt.Dialog
		modality: Qt.ApplicationModal
		ColumnLayout {
			id: mainLayout
			anchors.fill: parent
			anchors.margins: margin

			// === Mode ===
			GroupBox {
				title: i18n.tr("Execution mode")
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignLeft | Qt.AlignTop
				flat: true
				ComboBox {
					id: cmbExecMode
					Layout.fillWidth: true
					anchors.left: parent.left
					anchors.right: parent.right
					model: [
						i18n.tr("Add notations for selected staff"),
						i18n.tr("Add notations for selected range")
					]
					onCurrentIndexChanged: { helper.refreshWindow() }
				}
			}

			// === Target ===
			GroupBox {
				id: grpTargetSettings
				title: i18n.tr("Target settings")

				Layout.fillWidth: true
				GridLayout {
					columns: 2
					anchors.fill: parent
					
					// === Score ===
					GroupBox {
						id: grpscore
						title: i18n.tr("Score")
						Layout.fillWidth: true
						flat: true
						ComboBox {
							id: cmbScore
							Layout.fillWidth: true
							anchors.left: parent.left
							anchors.right: parent.right
							model: scores
							textRole: "scoreName"
						}
					}

					// === Part ===
					GroupBox {
						title: i18n.tr("Part")
						Layout.fillWidth: true
						flat: true
						ComboBox {
							id: cmbPart
							Layout.fillWidth: true
							anchors.left: parent.left
							anchors.right: parent.right
							model: scores[cmbScore.currentIndex].parts
							textRole: "longName"
							onCurrentIndexChanged: { helper.refreshWindow() }
						}
					}

					// === Staff ===
					GroupBox {
						title: i18n.tr("Staff")
						Layout.fillWidth: true
						flat: true
						ComboBox {
							id: cmbStaff
							Layout.fillWidth: true
							anchors.left: parent.left
							anchors.right: parent.right
						}
					}

					// === Voice ===
					GroupBox {
						title: i18n.tr("Voice")
						Layout.fillWidth: true
						flat: true
						ComboBox {
							id: cmbVoice
							Layout.fillWidth: true
							anchors.left: parent.left
							anchors.right: parent.right
							model: [1, 2, 3, 4]
						}
					}
				}
			}

			// === BASIC SETTIONGS ===
			GroupBox {
				id: grpBasicSettings
				title: i18n.tr("Basic settings")
				Layout.fillWidth: true

				GridLayout {
					columns: 2
					anchors.fill: parent
					
					// === Keys ===
					GroupBox {
						title: i18n.tr("Keys")
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignLeft | Qt.AlignTop
						flat: true
						ComboBox {
							id: cmbKeys
							Layout.fillWidth: true
							anchors.left: parent.left
							anchors.right: parent.right
							model: [
								i18n.tr("17 keys"),
								i18n.tr("21 keys")
							]
							onCurrentIndexChanged: { helper.refreshWindow() }
						}
					}

					// === Notation type ===
					GroupBox {
						title: i18n.tr("Notation type")
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignLeft | Qt.AlignTop
						flat: true
						ComboBox {
							id: cmbNotationType
							Layout.fillWidth: true
							anchors.left: parent.left
							anchors.right: parent.right
							model: [
								i18n.tr("Japanese name"),
								i18n.tr("English name"),
								i18n.tr("Number")
							]
							onCurrentIndexChanged: { helper.refreshWindow() }
						}
					}

					// === Notation placement ===
					GroupBox {
						title: i18n.tr("Notation placement")
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignLeft | Qt.AlignTop
						flat: true
						ComboBox {
							id: cmbNotationPlacement
							Layout.fillWidth: true
							anchors.left: parent.left
							anchors.right: parent.right
							model: [
								i18n.tr("Below"),
								i18n.tr("Above")
							]
						}
					}
				}
			}

			// === EXTENDED SETTIONGS ===
			GroupBox {
				title: i18n.tr("Extended settings")
				Layout.fillWidth: true
				anchors.top: grpBasicSettings.bottom

				ColumnLayout {
					anchors.fill: parent

					// === Check voice range ===
					CheckBox { id: cbCheckVoiceRange; text: i18n.tr("Check voice range(failed to stop)") }
				}
			}
			TextArea {
				id: txtDebug
				visible: false
			}

			// === BUTTONS on Bottom footer ===
			GridLayout {
				anchors.left: parent.left
				anchors.right: parent.right
				columns: 2
				RowLayout {
					Button { id: defaultButton; text: i18n.tr("Default", "button"); onClicked: { settings.reset(); settings.load(); helper.refreshWindow() } }
					Button { id: debugButton; text: "Debug";  onClicked: { helper.debug() }
						visible: false
					}
				}
				RowLayout {
					anchors.right: parent.right
					Button { id: closeButton; text: i18n.tr("Cancel", "button"); onClicked: { window.close(); Qt.quit() } }
					Button { id: okButton;    text: i18n.tr("OK", "button");     onClicked: { notation.execute(); settings.save(); /*window.close(); Qt.quit()*/ } }
				}
			}
		}

		MessageDialog {
			id: errorDialog
			icon: StandardIcon.Warning
			modality: Qt.WindowModal
			standardButtons: StandardButton.Ok
			title: i18n.tr("Error")
			text: ""
			onAccepted: { errorDialog.visible = false }
			visible: false
		}
	}
}
