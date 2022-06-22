import QtQuick 2.0
import QtQuick.Controls 1.2

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.Palette               1.0
import QGroundControl.FlightMap             1.0
import MyControls                           1.0
Item {
    id: root
    state: "close"
    states: [
        State {
            name: "open"
            PropertyChanges {
                target: rect
                visible: true
            }
        },
        State {
            name: "close"
            PropertyChanges {
                target: rect
                visible: false
            }
        }
    ]
    Rectangle {
        id: rect
        visible: true
        anchors.fill: parent
        color: "black"
        opacity: 0.7
        radius: root.width / 5
        MyCompass {
            id: compass
            width: 150
            height: 150
            anchors.right: parent.horizontalCenter
            anchors.rightMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 10
        }
        QGCAttitudeWidget {
            id:                 attitude
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 10
            size:               150
            vehicle:            activeVehicle
        }
        MyVelocimeter {
            id: velocimeter
            width: 150
            height: 150
            anchors.right: parent.horizontalCenter
            anchors.rightMargin: 10
            anchors.top: compass.bottom
            anchors.topMargin: 10
        }
        MyAltimeter {
            id: altimeter
            width: 100
            height: 150
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: 30
            anchors.top: attitude.bottom
            anchors.topMargin: 10
        }
        ExclusiveGroup {
            id: buttonGroup
        }

        Row {
            id: row
            width: 200
            height: 50
            spacing: 4
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            MyButton {
                id: _health
                exclusiveGroup:buttonGroup
                anchors.verticalCenter: parent.verticalCenter
                mytitle: qsTr("健康")
                onClicked: {
                    this.checked=true
                    rect_qml.visible=true
                    loader_qml.source="qrc:/qml/HealthPageWidget.qml"
                }
            }
            MyButton {
                id: _camera
                exclusiveGroup:buttonGroup
                anchors.verticalCenter: parent.verticalCenter
                mytitle: qsTr("相机")
                onClicked: {
                    this.checked=true
                    rect_qml.visible=true
                    loader_qml.source="qrc:/qml/CameraPageWidget.qml"
                }
            }
            MyButton {
                id: _vibration
                exclusiveGroup:buttonGroup
                anchors.verticalCenter: parent.verticalCenter
                mytitle: qsTr("振动")
                onClicked: {
                    this.checked=true
                    rect_qml.visible=true
                    loader_qml.source="qrc:/qml/VibrationPageWidget.qml"
                }
            }
        }
    }
    //combox界面
//    Item {
//        id:                 _valuesItem
//        anchors.topMargin:  ScreenTools.defaultFontPixelHeight / 4
//        anchors.top:        rect.bottom
//        width:              parent.width
//        height:             100//_valuesWidget.height
//        visible:            widgetRoot.showValues

//        // Prevent all clicks from going through to lower layers
//        DeadMouseArea {
//            anchors.fill: parent
//        }

//        Rectangle {
//            anchors.fill:   _valuesWidget
//            color:          "red"//qgcPal.window
//        }

//        PageView {
//            id:                 _valuesWidget
//            anchors.margins:    1
//            anchors.left:       parent.left
//            anchors.right:      parent.right
//            maxHeight:          200//_availableValueHeight
//        }
//    }

    Rectangle {
        id:                 rect_qml
        visible:            root.state=="open"?  true : false
        anchors.topMargin:  ScreenTools.defaultFontPixelHeight / 4
        anchors.top:        rect.bottom
        width:              parent.width
        height:             110
        color:              "black"
        opacity:            0.7
        Loader {
            id: loader_qml
            anchors.fill: parent
            source: ""
        }
    }

    Image {
        source: rect.visible ? "qrc:/MyImages/MyImages/Pikachu.ico" : "qrc:/MyImages/MyImages/PokeBall.ico"
        sourceSize.width: parent.width / 10
        sourceSize.height: parent.height / 10
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        MouseArea {
            anchors.fill: parent
            drag.target: root
            drag.axis: Drag.XAndYAxis
            drag.minimumX: 0
            drag.maximumX: root.parent.width - root.width
            drag.minimumY: 0
            drag.maximumY: root.parent.height - root.height
            onClicked: {
                if(root.state == "open")
                {
                    root.state = "close"
                    _health.checked=false
                    _camera.checked=false
                    _vibration.checked=false
                    rect_qml.visible=false
                }else
                {
                    root.state = "open"
                }
            }
        }
    }
}
