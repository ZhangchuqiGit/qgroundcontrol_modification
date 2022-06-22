
import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2
import QtQuick.Layouts  1.11

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactControls  1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0

//import QGroundControl.Zcq_debug     1.0

Item {
	id:     _root
	height: monitorColumn.height
	property bool twoColumn: false

	RCChannelMonitorController {    id: controller    }
	//	Zcq_debug { id : zcq }

	GridLayout {
		id:         monitorColumn
		width:      parent.width
		columns:    twoColumn ? 2 : 1
		columnSpacing: 0
		rowSpacing: 0 // ScreenTools.defaultFontPixelWidth
		Connections {
			target: controller
			onChannelRCValueChanged: {
				if (channelMonitorRepeater.itemAt(channel)) {
					channelMonitorRepeater.itemAt(channel).loader.item.rcValue = rcValue
				}
			}
		}
		//		Component.onCompleted: {
		//			zcq.echo("Component.onCompleted: {...}" + " -------- RCChannelMonitor.qml ")
		//			zcq.echo("controller.channelCount=" +  controller.channelCount)
		//			zcq.echo("width=" + width)
		//			zcq.echo("height=" + width)
		//		}
		QGCLabel {
			Layout.columnSpan:  parent.columns
			text:               "Channel Monitor"
			color:          "deepskyblue" // qgcPal.text
		}
		Repeater {
			id:     channelMonitorRepeater
			model:  controller.channelCount
			RowLayout {
				QGCLabel {
					id:     channelLabel
					Layout.minimumWidth: ScreenTools.defaultFontPixelWidth * 2.5
					text:   modelData + 1
					horizontalAlignment: Text.AlignRight
					verticalAlignment: Text.AlignVCenter
				}
				property Item loader: theLoader
				Loader {
					id:                 theLoader
					Layout.fillWidth:   true
					sourceComponent: channelMonitorDisplayComponent // 通道监控显示组件
					property bool mapped:               true
					readonly property bool reversed:    false
				}
			}
		}
	}

	Component {
		id: channelMonitorDisplayComponent // 通道监控显示组件
		Item {
			property int			rcValue:			1500
			//					property int            __lastRcValue:  1500
			//					readonly property int   __rcValueMaxJitter: 2
			readonly property int	_pwmMin:		1000 - 60
			readonly property int	_pwmMax:		2000 + 60
			readonly property int _pwmRange:    _pwmMax - _pwmMin
			// Bar
			Rectangle {
				id:                     bar
				anchors.verticalCenter: parent.verticalCenter
				width:                  parent.width
				height:                 6 // parent.height * 0.3
				color:                  "LimeGreen" // qgcPal.windowShade
				border.width: 0
				opacity: 1 // 透明度
				radius: height * 0.5
			}
			// Indicator
			Rectangle {
				id: indicator_r
				visible:                mapped
				anchors.verticalCenter: parent.verticalCenter
				height:                 bar.height * 1.6
				width:					height
				radius: height * 0.5
				color:                  "red" // qgcPal.text
				border.width: 0
				opacity: 1 // 透明度
				x: ( ( (reversed ? _pwmMax - rcValue : rcValue - _pwmMin) / _pwmRange)
					* parent.width) - (width / 2)
			}
			// Center point
			Rectangle {
				anchors.verticalCenter: parent.verticalCenter
				anchors.horizontalCenter:   parent.horizontalCenter
				width:                      1
				height:                     indicator_r.height
				color:                      "white" // qgcPal.window // "transparent"
				border.width: 0
				opacity: 1 // 透明度
				//radius: 2
			}
			QGCLabel {
				visible:                !mapped
				anchors.fill:           parent
				horizontalAlignment:    Text.AlignHCenter
				verticalAlignment:      Text.AlignVCenter
				text:                   "Not Mapped"//未映射
				color: "pink" //qgcPal.window
			}
		}
	}

}
