/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.11
import QtQuick.Layouts  1.11

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//-------------------------------------------------------------------------
//-- Telemetry RSSI
Item {
    id:             _root
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          telemIcon.width * 1.1

    property bool showIndicator: _hasTelemetry

    property var  _activeVehicle:   QGroundControl.multiVehicleManager.activeVehicle
    property bool _hasTelemetry:    _activeVehicle ? _activeVehicle.telemetryLRSSI !== 0 : false

    Component {
        id: telemRSSIInfo
        Rectangle {
			width:  telemCol.width   + ScreenTools.defaultFontPixelWidth  * 1.1
			height: telemCol.height  + ScreenTools.defaultFontPixelHeight * 1.1
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text
            Column {
                id:                 telemCol
				spacing:            ScreenTools.defaultFontPixelHeight * 0.3
                width:              Math.max(telemGrid.width, telemLabel.width)
				anchors.margins:    ScreenTools.defaultFontPixelWidth
                anchors.centerIn:   parent
                QGCLabel {
                    id:             telemLabel
                    text:           qsTr("Telemetry RSSI Status")
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                GridLayout {
                    id:                 telemGrid
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter
                    QGCLabel { text: qsTr("Local RSSI:") }
                    QGCLabel { text: activeVehicle.telemetryLRSSI + " dBm"}
                    QGCLabel { text: qsTr("Remote RSSI:") }
                    QGCLabel { text: activeVehicle.telemetryRRSSI + " dBm"}
                    QGCLabel { text: qsTr("RX Errors:") }
                    QGCLabel { text: activeVehicle.telemetryRXErrors }
                    QGCLabel { text: qsTr("Errors Fixed:") }
                    QGCLabel { text: activeVehicle.telemetryFixed }
                    QGCLabel { text: qsTr("TX Buffer:") }
                    QGCLabel { text: activeVehicle.telemetryTXBuffer }
                    QGCLabel { text: qsTr("Local Noise:") }
                    QGCLabel { text: activeVehicle.telemetryLNoise }
                    QGCLabel { text: qsTr("Remote Noise:") }
                    QGCLabel { text: activeVehicle.telemetryRNoise }
                }
            }
        }
    }
    QGCColoredImage {
        id:                 telemIcon
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        width:              height
        sourceSize.height:  height
        source:             "/qmlimages/TelemRSSI.svg"
        fillMode:           Image.PreserveAspectFit
        color:              qgcPal.buttonText
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            mainWindow.showPopUp(_root, telemRSSIInfo)
        }
    }
}
