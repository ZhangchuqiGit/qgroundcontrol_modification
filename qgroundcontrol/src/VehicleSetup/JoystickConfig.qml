//SetupView.qml : 游戏手柄

import QtQuick                      2.11
import QtQuick.Controls             2.4
import QtQuick.Dialogs              1.3
import QtQuick.Layouts              1.11

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0

/// Joystick Config
SetupPage {
	id:                 joystickPage
	pageComponent:      pageComponent
	pageName:           qsTr("Joystick")// 游戏手柄
	pageDescription:    "" // qsTr("Joystick Setup is used to configure and calibrate joysticks.")

	readonly property real  _maxButtons:         64
	readonly property real  _attitudeLabelWidth: ScreenTools.defaultFontPixelWidth * 10

	Connections {
		target: joystickManager
		onAvailableJoysticksChanged: {
			if(joystickManager.joysticks.length === 0) {
				summaryButton.checked = true
				setupView.showSummaryPanel()
			}
		}
	}

	Component {
		id: pageComponent
		Item {
			width:  availableWidth
			height: bar.height + joyLoader.height

			readonly property real  labelToMonitorMargin:   ScreenTools.defaultFontPixelWidth * 3
			property var            _activeJoystick:        joystickManager.activeJoystick

			function setupPageCompleted() {
				controller.start()
			}

			JoystickConfigController {
				id:             controller
			}

			QGCTabBar {
				id:             bar
				width:          parent.width
				Component.onCompleted: {
					currentIndex = _activeJoystick && _activeJoystick.calibrated ? 0 : 2
				}
				anchors.top:    parent.top
				QGCTabButton {
					text:       qsTr("General")
				}
				QGCTabButton {
					text:       qsTr("Button Assigment")
				}
				QGCTabButton {
					text:       qsTr("Calibration")
				}
				QGCTabButton {
					text:       qsTr("Advanced")
				}
			}

			property var pages:  ["JoystickConfigGeneral.qml", "JoystickConfigButtons.qml", "JoystickConfigCalibration.qml", "JoystickConfigAdvanced.qml"]

			Loader {
				id:             joyLoader
				source:         pages[bar.currentIndex]
				width:          parent.width
				anchors.top:    bar.bottom
			}
		}
	}
}


