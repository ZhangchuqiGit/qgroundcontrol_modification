//import QtQuick 2.0
//import QtQuick.Extras 1.4
//import QtQuick.Controls.Styles 1.4
//Item {
//    id: item_dashboard
//    //航向角的数据源
//    property real   _heading:         activeVehicle ? activeVehicle.heading.rawValue : 0
//    //实现航向仪的可拖拽功能
//    MouseArea {
//        id: gauge_mouse
//        anchors.fill: parent
//        drag.target: parent
//        drag.axis: Drag.XAndYAxis
//        drag.minimumX: 0
//        drag.maximumX: parent.parent.width - parent.width
//        drag.minimumY: 0
//        drag.maximumY: parent.parent.height - parent.height
//    }
//    CircularGauge {
//        id: gauge
//        stepSize: 0.1 //value的增量必须大于stepSize,否则仪表盘不动作
//        anchors.fill: parent
//        minimumValue: 0
//        maximumValue: 360
//        //绑定航向角的数据
//        value: _heading
//        //DIY仪表盘样式
//        style: CircularGaugeStyle {
//            id: gauge_Style
//            //设置角度范围
//            minimumValueAngle: 0
//            maximumValueAngle: 360
//            //设置标签显示间隔
//            labelStepSize: 30
//            //设置刻度线标签显示具体信息
//            tickmarkLabel: Text {
//                text: {
//                    if(styleData.value === 0)
//                    {
//                        font.pixelSize = outerRadius * 0.15
//                        return "N"
//                    }
//                    else if(styleData.value === 90)
//                    {
//                        font.pixelSize = outerRadius * 0.15
//                        return "E"
//                    }
//                    else if(styleData.value === 180)
//                    {
//                        font.pixelSize = outerRadius * 0.15
//                        return "S"
//                    }else if(styleData.value === 270)
//                    {
//                        font.pixelSize = outerRadius * 0.15
//                        return "W"
//                    }else
//                    {
//                        font.pixelSize = outerRadius * 0.1
//                        return styleData.value
//                    }
//                }
//                color: "#D5912B"
//                antialiasing: true
//                visible: styleData.value < 360 //防止 360 和 0 这两个标签重叠
//            }
//            //设置指针
//            needle: Canvas {
//                y: outerRadius * 0.6
//                width: outerRadius * 0.8
//                height: outerRadius * 1.5
//                antialiasing: true
//                onPaint: {
//                    var ctx = getContext("2d")
//                    ctx.strokeStyle = "#D5912B"
//                    ctx.lineWidth = outerRadius * 0.015
//                    //绘制矩形边框(方便定位)
////                    ctx.beginPath()
////                    ctx.strokeRect(0,0,width,height)
//                    //绘制飞机头部和指针
//                    ctx.beginPath()
//                    ctx.moveTo(width * 0.5,0)
//                    ctx.lineTo(width * 0.5,height * 0.2)
//                    ctx.lineTo(width * 0.4,height * 0.3)
//                    ctx.moveTo(width * 0.5,height * 0.2)
//                    ctx.lineTo(width * 0.6,height * 0.3)
//                    ctx.stroke()
//                    //绘制飞机左边机翼
//                    ctx.beginPath()
//                    ctx.moveTo(width * 0.4,height * 0.3)
//                    ctx.lineTo(outerRadius * 0.015,height * 0.38)
//                    ctx.lineTo(outerRadius * 0.015,height * 0.5)
//                    ctx.lineTo(width * 0.4,height * 0.5)
//                    ctx.stroke()
//                    //绘制飞机右边机翼
//                    ctx.beginPath()
//                    ctx.moveTo(width * 0.6,height * 0.3)
//                    ctx.lineTo(width-outerRadius * 0.015,height * 0.38)
//                    ctx.lineTo(width-outerRadius * 0.015,height * 0.5)
//                    ctx.lineTo(width * 0.6,height * 0.5)
//                    ctx.stroke()
//                    //绘制飞机机尾
//                    ctx.beginPath()
//                    ctx.moveTo(width * 0.4,height * 0.5)
//                    ctx.lineTo(width * 0.4,height * 1)
//                    ctx.lineTo(width * 0.6,height * 1)
//                    ctx.lineTo(width * 0.6,height * 0.5)
//                    ctx.stroke()
//                }
//            }
//            //设置前景（即中心圆盘）
//            foreground: Item {
//                //设置中心圆盘区域
//                Rectangle {
//                    id: centerCir
//                    width: outerRadius * 0.2
//                    height: width
//                    radius: width / 2
//                    color: "#F07D31"
//                    anchors.centerIn: parent
//                }
//                //设置数值显示区域
//                Rectangle {
//                    id: value_rect
//                    width: outerRadius * 0.4
//                    height: outerRadius * 0.3
//                    color: "#444548"
//                    anchors.verticalCenter: parent.verticalCenter
//                    anchors.rightMargin: outerRadius * 1/5
//                    anchors.right: centerCir.left
//                    radius: 10
//                    border.width: 5
//                    Text {
//                        id: value_text
//                        anchors.fill: parent
//                        color: "white"
//                        verticalAlignment: Text.AlignVCenter
//                        horizontalAlignment: Text.AlignHCenter
//                        font.pixelSize: outerRadius * 0.1
//                        text: gauge.value.toFixed(0)
//                    }
//                }
//            }
//            //设置背景
//            background: Canvas {
//                width: outerRadius * 2
//                height: outerRadius * 2
//                onPaint: {
//                    var ctx = getContext("2d")
//                    //绘制表盘背景
//                    ctx.beginPath()
//                    ctx.fillStyle = "black"
//                    ctx.ellipse(0, 0, width, height)
//                    ctx.fill()
//                    //绘制表盘边框
//                    ctx.strokeStyle = "#D5912B"
//                    ctx.lineWidth = outerRadius * 0.015
//                    ctx.ellipse(0, 0, width, height)
//                    ctx.stroke()
//                }
//            }

//        }

//    }


//}

import QtQuick 2.0
import QtLocation 5.6
import QtPositioning 5.6

Item {
//    width: Qt.platform.os == "android" ? Screen.width : 512
//    height: Qt.platform.os == "android" ? Screen.height : 512

    visible: true
    anchors.fill: parent
    Plugin {
        id: mapPlugin
        name: "mapboxgl" // "mapboxgl", "esri", ...
        // specify plugin parameters if necessary
        // PluginParameter {
        //     name:
        //     value:
        // }
    }

    Map {
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(23.13, 113.27) // Oslo
        zoomLevel: 14
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
