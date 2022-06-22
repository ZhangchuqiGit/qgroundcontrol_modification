//SetupView.qml : Repeater : model
//	src/AutoPilotPlugins/PX4/PX4AutoPilotPlugin.cc :
//	const QVariantList& PX4AutoPilotPlugin::vehicleComponents(void)
//		src/AutoPilotPlugins/PX4/PowerComponent.qml				电源

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0

SetupPage {
    id:             powerPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Item {
            width:  Math.max(availableWidth, innerColumn.width)
            height: innerColumn.height

            property int textEditWidth:    ScreenTools.defaultFontPixelWidth * 8

            property Fact battNumCells:         controller.getParameterFact(-1, "BAT_N_CELLS")
            property Fact battHighVolt:         controller.getParameterFact(-1, "BAT_V_CHARGED")
            property Fact battLowVolt:          controller.getParameterFact(-1, "BAT_V_EMPTY")
            property Fact battVoltLoadDrop:     controller.getParameterFact(-1, "BAT_V_LOAD_DROP")
            property Fact battVoltageDivider:   controller.getParameterFact(-1, "BAT_V_DIV")
            property Fact battAmpsPerVolt:      controller.getParameterFact(-1, "BAT_A_PER_V")
            property Fact uavcanEnable:         controller.getParameterFact(-1, "UAVCAN_ENABLE", false)

            readonly property string highlightPrefix:   "<font color=\"" + qgcPal.warningText + "\">"
            readonly property string highlightSuffix:   "</font>"

            function getBatteryImage()
            {
                switch(battNumCells.value) {
                case 1:  return "/qmlimages/PowerComponentBattery_01cell.svg";
                case 2:  return "/qmlimages/PowerComponentBattery_02cell.svg"
                case 3:  return "/qmlimages/PowerComponentBattery_03cell.svg"
                case 4:  return "/qmlimages/PowerComponentBattery_04cell.svg"
                case 5:  return "/qmlimages/PowerComponentBattery_05cell.svg"
                case 6:  return "/qmlimages/PowerComponentBattery_06cell.svg"
                default: return "/qmlimages/PowerComponentBattery_01cell.svg";
                }
            }

            ColumnLayout {
                id:                         innerColumn
                anchors.horizontalCenter:   parent.horizontalCenter
                spacing:                    ScreenTools.defaultFontPixelHeight

                function drawArrowhead(ctx, x, y, radians)
                {
                    ctx.save();
                    ctx.beginPath();
                    ctx.translate(x,y);
                    ctx.rotate(radians);
                    ctx.moveTo(0,0);
                    ctx.lineTo(5,10);
                    ctx.lineTo(-5,10);
                    ctx.closePath();
                    ctx.restore();
                    ctx.fill();
                }

                function drawLineWithArrow(ctx, x1, y1, x2, y2)
                {
                    ctx.beginPath();
                    ctx.moveTo(x1, y1);
                    ctx.lineTo(x2, y2);
                    ctx.stroke();
                    var rd = Math.atan((y2 - y1) / (x2 - x1));
                    rd += ((x2 > x1) ? 90 : -90) * Math.PI/180;
                    drawArrowhead(ctx, x2, y2, rd);
                }

                PowerComponentController {
                    id:         controller
                    onOldFirmware:          mainWindow.showMessageDialog(qsTr("ESC Calibration"), qsTr("%1 cannot perform ESC Calibration with this version of firmware. You will need to upgrade to a newer firmware.").arg(QGroundControl.appName))
                    onNewerFirmware:        mainWindow.showMessageDialog(qsTr("ESC Calibration"), qsTr("%1 cannot perform ESC Calibration with this version of firmware. You will need to upgrade %1.").arg(QGroundControl.appName))
                    onBatteryConnected:     mainWindow.showMessageDialog(qsTr("ESC Calibration"), qsTr("Performing calibration. This will take a few seconds.."))
                    onCalibrationFailed:    mainWindow.showMessageDialog(qsTr("ESC Calibration failed"), errorMessage)
                    onCalibrationSuccess:   mainWindow.showMessageDialog(qsTr("ESC Calibration"), qsTr("Calibration complete. You can disconnect your battery now if you like."))
                    onConnectBattery:       mainWindow.showMessageDialog(qsTr("ESC Calibration"), highlightPrefix + qsTr("WARNING: Props must be removed from vehicle prior to performing ESC calibration.") + highlightSuffix + qsTr(" Connect the battery now and calibration will begin."))
                    onDisconnectBattery:    mainWindow.showMessageDialog(qsTr("ESC Calibration failed"), qsTr("You must disconnect the battery prior to performing ESC Calibration. Disconnect your battery and try again."))
                }

                Component {
                    id: calcVoltageDividerDlgComponent

                    QGCViewDialog {
                        id: calcVoltageDividerDlg

                        QGCFlickable {
                            anchors.fill:   parent
                            contentHeight:  column.height
                            contentWidth:   column.width

                            Column {
                                id:         column
                                width:      calcVoltageDividerDlg.width
                                spacing:    ScreenTools.defaultFontPixelHeight

                                QGCLabel {
                                    width:      parent.width
                                    wrapMode:   Text.WordWrap
                                    text:       qsTr("Measure battery voltage using an external voltmeter and enter the value below. Click Calculate to set the new voltage multiplier.")
									//使用外部电压表测量电池电压，并在下方输入测量值。点击“计算”设置新的电压乘数。
                                }

                                Grid {
                                    columns: 2
                                    spacing: ScreenTools.defaultFontPixelHeight / 2
                                    verticalItemAlignment: Grid.AlignVCenter

                                    QGCLabel {
										text: qsTr("Measured voltage:")//测量电压：
                                    }
									QGCTextField {
										font.family:        ScreenTools.normalFontFamily
										id: measuredVoltage }

									QGCLabel { text: qsTr("Vehicle voltage:") }//飞机电压：
                                    QGCLabel { text: controller.vehicle.battery.voltage.valueString }

									QGCLabel { text: qsTr("Voltage divider:") }//电压分压器：
                                    FactLabel { fact: battVoltageDivider }
                                }

                                QGCButton {
									text: "Calculate" // 计算

                                    onClicked:  {
                                        var measuredVoltageValue = parseFloat(measuredVoltage.text)
                                        if (measuredVoltageValue === 0 || isNaN(measuredVoltageValue)) {
                                            return
                                        }
                                        var newVoltageDivider = (measuredVoltageValue * battVoltageDivider.value) / controller.vehicle.battery.voltage.value
                                        if (newVoltageDivider > 0) {
                                            battVoltageDivider.value = newVoltageDivider
                                        }
                                    }
                                }
                            } // Column
                        } // QGCFlickable
                    } // QGCViewDialog
                } // Component - calcVoltageDividerDlgComponent

                Component {
                    id: calcAmpsPerVoltDlgComponent

                    QGCViewDialog {
                        id: calcAmpsPerVoltDlg

                        QGCFlickable {
                            anchors.fill:   parent
                            contentHeight:  column.height
                            contentWidth:   column.width

                            Column {
                                id:         column
                                width:      calcAmpsPerVoltDlg.width
                                spacing:    ScreenTools.defaultFontPixelHeight

                                QGCLabel {
                                    width:      parent.width
                                    wrapMode:   Text.WordWrap
                                    text:       qsTr("Measure current draw using an external current meter and enter the value below. Click Calculate to set the new amps per volt value.")
									//使用外部电流表测量当前电流消耗量，然后在下方输入该值。单击“计算”设置新的“安培/伏特”值。
                                }

                                Grid {
                                    columns: 2
                                    spacing: ScreenTools.defaultFontPixelHeight / 2
                                    verticalItemAlignment: Grid.AlignVCenter

                                    QGCLabel {
										font.family:        ScreenTools.normalFontFamily
										text: qsTr("Measured current:")//测量电流：
                                    }
                                    QGCTextField { id: measuredCurrent }

									QGCLabel { text: qsTr("Vehicle current:") }//飞机电流：
                                    QGCLabel { text: controller.vehicle.battery.current.valueString }

									QGCLabel { text: qsTr("Amps per volt:") }//安培/伏特
                                    FactLabel { fact: battAmpsPerVolt }
                                }

                                QGCButton {
									text: qsTr("Calculate")//计算
                                    onClicked:  {
                                        var measuredCurrentValue = parseFloat(measuredCurrent.text)
                                        if (measuredCurrentValue === 0) {
                                            return
                                        }
                                        var newAmpsPerVolt = (measuredCurrentValue * battAmpsPerVolt.value) / controller.vehicle.battery.current.value
                                        if (newAmpsPerVolt != 0) {
                                            battAmpsPerVolt.value = newAmpsPerVolt
                                        }
                                    }
                                }
                            } // Column
                        } // QGCFlickable
                    } // QGCViewDialog
                } // Component - calcAmpsPerVoltDlgComponent

				/******************************************************************/
                QGCGroupBox {
                    id:     batteryGroup
					title:  qsTr("Battery") // 电池

                    GridLayout {
                        id:             batteryGrid
                        columns:        5
                        columnSpacing:  ScreenTools.defaultFontPixelWidth

                        QGCLabel {
							text:               qsTr("Number of Cells (in Series)") // 电池芯数
                        }

                        FactTextField {
                            id:         cellsField
                            width:      textEditWidth
                            fact:       battNumCells
                            showUnits:  true
                        }

                        QGCColoredImage {
                            id:                     batteryImage
                            Layout.rowSpan:         3
                            width:                  height * 0.75
                            height:                 100
                            sourceSize.height:      height
                            fillMode:               Image.PreserveAspectFit
                            smooth:                 true
                            color:                  qgcPal.text
                            cache:                  false
                            source:                 getBatteryImage();
                        }

                        Item { width: 1; height: 1; Layout.columnSpan: 2 }

                        QGCLabel {
                            id:                 battHighLabel
							text:               qsTr("Full Voltage (per cell)") // 满电电压（每芯）
                        }

                        FactTextField {
                            id:         battHighField
                            width:      textEditWidth
                            fact:       battHighVolt
                            showUnits:  true
                        }

                        QGCLabel {
							text:   qsTr("Battery Max:")//电池最大：
                        }

                        QGCLabel {
                            text:   (battNumCells.value * battHighVolt.value).toFixed(1) + ' V'
                        }

                        QGCLabel {
                            id:                 battLowLabel
							text:               qsTr("Empty Voltage (per cell)")//空电电压（每芯）
                        }

                        FactTextField {
                            id:         battLowField
                            width:      textEditWidth
                            fact:       battLowVolt
                            showUnits:  true
                        }

                        QGCLabel {
							text:   qsTr("Battery Min:")//电池最小：
                        }

                        QGCLabel {
                            text:   (battNumCells.value * battLowVolt.value).toFixed(1) + ' V'
                        }

                        QGCLabel {
							text:               qsTr("Voltage divider")//电压分压器：
                        }

                        FactTextField {
                            id:                 voltMultField
                            fact:               battVoltageDivider
                        }

                        QGCButton {
                            id:                 voltMultCalculateButton
							text:               qsTr("Calculate")//计算
                            onClicked:          mainWindow.showComponentDialog(calcVoltageDividerDlgComponent, qsTr("Calculate Voltage Divider"), mainWindow.showDialogDefaultWidth, StandardButton.Close)
                        }

                        Item { width: 1; height: 1; Layout.columnSpan: 2 }

                        QGCLabel {
                            id:                 voltMultHelp
                            Layout.columnSpan:  batteryGrid.columns
                            Layout.fillWidth:   true
                            font.pointSize:     ScreenTools.smallFontPointSize
                            wrapMode:           Text.WordWrap
                            text:               qsTr("If the battery voltage reported by the vehicle is largely different than the voltage read externally using a voltmeter you can adjust the voltage multiplier value to correct this. ") +
                                                qsTr("Click the Calculate button for help with calculating a new value.")
							/*如果飞机所报告的电池电压与使用电压表测量的电压读数有很大差异，那么你可以调整你的电压乘数值来修正。
							单击“计算”按钮帮助计算新值*/
                        }

                        QGCLabel {
                            id:                 ampPerVoltLabel
							text:               qsTr("Amps per volt")//安培/伏特
                        }

                        FactTextField {
                            id:                 ampPerVoltField
                            fact:               battAmpsPerVolt
                        }

                        QGCButton {
                            id:                 ampPerVoltCalculateButton
							text:               qsTr("Calculate")//计算
							onClicked:          mainWindow.showComponentDialog(calcAmpsPerVoltDlgComponent,
																			   qsTr("Calculate Amps per Volt"),
																			   /*计算安培/伏特*/
																			   mainWindow.showDialogDefaultWidth,
																			   StandardButton.Close)
                        }

                        Item { width: 1; height: 1; Layout.columnSpan: 2 }

                        QGCLabel {
                            id:                 ampPerVoltHelp
                            Layout.columnSpan:  batteryGrid.columns
                            Layout.fillWidth:   true
                            font.pointSize:     ScreenTools.smallFontPointSize
                            wrapMode:           Text.WordWrap
                            text:               qsTr("If the current draw reported by the vehicle is largely different than the current read externally using a current meter you can adjust the amps per volt value to correct this. ") +
                                                qsTr("Click the Calculate button for help with calculating a new value.")
							/*如果载具所报告的电流与使用电流表的电流读数有较大偏差的话，你可以调整“安培/伏特”的值来修正它
							单击“计算”按钮帮助计算新值*/
						}
                    } // Grid
                } // QGCGroupBox - Battery settings

                QGCGroupBox {
                    Layout.maximumWidth:    batteryGroup.width
                    Layout.fillWidth:       true
                    title:                  qsTr("ESC PWM Minimum and Maximum Calibration")
					//电调PWM最大最小值校准

                    ColumnLayout {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        spacing:        ScreenTools.defaultFontPixelWidth

                        QGCLabel {
                            color:              qgcPal.warningText
                            wrapMode:           Text.WordWrap
                            text:               qsTr("WARNING: Propellers must be removed from vehicle prior to performing ESC calibration.")
							//警告：在执行电调校准之前，飞机上的螺旋桨必须先拆卸下来。
                            Layout.fillWidth:   true
                        }

                        QGCLabel {
                            text: qsTr("You must use USB connection for this operation.")
							//必须使用 USB 连接进行此操作。
                        }

                        QGCButton {
							text:       qsTr("Calibrate")//校准
                            width:      ScreenTools.defaultFontPixelWidth * 20
                            onClicked:  controller.calibrateEsc()
                        }
                    }
                }

                QGCCheckBox {
                    id:         showUAVCAN
					text:       qsTr("Show UAVCAN Settings")//显示UAVCAN设置
                    checked:    uavcanEnable ? uavcanEnable.rawValue !== 0 : false
                }

                QGCGroupBox {
                    Layout.maximumWidth:    batteryGroup.width
                    Layout.fillWidth:       true
					title:                  qsTr("UAVCAN Bus Configuration")//UAVCAN总线配置
                    visible:                showUAVCAN.checked

                    Row {
                        id:         uavCanConfigRow
                        spacing:    ScreenTools.defaultFontPixelWidth

                        FactComboBox {
                            id:                 uavcanEnabledCheckBox
                            width:              ScreenTools.defaultFontPixelWidth * 20
                            fact:               uavcanEnable
                            indexModel:         false
                        }

                        QGCLabel {
                            anchors.verticalCenter: parent.verticalCenter
							text:                   qsTr("Change required restart")//当前的变更需要重新启动
                        }
                    }
                }

                QGCGroupBox {
                    Layout.maximumWidth:    batteryGroup.width
                    Layout.fillWidth:       true
                    title:                  qsTr("UAVCAN Motor Index and Direction Assignment")
					//UAVCAN电机索引与方向分配
                    visible:                showUAVCAN.checked

                    ColumnLayout {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        spacing:        ScreenTools.defaultFontPixelWidth

                        QGCLabel {
                            wrapMode:           Text.WordWrap
                            color:              qgcPal.warningText
                            text:               qsTr("WARNING: Propellers must be removed from vehicle prior to performing UAVCAN ESC configuration.")
                            Layout.fillWidth:   true
                        }

                        QGCLabel {
                            wrapMode:           Text.WordWrap
                            text:               qsTr("ESC parameters will only be accessible in the editor after assignment.")
                            Layout.fillWidth:   true
                        }

                        QGCLabel {
                            wrapMode:           Text.WordWrap
                            text:               qsTr("Start the process, then turn each motor into its turn direction, in the order of their motor indices.")
                            Layout.fillWidth:   true
                        }

                        QGCButton {
                            text:       qsTr("Start Assignment")
                            width:      ScreenTools.defaultFontPixelWidth * 20
                            onClicked:  controller.busConfigureActuators()
                        }

                        QGCButton {
                            text:       qsTr("Stop Assignment")
                            width:      ScreenTools.defaultFontPixelWidth * 20
                            onClicked:  controller.stopBusConfigureActuators()
                        }
                    }
                }

                QGCCheckBox {
                    id:     showAdvanced
					text:   qsTr("Show Advanced Settings")//显示高级设置
                }

                QGCGroupBox {
                    Layout.maximumWidth:    batteryGroup.width
                    Layout.fillWidth:       true
					title:                  qsTr("Advanced Power Settings")//高级电源设置
                    visible:                showAdvanced.checked

                    ColumnLayout {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        spacing:        ScreenTools.defaultFontPixelWidth

                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth

                            QGCLabel {
                                text:               qsTr("Voltage Drop on Full Load (per cell)")
                                anchors.baseline:   battDropField.baseline
                            }

                            FactTextField {
                                id:         battDropField
                                width:      textEditWidth
                                fact:       battVoltLoadDrop
                                showUnits:  true
                            }
                        }

                        QGCLabel {
                            wrapMode:           Text.WordWrap
                            text:               qsTr("Batteries show less voltage at high throttle. Enter the difference in Volts between idle throttle and full ") +
                                                qsTr("throttle, divided by the number of battery cells. Leave at the default if unsure. ") +
                                                highlightPrefix + qsTr("If this value is set too high, the battery might be deep discharged and damaged.") + highlightSuffix
                            Layout.maximumWidth: ScreenTools.defaultFontPixelWidth * 60
                        }

                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth

                            QGCLabel {
                                text: qsTr("Compensated Minimum Voltage:")
                            }

                            QGCLabel {
                                text: ((battNumCells.value * battLowVolt.value) - (battNumCells.value * battVoltLoadDrop.value)).toFixed(1) + qsTr(" V")
                            }
                        }
                    } // Column
                } // QGCGroupBox - Advanced power settings
            } // Column
        } // Item
    } // Component
} // SetupPage
