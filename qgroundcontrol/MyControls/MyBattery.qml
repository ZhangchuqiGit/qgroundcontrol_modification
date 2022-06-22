import QtQuick 2.0
import QtQuick.Controls 2.12
Item {
    id: root
    width: 50
    height: battery_top.height + battery_bottom.height
    property var value: battery_power.height
    //模拟数据变化
    Timer {
        running: true
        repeat: true
        interval: 4000
        onTriggered: battery_power.height = (battery_power.height == 100 ? 0 : 100)
    }

    Rectangle {
        id: battery_top
        width: 26
        height: 15
        border.color: "#959a93"
        border.width: 5
        radius: width / 5
        anchors.horizontalCenter: root.horizontalCenter
    }

    Rectangle {
        id: battery_bottom
        width: 50
        height: 110
        radius: width / 10
        color: "transparent"
        border.color: "#959a93"
        border.width: 5
        anchors.horizontalCenter: root.horizontalCenter
        anchors.top: battery_top.bottom
        anchors.topMargin: -(border.width)

        Label {
            id: label
            z: 0
            text: root.value.toFixed(0)
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Rectangle {
        id: battery_power
        z: 1
        width: battery_bottom.width - 2 * battery_bottom.border.width
        anchors.bottom: battery_bottom.bottom
        anchors.horizontalCenter: root.horizontalCenter
        anchors.bottomMargin: 5
        height: 0
        //设置动画效果
        Behavior on height {
            NumberAnimation {
                duration: 3000
            }
        }
        color: {
            if(height<=20)
            {
                return "red"
            }else
            {
                return "green"
            }
        }
    }
}


