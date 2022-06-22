import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtGraphicalEffects       1.0

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

//import QGroundControl.Zcq_debug     1.0

Button {
    id: _root
    onCheckedChanged: checkable = false
    property string mytitle: ""
    property bool   setupComplete: true                                    ///< true: setup complete indicator shows as completed
    property bool   setupIndicator: true                                    ///< true: show setup complete indicator
    activeFocusOnPress: true

    style: ButtonStyle {
        id: buttonStyle
        QGCPalette { // 字体和调色板
            id:                 qgcPal
            colorGroupEnabled:  control.enabled
        }
        property bool showHighlight: control.pressed | control.checked
        background: Rectangle {
            id:     innerRect
            color:  showHighlight ? qgcPal.buttonHighlight : qgcPal.windowShade
            radius: 2
            border.width: 0
            anchors.margins: 0
            anchors.fill: parent
            implicitWidth: 50
            implicitHeight: 30

            Label {
                id:                     titleBar
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment:      TextEdit.AlignVCenter
                horizontalAlignment:    TextEdit.AlignHCenter
                color:                  showHighlight ? qgcPal.buttonHighlightText : qgcPal.buttonText
                text:                   _root.mytitle
            }
        }
    }
}
