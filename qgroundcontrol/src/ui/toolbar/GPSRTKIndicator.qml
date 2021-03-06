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
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//-------------------------------------------------------------------------
//-- GPS Indicator
Item {
    id:             _root
    width:          (gpsValuesColumn.x + gpsValuesColumn.width) * 1.1
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    property bool showIndicator: QGroundControl.gpsRtk.connected.value

    Component {
        id: gpsInfo

        Rectangle {
			width:  gpsCol.width   + ScreenTools.defaultFontPixelWidth  * 1.1
			height: gpsCol.height  + ScreenTools.defaultFontPixelHeight * 1.1
			radius: ScreenTools.defaultFontPixelHeight * 0.4
            color:  qgcPal.window
            border.color:   qgcPal.text

            Column {
                id:                 gpsCol
				spacing:            2 // ScreenTools.defaultFontPixelHeight * 0.3
                width:              Math.max(gpsGrid.width, gpsLabel.width)
				anchors.margins:    2 // ScreenTools.defaultFontPixelHeight * 0.3
                anchors.centerIn:   parent

                QGCLabel {
                    id:             gpsLabel
                    text: (QGroundControl.gpsRtk.active.value) ? qsTr("Survey-in Active") : qsTr("RTK Streaming")
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                GridLayout {
                    id:                 gpsGrid
                    visible:            true
					anchors.margins:    22 // ScreenTools.defaultFontPixelHeight * 0.3
					columnSpacing:      2 // ScreenTools.defaultFontPixelWidth * 0.3
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: 2

                    QGCLabel {
                        text: qsTr("Duration:")
                        visible: QGroundControl.gpsRtk.active.value
                        }
                    QGCLabel {
                        text: QGroundControl.gpsRtk.currentDuration.value + ' s'
                        visible: QGroundControl.gpsRtk.active.value
                        }
                    QGCLabel {
                        // during survey-in show the current accuracy, after that show the final accuracy
                        text: QGroundControl.gpsRtk.valid.value ? qsTr("Accuracy:") : qsTr("Current Accuracy:")
                        visible: QGroundControl.gpsRtk.currentAccuracy.value > 0
                        }
                    QGCLabel {
                        text: QGroundControl.gpsRtk.currentAccuracy.valueString + " " + QGroundControl.appSettingsDistanceUnitsString
                        visible: QGroundControl.gpsRtk.currentAccuracy.value > 0
                        }
                    QGCLabel { text: qsTr("Satellites:") }
                    QGCLabel { text: QGroundControl.gpsRtk.numSatellites.value }
                }
            }
        }
    }

    QGCColoredImage {
        id:                 gpsIcon
        width:              height
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        source:             "/qmlimages/RTK.svg"
        fillMode:           Image.PreserveAspectFit
        sourceSize.height:  height
        opacity:            1
        color:              QGroundControl.gpsRtk.active.value ? qgcPal.colorRed : qgcPal.buttonText
    }

    Column {
        id:                     gpsValuesColumn
        anchors.verticalCenter: parent.verticalCenter
		anchors.leftMargin:     2 // ScreenTools.defaultFontPixelWidth * 0.3
        anchors.left:           gpsIcon.right

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            color:                      qgcPal.buttonText
            text:                       QGroundControl.gpsRtk.numSatellites.value
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked: {
            mainWindow.showPopUp(_root, gpsInfo)
        }
    }
}
