//SetupView.qml : Repeater : model
//	src/AutoPilotPlugins/PX4/PX4AutoPilotPlugin.cc :
//	const QVariantList& PX4AutoPilotPlugin::vehicleComponents(void)
//		src/AutoPilotPlugins/Common/RadioComponent.qml			遥控器

import QtQuick          2.3
import QtQuick.Controls 2.4
import QtQuick.Dialogs  1.2
import QtQuick.Layouts  1.11

import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Palette       1.0

SetupPage {
	id:             radioPage
	pageComponent:  pageComponent
	Component {
		id: pageComponent
		Item {
			width:  availableWidth
			height: availableHeight // Math.max(leftColumn.height, rightColumn.height)
			readonly property string  dialogTitle: qsTr("Radio") // 遥控器
			function setupPageCompleted() {
				controller.start()
				updateChannelCount()
			}
			function updateChannelCount()     { }
			QGCPalette { id: qgcPal; colorGroupEnabled: radioPage.enabled }
			RadioComponentController {
				id:             controller
				statusText:     statusText
				cancelButton:   cancelButton
				nextButton:     nextButton
				skipButton:     skipButton
				onChannelCountChanged:              updateChannelCount()
				onFunctionMappingChangedAPMReboot: mainWindow.showMessageDialog(qsTr("Reboot required"),
																				//需要重启
																				qsTr("Your stick mappings have changed, you must reboot the vehicle for correct operation."))//你的摇杆映射已经被修改，你必须重启飞机以便正确操作。
				onThrottleReversedCalFailure: mainWindow.showMessageDialog(qsTr("Throttle channel reversed"),
																		   //油门通道反向
																		   qsTr("Calibration failed. The throttle channel on your transmitter is reversed. You must correct this on your transmitter in order to complete calibration."))
				//校准失败。您遥控器上的油门通道已反向。你需要在你的发射机上修正这个问题来完成校准。
			}

			Component {
				id: copyTrimsDialogComponent
				QGCViewMessage {
					message: qsTr("Center your sticks and move throttle all the way down, then press Ok to copy trims. After pressing Ok, reset the trims on your radio back to zero.")
					//将遥控器摇杆居中并将油门放到最低位置，然后按确定开始复制微调量。按“确定”后，将遥控器上的微调设为0。
					function accept() {
						hideDialog()
						controller.copyTrims()
					}
				}
			}

			Component {
				id: zeroTrimsDialogComponent
				QGCViewMessage {
					/* 在校准之前，你应该把所有的微调和辅助微调量设为零。单击“确定”开始校准。
					  请确保断开所有电机电源，并且从飞机上卸下所有螺旋桨。*/
					message: qsTr("Before calibrating you should zero all your trims and subtrims.\nClick Ok to start Calibration.\n%1").arg((QGroundControl.multiVehicleManager.activeVehicle.px4Firmware ? "" : qsTr("Please ensure all motor power is disconnected AND all props are removed from the vehicle.")))
					function accept() {
						hideDialog()
						controller.nextButtonClicked()
					}
				}
			}

			Component {
				id: channelCountDialogComponent
				QGCViewMessage {
					//请打开发射机。需要%1个或者更多通道以进行飞行。
					message: controller.channelCount == 0 ? qsTr("Please turn on transmitter.") :
															qsTr("%1 channels or more are needed to fly.").arg(controller.minChannelCount)
				}
			}

			Component {
				id: spektrumBindDialogComponent // 绑定对话框组件
				QGCViewDialog {
					function accept() {
						controller.spektrumBindMode(radioGroup.current.bindMode)
						hideDialog()
					}
					function reject() {
						hideDialog()
					}
					Column {
						anchors.fill:   parent
						spacing:        5
						QGCLabel {
							width:      parent.width
							wrapMode:   Text.WordWrap
							//单击“确定”将 Spektrum 接收机置于对频（bind）模式下。在下面选择接收机类型:
							text:       qsTr("Click Ok to place your Spektrum receiver in the bind mode. Select the specific receiver type below:")
						}
						QGCRadioButton {
							text:       qsTr("DSM2 Mode")	//DSM2 模式
							property int bindMode: RadioComponentController.DSM2
						}
						QGCRadioButton {
							text:       qsTr("DSMX (7 channels or less)")	//DSMX（7通道或更少）
							property int bindMode: RadioComponentController.DSMX7
						}
						QGCRadioButton {
							checked:    true
							text:       qsTr("DSMX (8 channels or more)")
							property int bindMode: RadioComponentController.DSMX8
						}
					}
				}
			} // Component - spektrumBindDialogComponent

			Component {
				id: channelMonitorDisplayComponent // 通道监控显示组件
				Item {
					property int			rcValue:		1500
					//					property int            __lastRcValue:  1500
					//					readonly property int   __rcValueMaxJitter: 2
					readonly property int	_pwmMin:		1000 - 60
					readonly property int	_pwmMax:		2000 + 60
					readonly property int	_pwmRange:		_pwmMax - _pwmMin
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
						id: indicator
						visible:                mapped
						anchors.verticalCenter: parent.verticalCenter
						height:                 bar.height * 1.6
						width:					height
						radius: height * 0.5
						color:                  "red" //qgcPal.text
						border.width: 0
						opacity: 1 // 透明度
						x: ( (reversed ? _pwmMax - rcValue : rcValue - _pwmMin) / _pwmRange )
						   * parent.width - (width / 2)
					}
					// Center point
					Rectangle {
						anchors.verticalCenter: parent.verticalCenter
						anchors.horizontalCenter:   parent.horizontalCenter
						width:                      1
						height:                     indicator.height
						color:                      "white" //qgcPal.window
						border.width: 0
						opacity: 1 // 透明度
						//radius: 2
					}
					QGCLabel {
						visible:                !mapped
						anchors.fill:           parent
						horizontalAlignment:    Text.AlignHCenter
						verticalAlignment:      Text.AlignVCenter
						text:                   qsTr("Not Mapped")//未映射
						color:                  "pink" //qgcPal.window
					}
				}
			}

			/* Flickable 可闪烁的项目将其子节点放在可拖动和轻弹的表面上，导致对子项的视图滚动。 */
			// Flickable: QGC版本的可闪烁控制，显示水平/垂直滚动指示
			QGCFlickable {
				anchors.margins: 0
				anchors.fill:   parent
				clip:           true
				contentWidth: rightColumn.x + rightColumn.width
				//contentWidth:   leftColumn.width + columnSpacer.width + rightColumn.width
				contentHeight:  Math.max(leftColumn.height, rightColumn.height)
				Column {			// Left side column
					id:             leftColumn
					anchors.left:   parent.left
					spacing:        10
					Column { // Attitude Controls 姿态控制
						id: zcq_Column_Attitude_Controls
						spacing:    5
						QGCLabel {	text: qsTr("Attitude Controls")		}  /*姿态控制*/
						property real adapt_width: 0
						Component.onCompleted: {
							if (rollLabel.implicitWidth > adapt_width) adapt_width = rollLabel.implicitWidth
																	   + defaultTextWidth
							if (pitchLabel.implicitWidth > adapt_width) adapt_width = pitchLabel.implicitWidth
																		+ defaultTextWidth
							if (yawLabel.implicitWidth > adapt_width) adapt_width = yawLabel.implicitWidth
																	  + defaultTextWidth
							if (throttleLabel.implicitWidth > adapt_width) adapt_width = throttleLabel.implicitWidth
																		   + defaultTextWidth
						}
						property real attitude_width: 200
						Item {
							width:  parent.width
							height: rollLabel.height // defaultTextHeight * 2
							QGCLabel {
								id:     rollLabel
								anchors.verticalCenter: parent.verticalCenter
								width:  zcq_Column_Attitude_Controls.adapt_width
								verticalAlignment: Text.AlignVCenter
								text:   qsTr("Roll")//横滚
							}
							Loader {
								id:                 rollLoader
								anchors.left:       rollLabel.right
								anchors.verticalCenter: parent.verticalCenter
								height:             parent.height
								width: zcq_Column_Attitude_Controls.attitude_width
								sourceComponent:    channelMonitorDisplayComponent // 通道监控显示组件
								property real defaultTextWidth: defaultTextWidth
								property bool mapped:           controller.rollChannelMapped
								property bool reversed:         controller.rollChannelReversed
							}
							QGCLabel {
								id:     zcq_rollLabel
								anchors.leftMargin: 5
								anchors.left:    rollLoader.right
								anchors.verticalCenter: parent.verticalCenter
								verticalAlignment: Text.AlignVCenter
								color: "yellow"
							}
							Connections {
								target: controller
								onRollChannelRCValueChanged: {
									rollLoader.item.rcValue = rcValue
									zcq_rollLabel.text = rcValue
								}
							}
						}
						Item {
							width:  parent.width
							height: rollLabel.height // defaultTextHeight * 2
							QGCLabel {
								id:     pitchLabel
								width:  zcq_Column_Attitude_Controls.adapt_width
								text:   qsTr("Pitch")//俯仰
							}
							Loader {
								id:                 pitchLoader
								anchors.left:       pitchLabel.right
								anchors.verticalCenter: parent.verticalCenter
								height:             parent.height
								width: zcq_Column_Attitude_Controls.attitude_width
								sourceComponent:    channelMonitorDisplayComponent // 通道监控显示组件
								property real defaultTextWidth: defaultTextWidth
								property bool mapped:           controller.pitchChannelMapped
								property bool reversed:         controller.pitchChannelReversed
							}
							QGCLabel {
								id:     zcq_pitchLoader
								anchors.leftMargin: 5
								anchors.left:       pitchLoader.right
								anchors.verticalCenter: parent.verticalCenter
								verticalAlignment: Text.AlignVCenter
								color: "yellow"
							}
							Connections {
								target: controller
								onPitchChannelRCValueChanged: {
									pitchLoader.item.rcValue = rcValue
									zcq_pitchLoader.text = rcValue
								}
							}
						}
						Item {
							width:  parent.width
							height: rollLabel.height // defaultTextHeight * 2
							QGCLabel {
								id:     yawLabel
								width:  zcq_Column_Attitude_Controls.adapt_width
								text:   qsTr("Yaw")//偏航
							}
							Loader {
								id:                 yawLoader
								anchors.left:       yawLabel.right
								anchors.verticalCenter: parent.verticalCenter
								height:             parent.height
								width: zcq_Column_Attitude_Controls.attitude_width
								sourceComponent:    channelMonitorDisplayComponent // 通道监控显示组件
								property real defaultTextWidth: defaultTextWidth
								property bool mapped:           controller.yawChannelMapped
								property bool reversed:         controller.yawChannelReversed
							}
							QGCLabel {
								id:     zcq_yawLoader
								anchors.leftMargin: 5
								anchors.left:       yawLoader.right
								anchors.verticalCenter: parent.verticalCenter
								verticalAlignment: Text.AlignVCenter
								color: "yellow"
							}
							Connections {
								target: controller
								onYawChannelRCValueChanged: {
									yawLoader.item.rcValue = rcValue
									zcq_yawLoader.text = rcValue
								}
							}
						}
						Item {
							width:  parent.width
							height: rollLabel.height // defaultTextHeight * 2
							QGCLabel {
								id:     throttleLabel
								width:  zcq_Column_Attitude_Controls.adapt_width
								text:   qsTr("Throttle")//油门
							}
							Loader {
								id:                 throttleLoader
								anchors.left:       throttleLabel.right
								anchors.verticalCenter: parent.verticalCenter
								height:             parent.height
								width: zcq_Column_Attitude_Controls.attitude_width
								sourceComponent:    channelMonitorDisplayComponent // 通道监控显示组件
								property real defaultTextWidth: defaultTextWidth
								property bool mapped:           controller.throttleChannelMapped
								property bool reversed:         controller.throttleChannelReversed
							}
							QGCLabel {
								id:     zcq_throttleLabel
								anchors.leftMargin: 5
								anchors.left:       throttleLoader.right
								anchors.verticalCenter: parent.verticalCenter
								verticalAlignment: Text.AlignVCenter
								color: "yellow"
							}
							Connections {
								target:  controller
								onThrottleChannelRCValueChanged: {
									throttleLoader.item.rcValue = rcValue
									zcq_throttleLabel.text = rcValue
								}
							}
						}
					} // Column - Attitude Control labels
					Row { // Command Buttons
						spacing: 10
						QGCButton {
							id:         skipButton
							text:       qsTr("Skip")//跳过
							onClicked:  controller.skipButtonClicked()
						}
						QGCButton {
							id:         cancelButton
							text:       qsTr("Cancel")//取消
							onClicked:  controller.cancelButtonClicked()
						}
						QGCButton {
							id:         nextButton
							primary:    true
							text:       qsTr("Calibrate")//校准
							onClicked: {
								if (text === qsTr("Calibrate")) {
									mainWindow.showComponentDialog(zeroTrimsDialogComponent,
																   dialogTitle, // 遥控器
																   mainWindow.showDialogDefaultWidth,
																   StandardButton.Ok | StandardButton.Cancel)
								} else {
									controller.nextButtonClicked()
								}
							}
						}
					} // Row - Buttons
					QGCLabel {				// Status Text
						id:         statusText
						width:      parent.width
						wrapMode:   Text.WordWrap
					}
					Rectangle {
						width:          parent.width
						height:         1
						border.color:   qgcPal.text
						border.width:   1
					}
					QGCLabel { text: qsTr("Additional Radio setup:") }//其他遥控器设置：
					Column {
						id:                 switchSettingsGrid
						//anchors.left:       parent.left
						//anchors.right:      parent.right
						spacing:			5 // ScreenTools.defaultFontPixelWidth
						property real my_width_QGCLabel: 0
						property real my_width_FactComboBox: 0
						Repeater {
							model: QGroundControl.multiVehicleManager.activeVehicle.px4Firmware ?
									   (QGroundControl.multiVehicleManager.activeVehicle.multiRotor ?
											[ "RC_MAP_AUX1", "RC_MAP_AUX2", "RC_MAP_PARAM1",
											 "RC_MAP_PARAM2", "RC_MAP_PARAM3"] :
											[ "RC_MAP_FLAPS", "RC_MAP_AUX1", "RC_MAP_AUX2",
											 "RC_MAP_PARAM1", "RC_MAP_PARAM2", "RC_MAP_PARAM3"]) : 0
							Row {
								property Fact fact: controller.getParameterFact(-1, modelData)
								Component.onCompleted: {
									if (switchSet_Label.implicitWidth > switchSettingsGrid.my_width_QGCLabel)
										switchSettingsGrid.my_width_QGCLabel = switchSet_Label.implicitWidth
												+ ScreenTools.defaultFontPixelWidth
									if (switchSet_FactComboBox.implicitWidth > switchSettingsGrid.my_width_FactComboBox)
										switchSettingsGrid.my_width_FactComboBox = switchSet_FactComboBox.implicitWidth
												+ ScreenTools.defaultFontPixelWidth
								}
								QGCLabel {
									id: switchSet_Label
									anchors.verticalCenter: parent.verticalCenter
									width:  switchSettingsGrid.my_width_QGCLabel
									text:               fact.shortDescription
								}
								FactComboBox {
									id: switchSet_FactComboBox
									//centeredLabel: true
									anchors.verticalCenter: parent.verticalCenter
//									height: implicitHeight + 5
									width:  switchSettingsGrid.my_width_FactComboBox
									fact:       parent.fact
									indexModel: false
								}
							}
						}
					} // GridLayout
					RowLayout {
						spacing:        10
						QGCButton {
							id:         bindButton
							text:       qsTr("Spektrum Bind")//Spektrum 对频
							onClicked:  mainWindow.showComponentDialog(spektrumBindDialogComponent,
																	   dialogTitle, // 遥控器
																	   mainWindow.showDialogDefaultWidth,
																	   StandardButton.Ok | StandardButton.Cancel)
						}
						QGCButton {
							text:       qsTr("Copy Trims")//复制微调量
							onClicked:  mainWindow.showComponentDialog(copyTrimsDialogComponent,
																	   dialogTitle, // 遥控器
																	   mainWindow.showDialogDefaultWidth,
																	   StandardButton.Ok | StandardButton.Cancel)
						}
					} // RowLayout
				} // Column - Left Column

				Item {
					id:             columnSpacer
					anchors.left:  leftColumn.right
					width:          15
					height:		1
				}

				Column {			// Right side column
					id:             rightColumn
					anchors.top:    parent.top
					anchors.left:  columnSpacer.right
					width:         rightColumn_row.width
					spacing:        ScreenTools.defaultFontPixelWidth
					Row {
						id:  rightColumn_row
						spacing: ScreenTools.defaultFontPixelWidth
						QGCRadioButton {
							text:       qsTr("Mode 1")//模式1（日本手）
							checked:    controller.transmitterMode == 1
							onClicked:  controller.transmitterMode = 1
						}
						QGCRadioButton {
							text:       qsTr("Mode 2")//模式2（美国手）
							checked:    controller.transmitterMode == 2
							onClicked:  controller.transmitterMode = 2
						}
					}
					Image {
						width:      parent.width
						fillMode:   Image.PreserveAspectFit
						smooth:     true
						source:     controller.imageHelp
					}
					RCChannelMonitor {
						width:      parent.width
						twoColumn:  true
					}
				} // Column - Right Column
			}
		} // Item

	} // Component - pageComponent

} // SetupPage
