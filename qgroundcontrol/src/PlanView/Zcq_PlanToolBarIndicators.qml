import QtQuick     2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtQuick.Dialogs  1.2

import QGroundControl    1.0
import QGroundControl.ScreenTools  1.0
import QGroundControl.Controls     1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.FlightMap         1.0

//import QGroundControl.Zcq_debug     1.0

Item {
	width: missionStats.width
	height: missionStats.height + zcq_upload_00.height

    property bool _QGCButton: false

	property var    _planMasterController: mainWindow.planMasterControllerPlan
	property var    _currentMissionItem:   mainWindow.currentPlanMissionItem     ///< Mission item to display status for

	property var    missionItems:     _controllerValid ? _planMasterController.missionController.visualItems : undefined
	property real   missionDistance:  _controllerValid ? _planMasterController.missionController.missionDistance : NaN
	property real   missionTime: _controllerValid ? _planMasterController.missionController.missionTime : NaN
	property real   missionMaxTelemetry:   _controllerValid ? _planMasterController.missionController.missionMaxTelemetry : NaN
	property bool   missionDirty:     _controllerValid ? _planMasterController.missionController.dirty : false

	property bool   _controllerValid: _planMasterController !== undefined && _planMasterController !== null
	property bool   _controllerOffline:    _controllerValid ? _planMasterController.offline : true
	property var    _controllerDirty: _controllerValid ? _planMasterController.dirty : false
	property var    _controllerSyncInProgress:  _controllerValid ? _planMasterController.syncInProgress : false

	property bool   _statusValid:     _currentMissionItem !== undefined && _currentMissionItem !== null
	property bool   _missionValid:    missionItems !== undefined

	property real   _labelToValueSpacing:  ScreenTools.defaultFontPixelWidth
	property real   _rowSpacing: ScreenTools.isMobile ? 1 : 0
	property real   _distance:   _statusValid && _currentMissionItem ? _currentMissionItem.distance : NaN
	property real   _altDifference:   _statusValid && _currentMissionItem ? _currentMissionItem.altDifference : NaN
	property real   _gradient:   _statusValid && _currentMissionItem && _currentMissionItem.distance > 0 ?
									 (Math.atan(_currentMissionItem.altDifference / _currentMissionItem.distance) * (180.0/Math.PI)) : NaN
	property real   _azimuth:    _statusValid && _currentMissionItem ? _currentMissionItem.azimuth : NaN
	property real   _heading:    _statusValid && _currentMissionItem ? _currentMissionItem.missionVehicleYaw : NaN
	property real   _missionDistance: _missionValid ? missionDistance : NaN
	property real   _missionMaxTelemetry:  _missionValid ? missionMaxTelemetry : NaN
	property real   _missionTime:     _missionValid ? missionTime : NaN
	property int    _batteryChangePoint:   _controllerValid ? _planMasterController.missionController.batteryChangePoint : -1
	property int    _batteriesRequired:    _controllerValid ? _planMasterController.missionController.batteriesRequired : -1
	property bool   _batteryInfoAvailable: _batteryChangePoint >= 0 || _batteriesRequired >= 0
	property real   _controllerProgressPct:     _controllerValid ? _planMasterController.missionController.progressPct : 0
	property bool   _syncInProgress:  _controllerValid ? _planMasterController.missionController.syncInProgress : false

	property string _distanceText:    isNaN(_distance) ?    "-.-" : QGroundControl.metersToAppSettingsDistanceUnits(_distance).toFixed(1) + " " + QGroundControl.appSettingsDistanceUnitsString
	property string _altDifferenceText:    isNaN(_altDifference) ?    "-.-" : QGroundControl.metersToAppSettingsDistanceUnits(_altDifference).toFixed(1) + " " + QGroundControl.appSettingsDistanceUnitsString
	property string _gradientText:    isNaN(_gradient) ?    "-.-" : _gradient.toFixed(0) + " %"
	property string _azimuthText:     isNaN(_azimuth) ?     "-.-" : Math.round(_azimuth) % 360
	property string _headingText:     isNaN(_azimuth) ?     "-.-" : Math.round(_heading) % 360
	property string _missionDistanceText:  isNaN(_missionDistance) ?
											   "-.-" :  QGroundControl.metersToAppSettingsDistanceUnits(_missionDistance).toFixed(0) + " " + QGroundControl.appSettingsDistanceUnitsString
	property string _missionMaxTelemetryText:   isNaN(_missionMaxTelemetry) ?
													"-.-" : QGroundControl.metersToAppSettingsDistanceUnits(_missionMaxTelemetry).toFixed(0) + " " + QGroundControl.appSettingsDistanceUnitsString
	property string _batteryChangePointText:    _batteryChangePoint < 0 ?  "N/A" : _batteryChangePoint
	property string _batteriesRequiredText:     _batteriesRequired < 0 ?   "N/A" : _batteriesRequired

//	Component.onCompleted: {
//		zcq.echo("Component.onCompleted: {...} ------ Zcq_PlanToolBarIndicators.qml")
//		zcq.echo("height=" + height)
//		zcq.echo("width=" + width)
//		zcq.echo("missionStats.height=" + missionStats.height)
//		zcq.echo("missionStats.width=" + missionStats.width)
//		zcq.echo("zcq_PlanTool_01.height=" + zcq_PlanTool_01.height)
//		zcq.echo("zcq_PlanTool_01.width=" + zcq_PlanTool_01.width)
//		zcq.echo("zcq_PlanTool_02.height=" + zcq_PlanTool_02.height)
//		zcq.echo("zcq_PlanTool_02.width=" + zcq_PlanTool_02.width)
//		zcq.echo("zcq_PlanTool_03.height=" + zcq_PlanTool_03.height)
//		zcq.echo("zcq_PlanTool_03.width=" + zcq_PlanTool_03.width)
//		zcq.echo("zcq_PlanTool_02_time.height=" + zcq_PlanTool_02_time.height)
//		zcq.echo("zcq_PlanTool_02_time.width=" + zcq_PlanTool_02_time.width)
//		zcq.echo("zcq_upload_00.height=" + zcq_upload_00.height)
//		zcq.echo("zcq_upload_00.width=" + zcq_upload_00.width)
//		zcq.echo("largeProgressBar.height=" + progressBar.height)
//		zcq.echo("largeProgressBar.width=" + progressBar.width)
//	}

	function getMissionTime() {
		if(isNaN(_missionTime)) {
            return "00:00:00"
		}
		var t = new Date(0, 0, 0, 0, 0, Number(_missionTime))
		return Qt.formatTime(t, 'hh:mm:ss')
	}
	Timer {
		id:   resetProgressTimer
		interval:  2000
		onTriggered: {
			progressBar.visible = false
		}
	}
	Connections {	// Progress bar
		target: _controllerValid ? _planMasterController.missionController : undefined
		onProgressPctChanged: {
			if (_controllerProgressPct === 1) {
				resetProgressTimer.start()
			} else if (_controllerProgressPct > 0) {
				progressBar.visible = true
			}
		}
	}

	Rectangle {
		id: missionStats
		visible: true
		anchors.top: parent.top
        height: visible ? zcq_PlanTool_02.height : 0
        width: parent.width//zcq_PlanTool_01.width + 8
		color: "black" // "transparent"
		opacity: 0.9 // 透明度
		border.width: 0
		border.color: "red"
		RowLayout {
			id: zcq_PlanTool_01
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.verticalCenter: parent.verticalCenter
			spacing: ScreenTools.defaultFontPointSize
			GridLayout {
				id: zcq_PlanTool_02
				Layout.alignment: Qt.AlignTop
				columns: 2 // 设置列数
				columnSpacing:     0
				rowSpacing:   0
				QGCLabel {
					color:  "orange"
					text:     qsTr("Selected Waypoint")
					font.pointSize: ScreenTools.smallFontPointSize
					Layout.row: 0 // 设置项目在布局中第几行
					Layout.column: 0
					Layout.columnSpan: 2 // 设置项目的列跨度
					Layout.alignment:  Qt.AlignVCenter | Qt.AlignHCenter
				}
				QGCLabel {
					text: qsTr("Alt diff:")
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					text:    _altDifferenceText
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					text: qsTr("Azimuth:")
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					text:    _azimuthText
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					text: qsTr("Distance:")
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					text:    _distanceText
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					text: qsTr("Gradient:")
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					text:    _gradientText
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					text: qsTr("Heading:")
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					text:    _headingText
					Layout.alignment: Qt.AlignRight
				}
			}
			// Item { width: 1; height: 1 }
			GridLayout {
				id: zcq_PlanTool_03
				Layout.alignment: Qt.AlignTop
				columns: 2 // 设置列数
				columnSpacing:     0
				rowSpacing:   0
				QGCLabel {
					color:  "orange"
					text:     qsTr("Total Mission")
					font.pointSize: ScreenTools.smallFontPointSize
					Layout.row: 0 // 设置项目在布局中第几行
					Layout.column: 0
					Layout.columnSpan: 2 // 设置项目的列跨度
					Layout.alignment:  Qt.AlignVCenter | Qt.AlignHCenter
				}
                QGCLabel {
                    text: qsTr("Distance:")
                    Layout.alignment: Qt.AlignRight
                }
				QGCLabel {
					text:    _missionDistanceText
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					text: qsTr("Max telem dist:")
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					text:    _missionMaxTelemetryText
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					text: qsTr("Time:")
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					id: zcq_PlanTool_02_time
					text:    getMissionTime()
					//Layout.minimumWidth: 60
					Layout.alignment: Qt.AlignRight
				}
				// _batteryInfoAvailable
				QGCLabel {
					color:  "orange"
					visible: true // _batteryInfoAvailable
					text:     qsTr("Battery")
					font.pointSize: ScreenTools.smallFontPointSize
					Layout.columnSpan: 2 // 设置项目的列跨度
					Layout.alignment:  Qt.AlignVCenter | Qt.AlignHCenter
				}
				QGCLabel {
					visible: true // _batteryInfoAvailable
					text: qsTr("Batteries required:")
					Layout.alignment: Qt.AlignRight
				}
				QGCLabel {
					visible: true // _batteryInfoAvailable
					text:    _batteriesRequiredText
					Layout.alignment: Qt.AlignRight
				}
			}
		}
	}

	Rectangle {
        id: rect_button
		anchors.margins: 0
		anchors.top: missionStats.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		color: "black" // "transparent"
		opacity: 0.9 // 透明度
		border.width: 0
		RowLayout {
			id: zcq_upload_00
			anchors.margins: 0
			anchors.fill: parent
			spacing: 3
			Rectangle {
				id:             progressBar
				visible:        false
				height: uploadButton.height
				Layout.fillWidth: true
				Layout.minimumWidth: uploadButton.width
				color: "transparent"
				//opacity: 1 // 透明度
				border.width: 0
				Rectangle {	// Small mission download progress bar
					anchors.top:    parent.top
					anchors.bottom: parent.bottom
					width:          _controllerProgressPct * parent.width
					border.width: 0
					color:          qgcPal.colorGreen
				}
				QGCLabel {
					anchors.centerIn: parent
					text:    "Done"
					horizontalAlignment:    Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}
			QGCButton {
				id: uploadButton
				visible: !progressBar.visible && !_controllerOffline && !_controllerSyncInProgress
				Layout.fillWidth: true
				Layout.minimumWidth: uploadButton.width
				text:    _controllerDirty ? qsTr("Upload Required") : qsTr("Upload")
				enabled: !_controllerSyncInProgress
				primary: _controllerDirty
				onClicked:    _planMasterController.upload()
				PropertyAnimation on opacity {
					easing.type:    Easing.OutQuart
					from: 0.5
					to:   1
					loops:     Animation.Infinite
					running:   _controllerDirty && !_controllerSyncInProgress
					alwaysRunToEnd: true
					duration:  2000
				}
			}
			Rectangle {
				visible: true
				height: uploadButton.height
				Layout.fillWidth: true
				Layout.minimumWidth: uploadButton.width
				color: "transparent"
				opacity: 1 // 透明度
				border.width: 0
				border.color: "yellow"
				QGCButton {
					visible: true
					anchors.margins: 0
					anchors.fill: parent
					text:   "QGCButton"
                    onClicked: {
                        if(_QGCButton==true)
                        {
                            _QGCButton=false
                        }else
                        {
                            _QGCButton=true
                        }
                    }
				}
			}
		}
	}


}
