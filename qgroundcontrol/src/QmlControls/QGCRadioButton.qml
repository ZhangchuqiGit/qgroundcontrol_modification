
import QtQuick                  2.11
import QtQuick.Controls         2.4
import QtQuick.Controls.Styles  1.4

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

RadioButton {
    id: control
    property color  textColor:          _qgcPal.text
    property bool   textBold:           false
    property real   textFontPointSize:  ScreenTools.defaultFontPointSize
    property var    _qgcPal:            QGCPalette { colorGroupEnabled: enabled }
    property bool   _noText:            text === ""
    indicator: Rectangle {
		width:          ScreenTools.radioButtonIndicatorSize
		height:         width
        color:                  "white"
		border.color:           "purple"
		border.width: 1
		radius:                 height / 2
        opacity:                control.enabled ? 1 : 0.5
		x:                      control.leftPadding
        y:                      parent.height / 2 - height / 2
        Rectangle {
            anchors.centerIn:   parent
            // Width should be an odd number to be centralized by the parent properly
			width:              2 * Math.floor(parent.width / 4)
            height:             width
            antialiasing:       true
			radius:             height / 2
			color:              "black"
            visible:            control.checked
        }
    }
    contentItem: Text {
        text:               control.text
        font.family:        ScreenTools.normalFontFamily
        font.pointSize:     textFontPointSize
        font.bold:          control.textBold
        color:              control.textColor
        opacity:            enabled ? 1.0 : 0.3
        verticalAlignment:  Text.AlignVCenter
		leftPadding:        control.indicator.width
							+ (_noText ? 0 : 2) // ScreenTools.defaultFontPixelWidth * 0.25)
    }
}
