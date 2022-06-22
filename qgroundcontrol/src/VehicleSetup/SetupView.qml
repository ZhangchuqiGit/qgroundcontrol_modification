/// Setup 设置视图 载具设置

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl                       1.0
import QGroundControl.AutoPilotPlugin       1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0

import QGroundControl.Zcq_debug     1.0

/*	QML中Loader的source和sourceComponent属性
	QML的Loader元素经常备用来动态加载QML组件。可以使用source属性或者sourceComponent属性加载。
1、source属性，加载一个QML文档。
2、sourceComponent属性，加载一个Component对象。
3、当source或sourceComponent属性发生变化时，它之前的对象会被销毁，新对象会被加载。
4、当source设置为空串，或者sourceComponent设置为undefined，
	将会销毁当前对象，相关资源也会被释放，Loader对象会变成一个空对象。
*/

Rectangle {
	id: setupView
	color: "transparent" // qgcPal.window
	//opacity: 1 // 透明度
	border.width: 0
	anchors.margins: 0
	anchors.fill:   parent

	// 飞机解锁期间，不能执行此操作。
	readonly property string _armedVehicleText: qsTr("This operation cannot be performed while the vehicle is armed.")
	property bool   _vehicleArmed: QGroundControl.multiVehicleManager.activeVehicle ?
									   QGroundControl.multiVehicleManager.activeVehicle.armed : false
	property string _messagePanelText:  qsTr("missing message panel text") // 缺少消息面板文本
	property bool   _fullParameterVehicleAvailable:
		QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable
		&& !QGroundControl.multiVehicleManager.activeVehicle.parameterManager.missingParameters
	property var    _corePlugin:     QGroundControl.corePlugin

	QGCPalette { id: qgcPal; colorGroupEnabled: true } // 字体和调色板

	Zcq_debug { id : zcq }
	readonly property string zcqfile: " -------- SetupView.qml "

	Component.onCompleted: {
		zcq.echo("Component.onCompleted" + zcqfile)
		showSummaryPanel() // right Panel 概况
		zcq.echo("buttonScroll.width=" + buttonScroll.width )
		zcq.echo("buttonScroll.height=" + buttonScroll.height )
	}

	function showSummaryPanel() // right Panel 概况
	{
		zcq.echo("showSummaryPanel() 摘要面板" + zcqfile)
		if (mainWindow.preventViewSwitch())	return
		summaryButton.checked = true
		zcq.echo("_fullParameterVehicleAvailable=" + _fullParameterVehicleAvailable) // false
		if (_fullParameterVehicleAvailable) {
			if (QGroundControl.multiVehicleManager.activeVehicle.autopilot.vehicleComponents.length === 0) {
				zcq.echo("无组件飞机概况组件")
				panelLoader.setSourceComponent(noComponentsVehicleSummaryComponent) // 无组件飞机概况组件
			} else {
				zcq.echo("VehicleSummary.qml")
				panelLoader.setSource("VehicleSummary.qml")
			}
		} else if (QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable) {
			zcq.echo("缺少参数飞机摘要组件")
			panelLoader.setSourceComponent(missingParametersVehicleSummaryComponent) // 缺少参数飞机摘要组件
		} else {
			zcq.echo("断开的飞机汇总组件")
			panelLoader.setSourceComponent(disconnectedVehicleSummaryComponent) // 断开的飞机汇总组件
		}
	}

	// ------------------------------------------------------------------------
	function showPanel(button, qmlSource) {
		if (mainWindow.preventViewSwitch()) return
		button.checked = true
		panelLoader.setSource(qmlSource)
	}
	function showVehicleComponentPanel(vehicleComponent) //
	{
		if (mainWindow.preventViewSwitch()) return
		var autopilotPlugin = QGroundControl.multiVehicleManager.activeVehicle.autopilot
		var prereq = autopilotPlugin.prerequisiteSetup(vehicleComponent)
		if (prereq !== "") {
			_messagePanelText =
					qsTr("%1 setup must be completed prior to %2 setup.").arg(prereq).arg(vehicleComponent.name)
			panelLoader.setSourceComponent(messagePanelComponent)
			zcq.echo("_messagePanelText=" + _messagePanelText) // xxx 设置必须在 xxx 设置之前完成。
		} else {
			panelLoader.setSource(vehicleComponent.setupSource, vehicleComponent)
		}
		for(var i = 0; i < componentRepeater.count; i++) {
			var obj = componentRepeater.itemAt(i)
			if (obj.mytitle === vehicleComponent.name) {
				obj.checked = true
				break
			}
		}
	}
	Component {
		id: messagePanelComponent // 消息面板组件
		Rectangle {
			color: "Olive" // qgcPal.windowShade
			//Item {
			QGCLabel {
				anchors.margins:       0
				anchors.fill:           parent
				verticalAlignment:      Text.AlignVCenter
				horizontalAlignment:    Text.AlignHCenter
				wrapMode:               Text.WordWrap
				font.pointSize:         ScreenTools.mediumFontPointSize
				text:                   _messagePanelText // xxx 设置必须在 xxx 设置之前完成。
			}
		}
	}

	// ------------------------------------------------------------------------
	Connections {
		target: QGroundControl.corePlugin
		onShowAdvancedUIChanged: {
			if(!QGroundControl.corePlugin.showAdvancedUI) {
				showSummaryPanel() // right Panel 概况
			}
		}
	}
	Connections {
		target: QGroundControl.multiVehicleManager
		onParameterReadyVehicleAvailableChanged: {
			if(!QGroundControl.skipSetupPage) {
				if (QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable
						|| summaryButton.checked /*概况*/
						|| setupButtonGroup.current != firmwareButton /*固件*/) {
					/* 在以下情况下显示/重新加载摘要面板:
					一辆新车出现了; 摘要面板已经显示出来，活动车辆消失了;
					主动车辆消失了，我们不在固件面板上。*/
					showSummaryPanel() // right Panel 概况
				}
			}
		}
	}

	// ------------------------------------------------------------------------
	// 概况
	Component {
		id: noComponentsVehicleSummaryComponent // 无组件飞机概况组件
		Rectangle {
			color: "pink" // qgcPal.windowShade
			QGCLabel {
				anchors.margins:       0
				anchors.fill:           parent
				verticalAlignment:      Text.AlignVCenter
				horizontalAlignment:    Text.AlignHCenter
				wrapMode:               Text.WordWrap
				font.pointSize:         ScreenTools.mediumFontPointSize
				text: // 当前不支持您的飞机类型的设定。
					  qsTr("%1 does not currently support setup of your vehicle type. ").arg(QGroundControl.appName)
					  + "\nIf your vehicle is already configured you can still Fly."
				onLinkActivated: Qt.openUrlExternally(link)
				// onLinkActivated 当用户单击链接时将发出此信号, 由锚引用的URL在链接中传递
				// openUrlExternally 根据用户的桌面首选项，尝试在外部应用程序中打开指定的目标url。
				// 如果成功则返回true，否则返回false。
			}
		}
	}
	Component {
		id: disconnectedVehicleSummaryComponent // 断开的飞机汇总组件
		Rectangle {
			color: "red" //qgcPal.windowShade
			QGCLabel {
				anchors.margins:        0
				anchors.fill:           parent
				verticalAlignment:      Text.AlignVCenter
				horizontalAlignment:    Text.AlignHCenter
				wrapMode:               Text.WordWrap
				font.pointSize:         ScreenTools.largeFontPointSize
				text: // 飞机设置和信息将在连接飞机后显示。
					  qsTr("Vehicle settings and info will display after connecting your vehicle.")
					  + (ScreenTools.isMobile || !_corePlugin.options.showFirmwareUpgrade ?
							 "" : "\nClick Firmware on the left to upgrade your vehicle.")
				onLinkActivated: Qt.openUrlExternally(link)
			}
		}
	}
	Component {
		id: missingParametersVehicleSummaryComponent // 缺少参数飞机摘要组件
		Rectangle {
			color: "blue" // qgcPal.windowShade
			QGCLabel {
				anchors.margins:        0
				anchors.fill:           parent
				verticalAlignment:      Text.AlignVCenter
				horizontalAlignment:    Text.AlignHCenter
				wrapMode:               Text.WordWrap
				font.pointSize:         ScreenTools.mediumFontPointSize
				text: //您当前已连接到飞机，但未返回完整参数列表。因此，整套飞行器设置选项不可用。
					  qsTr("You are currently connected to a vehicle but it did not return the full parameter list. ")
					  + qsTr("As a result, the full set of vehicle setup options are not available.")
				onLinkActivated: Qt.openUrlExternally(link)
			}
		}
	}

	// ExclusiveGroup 提供了一种将多个可检查控件声明为互斥的方法
	// 支持的几个控件为：Action, MenuItem, Button 和 RadioButton
	ExclusiveGroup { id: setupButtonGroup }

	/* Flickable 可闪烁的项目将其子节点放在可拖动和轻弹的表面上，导致对子项的视图滚动。 */
	// Flickable: QGC版本的可闪烁控制，显示水平/垂直滚动指示
	QGCFlickable {
		id:                 buttonScroll
		anchors.margins: 0
		anchors.left:           parent.left
		anchors.top:           parent.top
		//anchors.verticalCenter: parent.verticalCenter
		width: buttonColumn.width + buttonColumn.spacing
		height: buttonColumn.height <= parent.height ?  contentHeight : parent.height
		contentHeight: buttonColumn.height + buttonColumn.spacing * 2
		flickableDirection: Flickable.VerticalFlick // 垂直滚动
		clip:               true
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
				text:                   qsTr("Vehicle Setup")		// 载具设置
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
			Repeater {
				model:                  _corePlugin ? _corePlugin.settingsPages : []
				// AppSettings.qml
				// ../zcq-qgroundcontrol/src/api/QGCCorePlugin.cc
				// [0] qrc:/qml/GeneralSettings.qml						General			常规
				// [1] qrc:/qml/LinkSettings.qml						Comm Links		通讯连接
				// [2] qrc:/qml/OfflineMap.qml							Offline Maps	离线地图
				// [3] qrc:/qml/MavlinkSettings.qml						MAVLink			检测器
				// [4] qrc:/qml/QGroundControl/Controls/AppMessages.qml	Console			控制台
				// [5] qrc:/qml/HelpSettings.qml						Help			帮助
				visible:                _corePlugin && _corePlugin.options.combineSettingsAndSetup // false
				SubMenuButton {
					visible:            _corePlugin && _corePlugin.options.combineSettingsAndSetup
					exclusiveGroup:     setupButtonGroup
					imageResource:      modelData.icon
					setupIndicator:     false
					text:               modelData.title
					Layout.fillWidth:   true
					Layout.alignment: Qt.AlignHCenter
					onClicked:          showPanel(this, modelData.url)
				}
			}
			SubMenuButton {
				id:                 summaryButton
				exclusiveGroup:     setupButtonGroup
				imageResource:      "/qmlimages/VehicleSummaryIcon.png"
				setupIndicator:     false
				mytitle:               qsTr("Summary")						// 概况
				Layout.fillWidth:   true
				Layout.alignment: Qt.AlignHCenter
				onClicked:			showSummaryPanel() // 概况
			}
			SubMenuButton {
				id:                 firmwareButton
				visible:            !ScreenTools.isMobile && _corePlugin.options.showFirmwareUpgrade
				exclusiveGroup:     setupButtonGroup
				imageResource:      "/qmlimages/FirmwareUpgradeIcon.png"
				setupIndicator:     false
				mytitle:               qsTr("Firmware")					// 固件
				Layout.fillWidth:   true
				Layout.alignment: Qt.AlignHCenter
				onClicked:			showPanel(this, "FirmwareUpgrade.qml")
			}
			SubMenuButton {
				id:                 px4FlowButton
				visible:            QGroundControl.multiVehicleManager.activeVehicle ?
										QGroundControl.multiVehicleManager.activeVehicle.priorityLink.isPX4Flow : false
				exclusiveGroup:     setupButtonGroup
				setupIndicator:     false
				mytitle:               qsTr("PX4Flow")						// PX4Flow 光流摄像头
				Layout.fillWidth:   true
				Layout.alignment: Qt.AlignHCenter
				onClicked:          showPanel(this, "PX4FlowSensor.qml")
			}
			SubMenuButton {
				id:                 joystickButton
				visible:            _fullParameterVehicleAvailable && joystickManager.joysticks.length !== 0
				exclusiveGroup:     setupButtonGroup
				setupComplete:      joystickManager.activeJoystick ?
										joystickManager.activeJoystick.calibrated : false
				setupIndicator:     true
				mytitle:               qsTr("Joystick")					// 游戏手柄
				Layout.fillWidth:   true
				Layout.alignment: Qt.AlignHCenter
				onClicked:          showPanel(this, "JoystickConfig.qml")
			}
			Repeater {
				id:     componentRepeater
				model:  _fullParameterVehicleAvailable ?
							QGroundControl.multiVehicleManager.activeVehicle.autopilot.vehicleComponents : 0
				/*	src/AutoPilotPlugins/PX4/PX4AutoPilotPlugin.cc :
					const QVariantList& PX4AutoPilotPlugin::vehicleComponents(void)
						src/AutoPilotPlugins/PX4/AirframeComponent.qml			机架
						src/AutoPilotPlugins/PX4/SensorsComponent.qml			传感器
						src/AutoPilotPlugins/Common/RadioComponent.qml			遥控器
						src/AutoPilotPlugins/PX4/PX4FlightModes.qml				飞行模式
						src/AutoPilotPlugins/PX4/PowerComponent.qml				电源
						src/AutoPilotPlugins/Common/MotorComponent.qml			电机
						src/AutoPilotPlugins/PX4/SafetyComponent.qml			安全
						src/AutoPilotPlugins/PX4/PX4TuningComponentPlane.qml	调参
						src/AutoPilotPlugins/PX4/PX4TuningComponentCopter.qml	调参 ok
						src/AutoPilotPlugins/PX4/PX4TuningComponentVTOL.qml		调参
						src/AutoPilotPlugins/PX4/CameraComponent.qml			相机 */
				SubMenuButton {
					visible:            modelData.setupSource.toString() !== ""
					exclusiveGroup:     setupButtonGroup
					imageResource:      modelData.iconResource
					setupIndicator:     modelData.requiresSetup
					setupComplete:      modelData.setupComplete
					mytitle:               modelData.name
					Layout.fillWidth:   true
					Layout.alignment: Qt.AlignHCenter
					onClicked:          showVehicleComponentPanel(modelData) //
				}
			}
			SubMenuButton {
				visible:            QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable
									&& !QGroundControl.multiVehicleManager.activeVehicle.highLatencyLink
									&& _corePlugin.showAdvancedUI
				exclusiveGroup:     setupButtonGroup
				setupIndicator:     false
				mytitle:               qsTr("Parameters")					// 参数
				Layout.fillWidth:   true
				Layout.alignment: Qt.AlignHCenter
				onClicked:          showPanel(this, "SetupParameterEditor.qml") // ParameterEditor.qml
			}
		}
	}
	Rectangle {
		id: bar_vertical
		anchors.margins: 0
		anchors.top:            buttonScroll.top
		anchors.bottom:         buttonScroll.bottom
		anchors.left:           buttonScroll.right
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
			function setSource(source, vehicleComponent) {
				panelLoader.source = ""
				panelLoader.vehicleComponent = vehicleComponent
				panelLoader.source = source
			}
			function setSourceComponent(sourceComponent, vehicleComponent) {
				panelLoader.sourceComponent = undefined
				panelLoader.vehicleComponent = vehicleComponent
				panelLoader.sourceComponent = sourceComponent
			}
			property var vehicleComponent
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
