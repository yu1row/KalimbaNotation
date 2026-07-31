//==============================================================================
//
// SPDX-License-Identifier: GPL-3.0-only
// MuseScore-CLA-applies
//
// MuseScore
// Kalimba Notation plugin for MuseScore Studio 4.4+
// KalimbaNotation.qml
//
// Copyright (c) 2022 Yuichiro Nakata
//
//==============================================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import MuseScore 3.0

MuseScore {
	id: root
	version: "2.0.00"
	description: "This plugin adds named or numbered score for kalimba from notes."
	title: "Kalimba Notation"
	categoryCode: "composing-arranging-tools"
	pluginType: "dialog"
	// false: closing all scores must not tear down the dialog in a way that exits the app
	requiresScore: false

	property int margin: 12
	property int footerHeight: 48
	// Initial size; kept in sync with the host window on resize
	width: 520
	height: 720

	I18n            { id: i18n }
	KalimbaSettings { id: settings }
	// Persist KalimbaSettings properties (Qt.labs.settings is not available in Studio 4.x).
	Settings {
		category: "KalimbaNotation"
		property alias initialized: settings.initialized
		property alias execModeIndex: settings.execModeIndex
		property alias keysIndex: settings.keysIndex
		property alias notationTypeIndex: settings.notationTypeIndex
		property alias notationPlacementIndex: settings.notationPlacementIndex
		property alias voiceIndex: settings.voiceIndex
		property alias isCheckVoiceRange: settings.isCheckVoiceRange
	}
	Helper {
		id: helper
		// Pass host enums so Helper.qml need not import the MuseScore module
		// (any .qml containing that word is listed as a separate plugin).
		elementTypes: Element
		cursorTypes: Cursor
		placementTypes: Placement
	}
	Notation { id: notation }

	function applyWindowConstraints() {
		// Only touch this plugin dialog — never walk into the host main window.
		function unlockMax(obj) {
			if (!obj)
				return
			try {
				if (obj.minimumWidth !== undefined)
					obj.minimumWidth = 420
				if (obj.minimumHeight !== undefined)
					obj.minimumHeight = 320
				if (obj.maximumWidth !== undefined)
					obj.maximumWidth = 16777215
				if (obj.maximumHeight !== undefined)
					obj.maximumHeight = 16777215
			} catch (e) {}
		}

		unlockMax(root)
		try {
			unlockMax(root.Window.window)
		} catch (e2) {}
	}

	function syncSizeFromWindow() {
		var win = root.Window.window
		if (!win)
			return
		if (win.width > 0)
			root.width = win.width
		if (win.height > 0)
			root.height = win.height
		applyWindowConstraints()
	}

	// Close only this plugin dialog. Use quit() (not Qt.quit()).
	function closePlugin() {
		try {
			quit()
		} catch (e) {
			try {
				var win = root.Window.window
				if (win)
					win.close()
			} catch (e2) {}
		}
	}

	Connections {
		target: root.Window.window
		function onWidthChanged()  { syncSizeFromWindow() }
		function onHeightChanged() { syncSizeFromWindow() }
	}

	Component.onCompleted: {
		title = i18n.tr("Kalimba Notation")
		description = i18n.tr("This plugin adds named or numbered score for kalimba from notes.")
		applyWindowConstraints()
		Qt.callLater(syncSizeFromWindow)
	}

	onRun: {
		var requiredVersion = "4.4.0"

		if (helper.checkHostVersion(requiredVersion) == false) {
			errorDialog.text = i18n.tr("The version of " + i18n.appName + " must be %1 or higher.").arg(requiredVersion)
			errorDialog.open()
		} else if (!curScore) {
			warningDialog.text = i18n.tr("No score is open. Please open a score and try again.")
			warningDialog.open()
		} else {
			settings.load()
			helper.selectCurrentScoreInCombo()
			helper.refreshWindow()
			Qt.callLater(syncSizeFromWindow)

			var fontMsg = helper.getMissingFontsMessage()
			if (fontMsg !== "") {
				warningDialog.text = fontMsg
				Qt.callLater(function() { warningDialog.open() })
			}
		}
	}

	// Full-window shell: body scrolls, footer sticks to bottom
	Item {
		id: frame
		anchors.fill: parent

		ColumnLayout {
			id: shell
			anchors.fill: parent
			anchors.margins: margin
			spacing: 0

			ScrollView {
				id: scroll
				Layout.fillWidth: true
				Layout.fillHeight: true
				clip: true
				ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
				ScrollBar.vertical.policy: ScrollBar.AsNeeded
				contentWidth: availableWidth

				ColumnLayout {
					id: mainLayout
					width: scroll.availableWidth > 0 ? scroll.availableWidth : scroll.width
					spacing: 10

					GroupBox {
						id: gbExecMode
						title: i18n.tr("Execution mode")
						Layout.fillWidth: true
						ComboBox {
							id: cmbExecMode
							width: gbExecMode.availableWidth
							implicitHeight: 36
							model: [
								i18n.tr("Add notations for selected staff"),
								i18n.tr("Add notations for selected range"),
								i18n.tr("Remove notations from selected staff"),
								i18n.tr("Remove notations from selected range")
							]
							onCurrentIndexChanged: { helper.refreshWindow() }
						}
					}

					GroupBox {
						id: grpTargetSettings
						title: i18n.tr("Target settings")
						Layout.fillWidth: true
						GridLayout {
							id: targetGrid
							width: grpTargetSettings.availableWidth
							columns: 2
							columnSpacing: 8
							rowSpacing: 8

							GroupBox {
								id: gbScore
								title: i18n.tr("Score")
								Layout.fillWidth: true
								ComboBox {
									id: cmbScore
									width: gbScore.availableWidth
									implicitHeight: 36
									model: []
									onCurrentIndexChanged: { helper.refreshWindow() }
								}
							}

							GroupBox {
								id: gbPart
								title: i18n.tr("Part")
								Layout.fillWidth: true
								ComboBox {
									id: cmbPart
									width: gbPart.availableWidth
									implicitHeight: 36
									model: []
									onCurrentIndexChanged: { helper.refreshWindow() }
								}
							}

							GroupBox {
								id: gbStaff
								title: i18n.tr("Staff")
								Layout.fillWidth: true
								ComboBox {
									id: cmbStaff
									width: gbStaff.availableWidth
									implicitHeight: 36
								}
							}

							GroupBox {
								id: gbVoice
								title: i18n.tr("Voice")
								Layout.fillWidth: true
								ComboBox {
									id: cmbVoice
									width: gbVoice.availableWidth
									implicitHeight: 36
									model: [
										i18n.tr("All voices"),
										"1",
										"2",
										"3",
										"4"
									]
									currentIndex: 0
								}
							}
						}
					}

					GroupBox {
						id: grpBasicSettings
						title: i18n.tr("Basic settings")
						Layout.fillWidth: true
						GridLayout {
							width: grpBasicSettings.availableWidth
							columns: 2
							columnSpacing: 8
							rowSpacing: 8

							GroupBox {
								id: gbKeys
								title: i18n.tr("Keys")
								Layout.fillWidth: true
								ComboBox {
									id: cmbKeys
									width: gbKeys.availableWidth
									implicitHeight: 36
									model: [
										i18n.tr("17 keys"),
										i18n.tr("21 keys")
									]
								}
							}

							GroupBox {
								id: gbNotationType
								title: i18n.tr("Notation type")
								Layout.fillWidth: true
								ComboBox {
									id: cmbNotationType
									width: gbNotationType.availableWidth
									implicitHeight: 36
									model: [
										i18n.tr("Japanese name"),
										i18n.tr("English name"),
										i18n.tr("Number")
									]
								}
							}

							GroupBox {
								id: gbPlacement
								title: i18n.tr("Notation placement")
								Layout.fillWidth: true
								Layout.columnSpan: 2
								ComboBox {
									id: cmbNotationPlacement
									width: gbPlacement.availableWidth
									implicitHeight: 36
									model: [
										i18n.tr("Below"),
										i18n.tr("Above")
									]
								}
							}
						}
					}

					GroupBox {
						id: grpExtendedSettings
						title: i18n.tr("Extended settings")
						Layout.fillWidth: true
						ColumnLayout {
							width: grpExtendedSettings.availableWidth
							spacing: 6
							CheckBox {
								id: cbCheckVoiceRange
								Layout.fillWidth: true
								text: i18n.tr("Check voice range(failed to stop)")
							}
							CheckBox {
								id: cbRemoveExisting
								Layout.fillWidth: true
								text: i18n.tr("Remove existing kalimba notations before adding")
								checked: true
							}
						}
					}

					TextArea {
						id: txtDebug
						visible: false
						Layout.preferredHeight: 0
					}
				}
			}

			// Footer separator + buttons pinned to bottom
			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 1
				Layout.topMargin: 8
				Layout.bottomMargin: 8
				color: "#c8c8c8"
			}

			RowLayout {
				id: footer
				Layout.fillWidth: true
				Layout.preferredHeight: footerHeight
				Layout.minimumHeight: footerHeight
				Layout.maximumHeight: footerHeight
				spacing: 8

				Button {
					id: defaultButton
					text: i18n.tr("Default", "button")
					implicitHeight: 36
					onClicked: {
						settings.reset()
						settings.load()
						helper.refreshWindow()
					}
				}
				Button {
					id: debugButton
					text: "Debug"
					visible: false
					onClicked: { helper.debug() }
				}
				Item { Layout.fillWidth: true }
				Button {
					id: closeButton
					text: i18n.tr("Cancel", "button")
					implicitHeight: 36
					onClicked: { closePlugin() }
				}
				Button {
					id: okButton
					text: i18n.tr("OK", "button")
					implicitHeight: 36
					enabled: curScore !== null
					onClicked: {
						if (!curScore) {
							warningDialog.text = i18n.tr("No score is open. Please open a score and try again.")
							warningDialog.open()
							return
						}
						notation.execute()
						settings.save()
					}
				}
			}
		}
	}

	Dialog {
		id: errorDialog
		title: i18n.tr("Error")
		modal: true
		anchors.centerIn: parent
		standardButtons: Dialog.Ok
		property alias text: errorLabel.text

		Label {
			id: errorLabel
			wrapMode: Text.WordWrap
			width: Math.min(400, root.width - 40)
		}

		onAccepted: { errorDialog.close() }
	}

	Dialog {
		id: warningDialog
		title: i18n.tr("Warning")
		modal: true
		anchors.centerIn: parent
		standardButtons: Dialog.Ok
		property alias text: warningLabel.text

		Label {
			id: warningLabel
			wrapMode: Text.WordWrap
			width: Math.min(420, root.width - 40)
		}

		onAccepted: { warningDialog.close() }
	}
}
