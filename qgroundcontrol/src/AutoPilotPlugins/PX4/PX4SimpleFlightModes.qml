//SetupView.qml : Repeater : model
//	src/AutoPilotPlugins/PX4/PX4AutoPilotPlugin.cc :
//	const QVariantList& PX4AutoPilotPlugin::vehicleComponents(void)
//		src/AutoPilotPlugins/PX4/PX4FlightModes.qml				飞行模式

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0

//import QGroundControl.Zcq_debug     1.0
//Zcq_debug { id : zcq }
//readonly property string zcqfile: " -------- MainRootWindow.qml "

Item {
	id: root
	//property real _margins:  ScreenTools.defaultFontPixelHeight / 2
	property var  _switchNameList: [ "ACRO", "ARM", "GEAR", "KILL", "LOITER",
		"OFFB", "POSCTL", "RATT", "RETURN", "STAB" ]
	property var  _switchFactList:      [ ]
	property var  _switchTHFactList:    [ ]
	//readonly property real _flightModeComboWidth:   ScreenTools.defaultFontPixelWidth * 13
	//readonly property real _channelComboWidth:      ScreenTools.defaultFontPixelWidth * 13

	Component.onCompleted: {
		if (controller.vehicle.fixedWing) {
			_switchNameList.push("MAN")
		}
		if (controller.vehicle.vtol) {
			_switchNameList.push("TRANS")
		}
		for (var i=0; i<_switchNameList.length; i++) {
			_switchFactList.push("RC_MAP_" + _switchNameList[i] + "_SW")
			_switchTHFactList.push("RC_" + _switchNameList[i] + "_TH")
		}
		if (controller.vehicle.fixedWing) {
			_switchFactList.push("RC_MAP_FLAPS")
			_switchTHFactList.push("")
		}
		switchRepeater.model = _switchFactList
	}

	PX4SimpleFlightModesController {        id:         controller    }

	/* Flickable 可闪烁的项目将其子节点放在可拖动和轻弹的表面上，导致对子项的视图滚动。 */
	// Flickable: QGC版本的可闪烁控制，显示水平/垂直滚动指示
	QGCFlickable {
		anchors.margins: 0
		anchors.fill:   parent
		clip:           true
		contentWidth:   column2.x + column2.width
		contentHeight:  column0.height
		Column {
			id:         column0
			spacing:    ScreenTools.defaultFontPixelHeight / 2
			QGCButton {
				text: "Use Multi Channel Mode Selection"
				onClicked: {
					controller.getParameterFact(-1, "RC_MAP_MODE_SW").value = 5
					controller.getParameterFact(-1, "RC_MAP_FLTMODE").value = 0
				}
			}
			Row {
				id:         settingsRow
				spacing:    10 // ScreenTools.defaultFontPixelHeight / 2
				Column { // Flight mode settings
					id:     flightModeSettingsColumn
					spacing: 0 // ScreenTools.defaultFontPixelHeight / 2
					QGCLabel {
						id:             flightModeLabel
						text:           qsTr("Flight Mode Settings") // 飞行模式设置
						font.family:    ScreenTools.demiboldFontFamily
						verticalAlignment: Text.AlignVCenter
						color:          "deepskyblue" // qgcPal.text
					}
					Rectangle { // Flight Modes
						//id:                 flightModeSettings
						width:              flightModeColumn.width + 8
						height:             flightModeColumn.height + 8
						color:              qgcPal.windowShade // "transparent"
						border.width: 0
						opacity: 1 // 透明度
						radius: 2
						GridLayout {
							id:                 flightModeColumn
							anchors.margins:    0 // ScreenTools.defaultFontPixelWidth
							anchors.centerIn:	parent
							rows:               7
							rowSpacing:         2 // ScreenTools.defaultFontPixelWidth / 2
							columnSpacing:      0
							flow:               GridLayout.TopToBottom
							QGCLabel {
								//id: label_arm
								Layout.minimumWidth: implicitWidth + ScreenTools.defaultFontPixelWidth
								Layout.fillWidth:   true
								Layout.alignment: Qt.AlignVCenter
								//Layout.fillHeight:  true
								text:               qsTr("Mode Channel") // 模式通道
								verticalAlignment: Text.AlignVCenter
							}
							Repeater {
								model:  6
								QGCLabel {
									Layout.minimumWidth: implicitWidth + ScreenTools.defaultFontPixelWidth
									Layout.fillWidth:   true
									Layout.alignment: Qt.AlignVCenter
									//Layout.fillHeight:  true
									text:               qsTr("Flight Mode %1").arg(modelData + 1)
									color: controller.activeFlightMode == index ?
											   "yellow" : qgcPal.text
									verticalAlignment: Text.AlignVCenter
								}
							}
							FactComboBox {
								Layout.minimumWidth: implicitWidth + ScreenTools.defaultFontPixelWidth
								//Layout.minimumHeight: implicitHeight
								Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
								//Layout.fillHeight:  true
								Layout.fillWidth:   true
								fact:               controller.getParameterFact(-1, "RC_MAP_FLTMODE")
								indexModel:         false
								sizeToContents:     true
							}
							Repeater {
								model: 6
								FactComboBox {
									Layout.minimumWidth: implicitWidth + ScreenTools.defaultFontPixelWidth
									//Layout.minimumHeight: implicitHeight
									Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
									//Layout.fillHeight:  true
									Layout.fillWidth:   true
									fact: controller.getParameterFact(-1, "COM_FLTMODE" + (modelData + 1))
									indexModel:         false
									sizeToContents:     true
								}
							}
						}
					} // Rectangle - Flight Modes
				} // Column - Flight mode settings
				Column { // Switch settings
					id:         column2
					spacing:    0 // ScreenTools.defaultFontPixelHeight / 2
					QGCLabel {
						text:           qsTr("Switch Settings") // 开关设置
						font.family:    ScreenTools.demiboldFontFamily
						verticalAlignment: Text.AlignVCenter
						color:          "deepskyblue" // qgcPal.text
					}
					Rectangle {
						id:     switchSettingsRect
						width:  switchSettingsGrid.width + 8
						height: switchSettingsGrid.height + 8
						color:              qgcPal.windowShade // "transparent"
						border.width: 0
						opacity: 1 // 透明度
						radius: 2
						GridLayout {
							id:                 switchSettingsGrid
							anchors.margins:    0 // ScreenTools.defaultFontPixelWidth
							anchors.centerIn:	parent
							columns:            1
							columnSpacing:      0
							rowSpacing:         2
							Repeater {
								id: switchRepeater
								RowLayout {
									spacing:   0 // ScreenTools.defaultFontPixelWidth
									Layout.fillWidth:   true
									property string thFactName: _switchTHFactList[index]
									property bool   thFactExists: thFactName == ""
									property Fact   swFact: controller.getParameterFact(-1, modelData)
									property Fact   thFact: thFactExists ?
																controller.getParameterFact(-1, thFactName) :
																null
									property real   thValue:  thFactExists ? thFact.rawValue : 0.5
									property real   thPWM:    1000 + (1000 * thValue)
									property int    swChannel:  swFact.rawValue - 1
									property bool   swActive:   swChannel < 0 ?
																	false :
																	(thValue >= 0 ?
																		 (controller.rcChannelValues[swChannel] > thPWM) :
																		 (controller.rcChannelValues[swChannel] <= thPWM))
									QGCLabel {
										Layout.minimumWidth: implicitWidth + ScreenTools.defaultFontPixelWidth
										Layout.alignment: Qt.AlignVCenter
										Layout.fillWidth:   true
										text:               swFact.shortDescription
										color:              swActive ? "yellow" : qgcPal.text
										verticalAlignment: Text.AlignVCenter
									}
									FactComboBox {
										// Layout.preferredWidth: _channelComboWidth
										Layout.minimumWidth: implicitWidth + ScreenTools.defaultFontPixelWidth
										Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
										//Layout.fillWidth:   true
										fact:                   swFact
										indexModel:             false
									}
								}
							}
						} // Column
					} // Rectangle

					RCChannelMonitor {
						width:      switchSettingsRect.width
						twoColumn:  true
					}
				} // Column - Switch settings
			} // Row - Settings
		}
	}
}
