import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
Item {
    id: root
    property real   _speed:         activeVehicle ? activeVehicle.groundSpeed.rawValue : 0
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
    //模拟数据变化
//    Timer {
//        running: true
//        repeat: true
//        interval: 4000
//        onTriggered: gauge.value = (gauge.value == gauge.maximumValue ? 0 : gauge.maximumValue)
//    }
    CircularGauge {
        id: gauge
        value: _speed
        //设置动画效果
//        Behavior on value {
//            NumberAnimation {
//                duration: 3000
//            }
//        }

        anchors.fill: parent
        style: CircularGaugeStyle {
            id: gauge_style
            needle: null
            foreground: Item {
                //数值显示
                Rectangle {
                    id: value_rect
                    anchors.centerIn: parent
                    width: outerRadius * 0.35
                    height: width
                    color: "transparent"
                    Text {
                        id: value_text
                        anchors.fill: parent
                        color: "#e5e5e5"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: outerRadius * 0.25
                        text: gauge.value.toFixed(0)
                    }
                }
                //单位显示
                Text {
                    id: unit_text
                    anchors.top: value_rect.bottom
                    anchors.topMargin: outerRadius * 0.05
                    anchors.horizontalCenter: value_rect.horizontalCenter
                    color: "#e5e5e5"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: outerRadius * 0.15
                    text: qsTr("m/s")
                }
            }
            //角度转换为弧度
            function degreesToRadians(degrees) {
                return degrees * (Math.PI / 180)
            }

            tickmark: Rectangle {
                visible: styleData.value
                implicitWidth: outerRadius * 0.02
                implicitHeight: outerRadius * 0.06
                color: "#e5e5e5"
            }

            tickmarkLabel: Text {
                text: styleData.value
                font.pixelSize: outerRadius * 0.12
                color: Qt.rgba(styleData.value / gauge.maximumValue, 1 - styleData.value / gauge.maximumValue, 0, 1)
                antialiasing: true
            }
            background: Item {
                //绘制背景
                Canvas {
                    width: outerRadius * 2
                    height: outerRadius * 2
                    onPaint: {
                        var ctx = getContext("2d")
                        //绘制表盘背景
                        ctx.beginPath()
                        ctx.fillStyle = "black"
                        ctx.arc(width/2,height/2,outerRadius,0,2 * Math.PI)
                        ctx.fill()
                        //绘制圆圈
                        ctx.beginPath()
                        ctx.strokeStyle = "#33CCFF"
                        ctx.lineWidth = outerRadius * 0.015
                        ctx.arc(width/2,height/2,outerRadius * 0.5,0,2 * Math.PI)
                        ctx.stroke()
                        //绘制中间分割线
                        ctx.beginPath()
                        ctx.strokeStyle = "#33CCFF"
                        ctx.lineWidth = outerRadius * 0.015
                        ctx.moveTo(width*0.5, height*0.6)
                        ctx.lineTo(width*0.4, height*0.6)
                        ctx.moveTo(width*0.5, height*0.6)
                        ctx.lineTo(width*0.6, height*0.6)
                        ctx.stroke()

                    }
                }
                //绘制动态弧形
                Canvas {
                    width: outerRadius * 2
                    height: outerRadius * 2
                    property var color: Qt.rgba(gauge.value / gauge.maximumValue, 1 - gauge.value / gauge.maximumValue, 0, 1)
                    property var center_x: width / 2
                    property var center_y: height / 2
                    property var value: gauge.value
                    onValueChanged: {
                        requestPaint()
                    }
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.beginPath()
                        ctx.lineWidth = outerRadius * 0.14
                        ctx.strokeStyle = color
                        ctx.arc(center_x,center_y,outerRadius/1.6,degreesToRadians(valueToAngle(gauge.minimumValue)-90),degreesToRadians(valueToAngle(gauge.value)-90))
                        ctx.stroke()
                    }
                }
            }
        }
    }
}
