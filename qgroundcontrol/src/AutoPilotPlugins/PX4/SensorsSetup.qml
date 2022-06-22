//SetupView.qml : Repeater : model
//	src/AutoPilotPlugins/PX4/PX4AutoPilotPlugin.cc :
//	const QVariantList& PX4AutoPilotPlugin::vehicleComponents(void)
//		src/AutoPilotPlugins/PX4/SensorsComponent.qml			传感器

import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2

import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0

/// Page for sensor calibration. This control is used within the SensorsComponent control and can also be used
/// standalone for custom uis. When using standardalone you can use the various show* bools to show/hide what you want.
Item {
	id: _root

	property bool   showSensorCalibrationCompass:   true    ///< true: Show this calibration button
	property bool   showSensorCalibrationGyro:      true    ///< true: Show this calibration button
	property bool   showSensorCalibrationAccel:     true    ///< true: Show this calibration button
	property bool   showSensorCalibrationLevel:     true    ///< true: Show this calibration button
	property bool   showSensorCalibrationAirspeed:  true    ///< true: Show this calibration button
	property bool   showSetOrientations:            true    ///< true: Show this calibration button
	property bool   showNextButton:                 false   ///< true: Show Next button which will signal nextButtonClicked

	signal nextButtonClicked

	// Help text which is shown both in the status text area prior to pressing a cal button and in the
	// pre-calibration dialog.

	readonly property string boardRotationText: qsTr("If the orientation is in the direction of flight, select ROTATION_NONE.") // 如果方向正是飞行方向，请选择 ROTATION_NONE。
	readonly property string compassRotationText: qsTr("If the orientation is in the direction of flight, select ROTATION_NONE.")

	readonly property string compassHelp:   qsTr("For Compass calibration you will need to rotate your vehicle through a number of positions.\nClick Ok to start calibration.")//要校准罗盘，你需要在几个不同的位置旋转你的飞机。
	readonly property string gyroHelp:      qsTr("For Gyroscope calibration you will need to place your vehicle on a surface and leave it still.\nClick Ok to start calibration.")//要校准陀螺仪，你需要将你的飞机放在平面上，并保持静止。
	readonly property string accelHelp:     qsTr("For Accelerometer calibration you will need to place your vehicle on all six sides on a perfectly level surface and hold it still in each orientation for a few seconds.\n\nClick Ok to start calibration.")//要校准加速度计，你需要将你的飞机6个面分别置于水平位置上，并静止数秒。点击“OK”开始校准
	readonly property string levelHelp:     qsTr("To level the horizon you need to place the vehicle in its level flight position and press OK.")//要校平地平线，你需要将飞机置于平飞位置，然后点OK。
	readonly property string airspeedHelp:  qsTr("For Airspeed calibration you will need to keep your airspeed sensor out of any wind and then blow across the sensor. Do not touch the sensor or obstruct any holes during the calibration.")
	//在校准空速计时，您需要保持没有任何风吹过传感器。在校准过程中，请勿触摸传感器或堵塞任何孔。
	readonly property string statusTextAreaDefaultText: qsTr("Start the individual calibration steps by clicking one of the buttons to the left.")//通过单击左侧的按钮开始各个校准步骤。

	// Used to pass what type of calibration is being performed to the preCalibrationDialog
	property string preCalibrationDialogType

	// Used to pass help text to the preCalibrationDialog dialog
	property string preCalibrationDialogHelp

	readonly property int rotationColumnWidth: ScreenTools.defaultFontPixelWidth * 30
	readonly property var rotations: [
		"ROTATION_NONE",
		"ROTATION_YAW_45",
		"ROTATION_YAW_90",
		"ROTATION_YAW_135",
		"ROTATION_YAW_180",
		"ROTATION_YAW_225",
		"ROTATION_YAW_270",
		"ROTATION_YAW_315",
		"ROTATION_ROLL_180",
		"ROTATION_ROLL_180_YAW_45",
		"ROTATION_ROLL_180_YAW_90",
		"ROTATION_ROLL_180_YAW_135",
		"ROTATION_PITCH_180",
		"ROTATION_ROLL_180_YAW_225",
		"ROTATION_ROLL_180_YAW_270",
		"ROTATION_ROLL_180_YAW_315",
		"ROTATION_ROLL_90",
		"ROTATION_ROLL_90_YAW_45",
		"ROTATION_ROLL_90_YAW_90",
		"ROTATION_ROLL_90_YAW_135",
		"ROTATION_ROLL_270",
		"ROTATION_ROLL_270_YAW_45",
		"ROTATION_ROLL_270_YAW_90",
		"ROTATION_ROLL_270_YAW_135",
		"ROTATION_PITCH_90",
		"ROTATION_PITCH_270",
		"ROTATION_ROLL_270_YAW_270",
		"ROTATION_ROLL_180_PITCH_270",
		"ROTATION_PITCH_90_YAW_180",
		"ROTATION_ROLL_90_PITCH_90"
	]

	property Fact cal_mag0_id:      controller.getParameterFact(-1, "CAL_MAG0_ID")
	property Fact cal_mag1_id:      controller.getParameterFact(-1, "CAL_MAG1_ID")
	property Fact cal_mag2_id:      controller.getParameterFact(-1, "CAL_MAG2_ID")
	property Fact cal_mag0_rot:     controller.getParameterFact(-1, "CAL_MAG0_ROT")
	property Fact cal_mag1_rot:     controller.getParameterFact(-1, "CAL_MAG1_ROT")
	property Fact cal_mag2_rot:     controller.getParameterFact(-1, "CAL_MAG2_ROT")

	property Fact cal_gyro0_id:     controller.getParameterFact(-1, "CAL_GYRO0_ID")
	property Fact cal_acc0_id:      controller.getParameterFact(-1, "CAL_ACC0_ID")

	property Fact sens_board_rot:   controller.getParameterFact(-1, "SENS_BOARD_ROT")
	property Fact sens_board_x_off: controller.getParameterFact(-1, "SENS_BOARD_X_OFF")
	property Fact sens_board_y_off: controller.getParameterFact(-1, "SENS_BOARD_Y_OFF")
	property Fact sens_board_z_off: controller.getParameterFact(-1, "SENS_BOARD_Z_OFF")
	property Fact sens_dpres_off:   controller.getParameterFact(-1, "SENS_DPRES_OFF")

	// Id > = signals compass available, rot < 0 signals internal compass
	property bool showCompass0Rot: cal_mag0_id.value > 0 && cal_mag0_rot.value >= 0
	property bool showCompass1Rot: cal_mag1_id.value > 0 && cal_mag1_rot.value >= 0
	property bool showCompass2Rot: cal_mag2_id.value > 0 && cal_mag2_rot.value >= 0

	property bool   _sensorsHaveFixedOrientation:   QGroundControl.corePlugin.options.sensorsHaveFixedOrientation
	property bool   _wifiReliableForCalibration:    QGroundControl.corePlugin.options.wifiReliableForCalibration
	property int    _buttonWidth:                   ScreenTools.defaultFontPixelWidth * 12

	Component.onCompleted: {
		var usingUDP = controller.usingUDPLink()
		if (usingUDP && !_wifiReliableForCalibration) {
			// 全局 简单 消息对话框
			mainWindow.showMessageDialog(qsTr("Sensor Calibration"),//传感器校准
										 qsTr("Performing sensor calibration over a WiFi connection is known to be unreliable. You should disconnect and perform calibration using a direct USB connection instead."))
			//用WiFi连接的方式校准传感器已被证实是不可靠的。你应该断开连接并使用USB直接连接。
		}
	}

	// --------------------------------------------------------------------

	SensorsComponentController {
		id:                         controller
		statusLog:                  statusTextArea
		progressBar:                progressBar

		compassButton:              compassButton
		gyroButton:                 gyroButton
		accelButton:                accelButton
		airspeedButton:             airspeedButton
		levelButton:                levelButton
		cancelButton:               cancelButton
		setOrientationsButton:      setOrientationsButton

		orientationCalAreaHelpText: orientationCalAreaHelpText

		onResetStatusTextArea: statusLog.text = statusTextAreaDefaultText // 通过单击左侧的按钮开始各个校准步骤。
		onMagCalComplete: {
			setOrientationsDialogShowBoardOrientation = false
			mainWindow.showComponentDialog(setOrientationsDialogComponent,
										   qsTr("Compass Calibration Complete"),	//磁罗盘校准完成
										   mainWindow.showDialogDefaultWidth,
										   StandardButton.Ok)
		}
		onWaitingForCancelChanged: {
			if (controller.waitingForCancel) {
				mainWindow.showComponentDialog(waitForCancelDialogComponent,
											   qsTr("Calibration Cancel"),	//校准取消
											   mainWindow.showDialogDefaultWidth, 0)
			}
		}
	}

	// --------------------------------------------------------------------

	Component {
		id: waitForCancelDialogComponent // 取消对话框组件
		QGCViewMessage {
			//等待飞机响应以取消。需要等待几秒钟。
			message: qsTr("Waiting for Vehicle to response to Cancel. This may take a few seconds.")
			Connections {
				target: controller
				onWaitingForCancelChanged: {
					if (!controller.waitingForCancel) {
						hideDialog()
					}
				}
			}
		}
	}

	Component {
		id: preCalibrationDialogComponent // 预校准对话框组件
		QGCViewDialog {
			id: preCalibrationDialog
			function accept() {
				if (preCalibrationDialogType == "gyro") {
					controller.calibrateGyro()
				} else if (preCalibrationDialogType == "accel") {
					controller.calibrateAccel()
				} else if (preCalibrationDialogType == "level") {
					controller.calibrateLevel()
				} else if (preCalibrationDialogType == "compass") {
					controller.calibrateCompass()
				} else if (preCalibrationDialogType == "airspeed") {
					controller.calibrateAirspeed()
				}
				preCalibrationDialog.hideDialog()
			}
			Column {
				anchors.margins: 0
				anchors.fill:   parent
				spacing:        ScreenTools.defaultFontPixelHeight
				Column {
					width:          parent.width
					spacing:        5
					visible:        !_sensorsHaveFixedOrientation
					QGCLabel {
						id:         boardRotationHelp
						width:      parent.width
						wrapMode:   Text.WordWrap
						visible:    (preCalibrationDialogType != "airspeed") && (preCalibrationDialogType != "gyro")
						text:       qsTr("Set autopilot orientation before calibrating.")
						//在校准之前请设置自动驾驶仪方向。
					}
					Column {
						visible:    boardRotationHelp.visible
						QGCLabel { text: qsTr("Autopilot Orientation:") }//自动驾驶仪方向：
						FactComboBox {
							id:     boardRotationCombo
							width:  rotationColumnWidth;
							model:  rotations
							fact:   sens_board_rot
						}
					}
				}
				QGCLabel {
					width:      parent.width
					wrapMode:   Text.WordWrap
					text:       preCalibrationDialogHelp
				}
			}
		}
	}

	property bool setOrientationsDialogShowBoardOrientation: true
	Component {
		id: setOrientationsDialogComponent // 设置方向对话框组件
		QGCViewDialog {
			id: setOrientationsDialog
			QGCFlickable {
				anchors.fill:   parent
				contentHeight:  columnLayout.height
				clip:           true
				Column {
					id:                 columnLayout
					anchors.margins:    ScreenTools.defaultFontPixelWidth
					anchors.left:       parent.left
					anchors.right:      parent.right
					anchors.top:        parent.top
					spacing:            ScreenTools.defaultFontPixelHeight
					QGCLabel {
						width:      parent.width
						wrapMode:   Text.WordWrap
						//确保在飞行前重启飞机。
						//在下方设置你的罗盘方向，并确保起飞前重启飞机。
						text:       _sensorsHaveFixedOrientation ?
										qsTr("Make sure to reboot the vehicle prior to flight.") :
										qsTr("Set your compass orientations below and the make sure to reboot the vehicle prior to flight.")
					}
					QGCButton {
						text: qsTr("Reboot Vehicle")//重启设备
						onClicked: {
							controller.vehicle.rebootVehicle()
							hideDialog()
						}
					}
					QGCLabel {
						width:      parent.width
						wrapMode:   Text.WordWrap
						text:       boardRotationText
						visible:    !_sensorsHaveFixedOrientation
					}
					Column {
						visible: setOrientationsDialogShowBoardOrientation
						QGCLabel {
							text: qsTr("Autopilot Orientation:")//自动驾驶仪方向：
						}
						FactComboBox {
							id:     boardRotationCombo
							width:  rotationColumnWidth;
							model:  rotations
							fact:   sens_board_rot
						}
					}
					// Compass 0 rotation
					Column {
						visible: !_sensorsHaveFixedOrientation
						Component {
							id: compass0ComponentLabel2
							QGCLabel {
								text: qsTr("External Compass Orientation:")//外置磁罗盘方向：
							}
						}
						Component {
							id: compass0ComponentCombo2
							FactComboBox {
								id:     compass0RotationCombo
								width:  rotationColumnWidth
								model:  rotations
								fact:   cal_mag0_rot
							}
						}
						Loader { sourceComponent: showCompass0Rot ? compass0ComponentLabel2 : null }
						Loader { sourceComponent: showCompass0Rot ? compass0ComponentCombo2 : null }
					}
					// Compass 1 rotation
					Column {
						visible: !_sensorsHaveFixedOrientation
						Component {
							id: compass1ComponentLabel2
							QGCLabel {
								text: qsTr("External Compass 1 Orientation:")//外置磁罗盘1方向：
							}
						}
						Component {
							id: compass1ComponentCombo2
							FactComboBox {
								id:     compass1RotationCombo
								width:  rotationColumnWidth
								model:  rotations
								fact:   cal_mag1_rot
							}
						}
						Loader { sourceComponent: showCompass1Rot ? compass1ComponentLabel2 : null }
						Loader { sourceComponent: showCompass1Rot ? compass1ComponentCombo2 : null }
					}
					// Compass 2 rotation
					Column {
						visible: !_sensorsHaveFixedOrientation
						spacing: ScreenTools.defaultFontPixelWidth
						Component {
							id: compass2ComponentLabel2
							QGCLabel {
								text: qsTr("Compass 2 Orientation")//磁罗盘2方向
							}
						}
						Component {
							id: compass2ComponentCombo2
							FactComboBox {
								id:     compass1RotationCombo
								width:  rotationColumnWidth
								model:  rotations
								fact:   cal_mag2_rot
							}
						}
						Loader { sourceComponent: showCompass2Rot ? compass2ComponentLabel2 : null }
						Loader { sourceComponent: showCompass2Rot ? compass2ComponentCombo2 : null }
					}
				} // Column
			} // QGCFlickable
		} // QGCViewDialog
	} // Component - setOrientationsDialogComponent

	/* Flickable 可闪烁的项目将其子节点放在可拖动和轻弹的表面上，导致对子项的视图滚动。 */
	// Flickable: QGC版本的可闪烁控制，显示水平/垂直滚动指示
	QGCFlickable {
		id:             buttonFlickable
		anchors.margins: 0
		anchors.leftMargin: buttonColumn.spacing
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width:          buttonColumn.width
		contentHeight:  buttonColumn.height + buttonColumn.spacing
		flickableDirection: Flickable.VerticalFlick // 垂直滚动
		Column {
			id:         buttonColumn
			spacing:    5 // ScreenTools.defaultFontPixelHeight / 2
			IndicatorButton {
				property bool 	_hasMag: controller.parameterExists(-1, "SYS_HAS_MAG") ?
											 controller.getParameterFact(-1, "SYS_HAS_MAG").value !== 0 : true
				id:             compassButton
				width:          _buttonWidth
				text:           qsTr("Compass")//磁罗盘
				indicatorGreen: cal_mag0_id.value !== 0
				visible:        _hasMag
								&& QGroundControl.corePlugin.options.showSensorCalibrationCompass
								&& showSensorCalibrationCompass
				onClicked: {
					preCalibrationDialogType = "compass"
					preCalibrationDialogHelp = compassHelp
					mainWindow.showComponentDialog(preCalibrationDialogComponent,
												   qsTr("Calibrate Compass"), // 校准磁罗盘
												   mainWindow.showDialogDefaultWidth,
												   StandardButton.Cancel | StandardButton.Ok)
				}
			}
			IndicatorButton {
				id:             gyroButton
				width:          _buttonWidth
				text:           qsTr("Gyroscope")//陀螺仪
				indicatorGreen: cal_gyro0_id.value !== 0
				visible:        QGroundControl.corePlugin.options.showSensorCalibrationGyro
								&& showSensorCalibrationGyro
				onClicked: {
					preCalibrationDialogType = "gyro"
					preCalibrationDialogHelp = gyroHelp
					mainWindow.showComponentDialog(preCalibrationDialogComponent,
												   qsTr("Calibrate Gyro"), // 校准陀螺仪
												   mainWindow.showDialogDefaultWidth,
												   StandardButton.Cancel | StandardButton.Ok)
				}
			}
			IndicatorButton {
				id:             accelButton
				width:          _buttonWidth
				text:           qsTr("Accelerometer") // 加速度计
				indicatorGreen: cal_acc0_id.value !== 0
				visible:        QGroundControl.corePlugin.options.showSensorCalibrationAccel
								&& showSensorCalibrationAccel
				onClicked: {
					preCalibrationDialogType = "accel"
					preCalibrationDialogHelp = accelHelp
					mainWindow.showComponentDialog(preCalibrationDialogComponent,
												   qsTr("Calibrate Accelerometer"), // 校准加速度计
												   mainWindow.showDialogDefaultWidth,
												   StandardButton.Cancel | StandardButton.Ok)
				}
			}
			IndicatorButton {
				id:             levelButton
				width:          _buttonWidth
				text:           qsTr("Level Horizon") // 校平地平线
				indicatorGreen: sens_board_x_off.value !== 0
								|| sens_board_y_off.value !== 0 | sens_board_z_off.value !== 0
				enabled:        cal_acc0_id.value !== 0 && cal_gyro0_id.value !== 0
				visible:        QGroundControl.corePlugin.options.showSensorCalibrationLevel
								&& showSensorCalibrationLevel
				onClicked: {
					preCalibrationDialogType = "level"
					preCalibrationDialogHelp = levelHelp
					mainWindow.showComponentDialog(preCalibrationDialogComponent,
												   qsTr("Level Horizon"), // 校平地平线
												   mainWindow.showDialogDefaultWidth,
												   StandardButton.Cancel | StandardButton.Ok)
				}
			}
			IndicatorButton {
				id:             airspeedButton
				width:          _buttonWidth
				text:           qsTr("Airspeed") // 空速
				visible:        (controller.vehicle.fixedWing || controller.vehicle.vtol) &&
								controller.getParameterFact(-1, "FW_ARSP_MODE").value === 0
								&& controller.getParameterFact(-1, "CBRK_AIRSPD_CHK").value !== 162128 &&
								QGroundControl.corePlugin.options.showSensorCalibrationAirspeed &&
								showSensorCalibrationAirspeed
				indicatorGreen: sens_dpres_off.value !== 0
				onClicked: {
					preCalibrationDialogType = "airspeed"
					preCalibrationDialogHelp = airspeedHelp
					mainWindow.showComponentDialog(preCalibrationDialogComponent,
												   qsTr("Calibrate Airspeed"), // 校准空速计
												   mainWindow.showDialogDefaultWidth,
												   StandardButton.Cancel | StandardButton.Ok)
				}
			}
			QGCButton {
				id:         cancelButton
				width:      _buttonWidth
				text:       qsTr("Cancel") // 取消
				enabled:    false
				onClicked:  controller.cancelCalibration()
			}
			QGCButton {
				id:         nextButton
				width:      _buttonWidth
				text:       qsTr("Next") // 下一步
				visible:    showNextButton
				onClicked:  _root.nextButtonClicked()
			}
			QGCButton {
				id:         setOrientationsButton
				width:      _buttonWidth
				text:       qsTr("Set Orientations") // 设置方向
				visible:    !_sensorsHaveFixedOrientation && showSetOrientations
				onClicked:  {
					setOrientationsDialogShowBoardOrientation = true
					mainWindow.showComponentDialog(setOrientationsDialogComponent,
												   qsTr("Set Orientations"), // 设置方向
												   mainWindow.showDialogDefaultWidth,
												   StandardButton.Ok)
				}
			}
		} // Column - Buttons
	} // QGCFLickable - Buttons

	// --------------------------------------------------------------------
	Column {
		anchors.margins: 0
		anchors.leftMargin: buttonColumn.spacing
		anchors.left:       buttonFlickable.right
		anchors.right:      parent.right
		anchors.top:        parent.top
		anchors.bottom:     parent.bottom
		QGCLabel {
			anchors.left:   parent.left
			verticalAlignment: Text.AlignVCenter
			text: qsTr("Progress Bar") // 进度条
		}
		ProgressBar {
			id:             progressBar
			//value: 0.5
			anchors.left:   parent.left
			anchors.right:  parent.right
			anchors.rightMargin: buttonColumn.spacing
		}
		Item { height: 10 //ScreenTools.defaultFontPixelHeight
			width: 10 } // spacer
		Item {
			property int calDisplayAreaWidth: parent.width
			width:  parent.width
			height: parent.height - y
			TextArea {
				id:             statusTextArea
				width:          parent.calDisplayAreaWidth
				height:         parent.height
				readOnly:       true
				frameVisible:   false
				text:           statusTextAreaDefaultText
				style: TextAreaStyle {
					textColor: qgcPal.text
					backgroundColor: qgcPal.windowShade
				}
			}
			Rectangle {
				id:         orientationCalArea
				width:      parent.calDisplayAreaWidth
				height:     parent.height
				visible:    controller.showOrientationCalArea
				color:      qgcPal.windowShade
				QGCLabel {
					id:                 orientationCalAreaHelpText
					anchors.top:        parent.top
					anchors.left:       parent.left
					anchors.right:      parent.right
					anchors.topMargin: 5
					anchors.leftMargin: 5
					anchors.rightMargin: 5
					wrapMode:           Text.WordWrap
				}
				Flow {
					anchors.top:        orientationCalAreaHelpText.bottom
					anchors.left:       parent.left
					anchors.right:      parent.right
					anchors.bottom:     parent.bottom
					anchors.topMargin:  5 // ScreenTools.defaultFontPixelWidth
					anchors.leftMargin: 5
					spacing:            5 // ScreenTools.defaultFontPixelWidth / 2
					property real indicatorWidth:   (width / 3) - spacing
					property real indicatorHeight:  (height / 2) - spacing
					VehicleRotationCal {
						width:              parent.indicatorWidth
						height:             parent.indicatorHeight
						visible:            controller.orientationCalDownSideVisible
						calValid:           controller.orientationCalDownSideDone
						calInProgress:      controller.orientationCalDownSideInProgress
						calInProgressText:  controller.orientationCalDownSideRotate ?
												qsTr("Rotate") : qsTr("Hold Still")
						imageSource:        controller.orientationCalDownSideRotate ?
												"qrc:///qmlimages/VehicleDownRotate.png" :
												"qrc:///qmlimages/VehicleDown.png"
					}
					VehicleRotationCal {
						width:              parent.indicatorWidth
						height:             parent.indicatorHeight
						visible:            controller.orientationCalUpsideDownSideVisible
						calValid:           controller.orientationCalUpsideDownSideDone
						calInProgress:      controller.orientationCalUpsideDownSideInProgress
						calInProgressText:  controller.orientationCalUpsideDownSideRotate ?
												qsTr("Rotate") : qsTr("Hold Still")
						imageSource:        controller.orientationCalUpsideDownSideRotate ?
												"qrc:///qmlimages/VehicleUpsideDownRotate.png" :
												"qrc:///qmlimages/VehicleUpsideDown.png"
					}
					VehicleRotationCal {
						width:              parent.indicatorWidth
						height:             parent.indicatorHeight
						visible:            controller.orientationCalNoseDownSideVisible
						calValid:           controller.orientationCalNoseDownSideDone
						calInProgress:      controller.orientationCalNoseDownSideInProgress
						calInProgressText:  controller.orientationCalNoseDownSideRotate ?
												qsTr("Rotate") : qsTr("Hold Still")
						imageSource:        controller.orientationCalNoseDownSideRotate ?
												"qrc:///qmlimages/VehicleNoseDownRotate.png" :
												"qrc:///qmlimages/VehicleNoseDown.png"
					}
					VehicleRotationCal {
						width:              parent.indicatorWidth
						height:             parent.indicatorHeight
						visible:            controller.orientationCalTailDownSideVisible
						calValid:           controller.orientationCalTailDownSideDone
						calInProgress:      controller.orientationCalTailDownSideInProgress
						calInProgressText:  controller.orientationCalTailDownSideRotate ?
												qsTr("Rotate") : qsTr("Hold Still")
						imageSource:        controller.orientationCalTailDownSideRotate ?
												"qrc:///qmlimages/VehicleTailDownRotate.png" :
												"qrc:///qmlimages/VehicleTailDown.png"
					}
					VehicleRotationCal {
						width:              parent.indicatorWidth
						height:             parent.indicatorHeight
						visible:            controller.orientationCalLeftSideVisible
						calValid:           controller.orientationCalLeftSideDone
						calInProgress:      controller.orientationCalLeftSideInProgress
						calInProgressText:  controller.orientationCalLeftSideRotate ?
												qsTr("Rotate") : qsTr("Hold Still")
						imageSource:        controller.orientationCalLeftSideRotate ?
												"qrc:///qmlimages/VehicleLeftRotate.png" :
												"qrc:///qmlimages/VehicleLeft.png"
					}
					VehicleRotationCal {
						width:              parent.indicatorWidth
						height:             parent.indicatorHeight
						visible:            controller.orientationCalRightSideVisible
						calValid:           controller.orientationCalRightSideDone
						calInProgress:      controller.orientationCalRightSideInProgress
						calInProgressText:  controller.orientationCalRightSideRotate ?
												qsTr("Rotate") : qsTr("Hold Still")
						imageSource:        controller.orientationCalRightSideRotate ?
												"qrc:///qmlimages/VehicleRightRotate.png" :
												"qrc:///qmlimages/VehicleRight.png"
					}
				}
			}
		}
	}
}
