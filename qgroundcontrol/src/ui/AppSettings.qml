/// Settings 配置视图 应用程序设置

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

import QGroundControl.Zcq_debug     1.0

Rectangle {
	color: "transparent" // qgcPal.window
	opacity: 1 // 透明度
	border.width: 0
	anchors.margins: 0
	anchors.fill:   parent

	Zcq_debug { id : zcq }
	readonly property string zcqfile: " -------- AppSettings.qml "

	Component.onCompleted: {
		zcq.echo("Component.onCompleted" + zcqfile)
		zcq.echo("buttonColumn.width=" + buttonColumn.width )
		zcq.echo("buttonColumn.height=" + buttonColumn.height )

		panelLoader.source = /* QGroundControl.corePlugin.settingsPages[0].url */
				QGroundControl.corePlugin.settingsPages[QGroundControl.corePlugin.defaultSettings].url
		// ../zcq-qgroundcontrol/src/api/QGCCorePlugin.cc
		// [0] qrc:/qml/GeneralSettings.qml						General			常规
		// [1] qrc:/qml/LinkSettings.qml						Comm Links		通讯连接
		// [2] qrc:/qml/OfflineMap.qml							Offline Maps	离线地图
		// [3] qrc:/qml/MavlinkSettings.qml						MAVLink			检测器
		// [4] qrc:/qml/QGroundControl/Controls/AppMessages.qml	Console			控制台
		// [5] qrc:/qml/HelpSettings.qml						Help			帮助
	}
	QGCPalette { id: qgcPal } // 字体和调色板
	Rectangle {
		id : divider
		anchors.margins: 0
		anchors.left:           parent.left
		anchors.top:           parent.top
		//anchors.verticalCenter: parent.verticalCenter
		height: buttonColumn.height + buttonColumn.spacing * 2
		width: buttonColumn.width + buttonColumn.spacing * 2
		color: "transparent"
		opacity: 1 // 透明度
		border.width: 0
		//radius: 2
		Rectangle {
			z: -1
			anchors.fill: parent
			anchors.margins: 0
			color: "#002800" // "transparent"
			border.width: 0
			opacity: 0.8 // 透明度
			radius: 2
		}
		ColumnLayout {
			id:         buttonColumn
			anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
			spacing:    4
			QGCLabel {
				Layout.fillWidth:       true
				Layout.alignment: Qt.AlignHCenter
				text:                   qsTr("Application Settings") // 应用设置
				wrapMode:               Text.WordWrap
				horizontalAlignment:    Text.AlignHCenter
				visible:                !ScreenTools.isShortScreen
				Rectangle {
					z: -1
					anchors.fill: parent
					anchors.margins: 0
					color: "darkolivegreen" // "transparent"
					border.width: 0
					opacity: 0.7 // 透明度
					radius: 2
				}
			}
			// ExclusiveGroup 提供了一种将多个可检查控件声明为互斥的方法
			// 支持的几个控件为：Action, MenuItem, Button 和 RadioButton
			ExclusiveGroup { id: panelActionGroup }
			property bool _first: true
			Repeater {
				model:  QGroundControl.corePlugin.settingsPages
				QGCButton {
					text:               modelData.title
					exclusiveGroup:     panelActionGroup
					Layout.fillWidth:   true
					Layout.alignment: Qt.AlignHCenter
					onClicked: {
						if (mainWindow.preventViewSwitch()) { return }
						if (panelLoader.source !== modelData.url) {
							panelLoader.source = modelData.url
						}
						checked = true
					}
					Component.onCompleted: {
						if(buttonColumn._first) {
							buttonColumn._first = false
							checked = true
						}
					}
				}
			}
		}
	}
	Rectangle {
		id: bar_vertical
		anchors.margins: 0
		anchors.top:            divider.top
		anchors.bottom:         divider.bottom
		anchors.left:           divider.right
		width: 2
		color: "#002800" // "transparent"
		border.width: 0
		opacity: 0.8 // 透明度
		//radius: 2
	}
	Rectangle { // 面板
		anchors.margins: 0
		anchors.top:            parent.top
		anchors.bottom:         parent.bottom
		anchors.left:           bar_vertical.right
		anchors.right:          parent.right
		color: "transparent"
		border.width: 0
		opacity: 1 // 透明度
		//radius: 2
		Loader {	//-- Panel Contents
			id: panelLoader
			anchors.margins: 0
			anchors.fill: parent
		}
		Rectangle {
			z: -1
			anchors.fill: parent
			anchors.margins: 0
			color: "#002800" // "transparent"
			border.width: 0
			opacity: 0.8 // 透明度
			radius: 2
		}
	}
}
