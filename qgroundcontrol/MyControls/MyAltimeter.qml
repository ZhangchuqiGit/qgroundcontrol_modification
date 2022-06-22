import QtQuick 2.0
import QtQuick.Extras 1.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
Item {
    id: root
    property real   _amsl:         activeVehicle ? activeVehicle.altitudeAMSL.rawValue : 0
    //模拟数据变化
//    Timer {
//        running: true
//        repeat: true
//        interval: 4000
//        onTriggered: gauge.value = (gauge.value == gauge.maximumValue ? 0 : gauge.maximumValue)
//    }
    //实现可拖拽功能
    MouseArea {
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XAndYAxis
        drag.minimumX: 0
        drag.maximumX: parent.parent.width - parent.width
        drag.minimumY: 0
        drag.maximumY: parent.parent.height - parent.height
    }
    Gauge {
        id: gauge
        value: _amsl
        //设置动画效果
//        Behavior on value {
//            NumberAnimation {
//                duration: 3000
//            }
//        }
        anchors.fill: parent
        maximumValue: 800
        tickmarkStepSize: 200
        style: GaugeStyle {
            valueBar: Rectangle {
                implicitWidth: 16
                color: Qt.rgba(gauge.value / gauge.maximumValue, 1 - gauge.value / gauge.maximumValue, 0, 1)
            }
            tickmarkLabel: Text {
                text: styleData.value
                color: Qt.rgba(styleData.value / gauge.maximumValue, 1 - styleData.value / gauge.maximumValue, 0, 1)
                antialiasing: true
            }
            background: Rectangle {
                color: "black"
            }
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
