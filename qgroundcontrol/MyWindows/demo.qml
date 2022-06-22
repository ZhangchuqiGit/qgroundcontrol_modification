import QtQuick 2.12
import QtQuick.Controls 2.12
Item {
    Row {
        id: row
        width: 200
        height: 50
        spacing: 5

        Rectangle {
            id: rectangle
            width: 50
            height: parent.height
            color: "black"
            opacity: 0.7
            radius: 5
            Text {
                color: "#daecf2"
                anchors.fill: parent
                text: qsTr("健康")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle {
            id: rectangle1
            width: 50
            height: parent.height
            opacity: 0.7
            color: "red"
            radius: 5
            Text {
                color: "#daecf2"
                anchors.fill: parent
                text: qsTr("相机")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle {
            id: rectangle2
            width: 50
            height: parent.height
            opacity: 0.7
            color: "green"
            radius: 5
            Text {
                color: "#daecf2"
                anchors.fill: parent
                text: qsTr("振动")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
