//SetupView.qml : 概况

import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4

import QGroundControl                       1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette               1.0

import QGroundControl.Zcq_debug     1.0

Rectangle {
	id:             _summaryRoot
	anchors.margins: 0
	anchors.fill:   parent
	color:          qgcPal.window
	property real _minSummaryW: ScreenTools.isTinyScreen ?
									ScreenTools.defaultFontPixelWidth * 20 :
									ScreenTools.defaultFontPixelWidth * 28
	property real _summaryBoxWidth: _minSummaryW
	property real _summaryBoxSpace: 0
	Zcq_debug { id : zcq }
	readonly property string zcqfile: " -------- VehicleSummary.qml 概况"
	QGCPalette {  // 字体和调色板
		id:                 qgcPal
		colorGroupEnabled:  enabled
	}
	function capitalizeWords(sentence) {
		return sentence.replace(/(?:^|\s)\S/g, function(a){ return a.toUpperCase(); } );
	}
	function computeSummaryBoxSize() {
		var sw  = 0
		var rw  = 0
		var idx = Math.floor(_summaryRoot.width / _minSummaryW)
		if(idx < 1) {
			_summaryBoxWidth = _summaryRoot.width
			_summaryBoxSpace = 0
		} else {
			_summaryBoxSpace = 0
			if(idx > 1) {
				_summaryBoxSpace = 8 // ScreenTools.defaultFontPixelWidth
				sw = _summaryBoxSpace * (idx - 1)
			}
			rw = _summaryRoot.width - sw
			_summaryBoxWidth = rw / idx
		}
	}
	Component.onCompleted: {
		zcq.echo("Component.onCompleted" + zcqfile)
		computeSummaryBoxSize()
	}
	onWidthChanged: {
		computeSummaryBoxSize()
	}
	/* Flickable 可闪烁的项目将其子节点放在可拖动和轻弹的表面上，导致对子项的视图滚动。 */
	// Flickable: QGC版本的可闪烁控制，显示水平/垂直滚动指示
	QGCFlickable {
		anchors.margins: 0
		anchors.fill:       parent
		contentHeight:      summaryColumn.height
		flickableDirection: Flickable.VerticalFlick // 垂直滚动
		clip:               true
		Column {
			id:             summaryColumn
			width:          parent.width
			spacing:        0
			anchors.margins: 0
			QGCLabel {
				width:			parent.width
				wrapMode:		Text.WordWrap
				color:			setupComplete ? qgcPal.text : qgcPal.warningText
				font.family:    ScreenTools.demiboldFontFamily
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				// 您将会从以下信息框中看到飞机设置的概况。左边是每个组件的设置菜单。
				// 警告：你的飞机在起飞前应该被正确配置。请检查左侧菜单红色标记的项目。
				text:           setupComplete ?
									qsTr("Below you will find a summary of the settings for your vehicle. To the left are the setup menus for each component.") : qsTr("WARNING: Your vehicle requires setup prior to flight. Please resolve the items marked in red using the menu on the left.")
				property bool setupComplete: QGroundControl.multiVehicleManager.activeVehicle ?
												 QGroundControl.multiVehicleManager.activeVehicle.autopilot.setupComplete :
												 false
			}
			Flow { // Flow 将其子项自动排定，必要时进行换行，以创建项目的行或列
				id:         _flowCtl
				anchors.margins: 0
				width:      parent.width
				spacing:    _summaryBoxSpace
				Repeater {
					model: QGroundControl.multiVehicleManager.activeVehicle ?
							   QGroundControl.multiVehicleManager.activeVehicle.autopilot.vehicleComponents : undefined
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
							src/AutoPilotPlugins/PX4/PX4TuningComponentCopter.qml	调参
							src/AutoPilotPlugins/PX4/PX4TuningComponentVTOL.qml		调参
							src/AutoPilotPlugins/PX4/CameraComponent.qml			相机 */
					Rectangle {
						anchors.margins: 0
						width:      _summaryBoxWidth
						height:     ScreenTools.defaultFontPixelHeight * 13
						color:      qgcPal.windowShade
						visible:    modelData.summaryQmlSource.toString() !== ""
						border.width: 1
						border.color: qgcPal.text
						radius: 2
						Component.onCompleted: {
							border.color = Qt.rgba(border.color.r, border.color.g, border.color.b, 0.1)
						}
						QGCButton {						// Title bar
							id:     titleBar
							anchors.margins: 0
							width:  parent.width
							text:   capitalizeWords(modelData.name)
							// Setup indicator
							Rectangle {
								visible:                modelData.requiresSetup && modelData.setupSource !== ""
								anchors.rightMargin:    ScreenTools.defaultFontPixelWidth
								anchors.right:          parent.right
								anchors.verticalCenter: parent.verticalCenter
								height:                 titleBar.height - 6
								width:                  height // ScreenTools.defaultFontPixelWidth * 1.40
								radius:                 width / 2
								color:                  modelData.setupComplete ? "green" : "red"
								opacity: 1 // 透明度
								border.width: 0
							}
							onClicked : {
								//console.log(modelData.setupSource)
								if (modelData.setupSource !== "") {
									setupView.showVehicleComponentPanel(modelData)
								}
							}
						}
						Rectangle {						// Summary Qml
							anchors.margins: 0
							anchors.top:    titleBar.bottom
							width:          parent.width
							Loader {
								anchors.fill:       parent
								anchors.margins:    8
								source:             modelData.summaryQmlSource
								/*	summaryQmlSource() :
										AirframeComponentSummary.qml		机架
										SensorsComponentSummary.qml			传感器
										PX4RadioComponentSummary.qml		遥控器
										FlightModesComponentSummary.qml		飞行模式
										PowerComponentSummary.qml			电源
										""									电机
										SafetyComponentSummary.qml			安全
										""									调参
										CameraComponentSummary.qml			相机 */
							}
						}
					}
				}
			}
		}
	}
}
