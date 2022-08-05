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
	menuPath:   "Plugins." + qsTr("Kalimba Notation")
	description: qsTr("This plugin adds named or numbered score for kalimba from notes.")

	// ********************************************************************************
	// External objects
	// ********************************************************************************
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
			errorDialog.text = qsTr("The version of MuseScore must be %1 or higher.").arg(requiredVersion)
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
		title: qsTr("Kalimba Notation")
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
				title: qsTr("Execution mode")
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignLeft | Qt.AlignTop
				flat: true
				ComboBox {
					id: cmbExecMode
					Layout.fillWidth: true
					anchors.left: parent.left
					anchors.right: parent.right
					model: [
						qsTr("Add notations for selected staff"),
						qsTr("Add notations for selected range")
					]
					onCurrentIndexChanged: { helper.refreshWindow() }
				}
			}

			// === Target ===
			GroupBox {
				id: grpTargetSettings
				title: qsTr("Target settings")

				Layout.fillWidth: true
				GridLayout {
					columns: 2
					anchors.fill: parent
					
					// === Score ===
					GroupBox {
						id: grpscore
						title: qsTr("Score")
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
						title: qsTr("Part")
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
						title: qsTr("Staff")
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
						title: qsTr("Voice")
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
				title: qsTr("Basic settings")
				Layout.fillWidth: true

				GridLayout {
					columns: 2
					anchors.fill: parent
					
					// === Keys ===
					GroupBox {
						title: qsTr("Keys")
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignLeft | Qt.AlignTop
						flat: true
						ComboBox {
							id: cmbKeys
							Layout.fillWidth: true
							anchors.left: parent.left
							anchors.right: parent.right
							model: [
								qsTr("17 keys"),
								qsTr("21 keys")
							]
							onCurrentIndexChanged: { helper.refreshWindow() }
						}
					}

					// === Notation type ===
					GroupBox {
						title: qsTr("Notation type")
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignLeft | Qt.AlignTop
						flat: true
						ComboBox {
							id: cmbNotationType
							Layout.fillWidth: true
							anchors.left: parent.left
							anchors.right: parent.right
							model: [
								qsTr("Japanese name"),
								qsTr("English name"),
								qsTr("Number")
							]
							onCurrentIndexChanged: { helper.refreshWindow() }
						}
					}

					// === Notation placement ===
					GroupBox {
						title: qsTr("Notation placement")
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignLeft | Qt.AlignTop
						flat: true
						ComboBox {
							id: cmbNotationPlacement
							Layout.fillWidth: true
							anchors.left: parent.left
							anchors.right: parent.right
							model: [
								qsTr("Below"),
								qsTr("Above")
							]
						}
					}
				}
			}

			// === EXTENDED SETTIONGS ===
			GroupBox {
				title: qsTr("Extended settings")
				Layout.fillWidth: true
				anchors.top: grpBasicSettings.bottom

				ColumnLayout {
					anchors.fill: parent

					// === Check voice range ===
					CheckBox { id: cbCheckVoiceRange; text: qsTr("Check voice range(failed to stop)") }
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
					Button { id: defaultButton; text: qsTr("Default", "button"); onClicked: { settings.reset(); settings.load(); helper.refreshWindow() } }
					Button { id: debugButton; text: "Debug";  onClicked: { helper.debug() }
						visible: false
					}
				}
				RowLayout {
					anchors.right: parent.right
					Button { id: closeButton; text: qsTr("Cancel", "button"); onClicked: { window.close(); Qt.quit() } }
					Button { id: okButton;    text: qsTr("OK", "button");     onClicked: { notation.execute(); settings.save(); /*window.close(); Qt.quit()*/ } }
				}
			}
		}

		MessageDialog {
			id: errorDialog
			icon: StandardIcon.Warning
			modality: Qt.WindowModal
			standardButtons: StandardButton.Ok
			title: qsTr("Error")
			text: ""
			onAccepted: { errorDialog.visible = false }
			visible: false
		}
	}
}
