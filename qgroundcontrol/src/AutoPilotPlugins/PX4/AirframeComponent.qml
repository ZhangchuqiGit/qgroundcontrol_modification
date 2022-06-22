//SetupView.qml : Repeater : model
//	src/AutoPilotPlugins/PX4/PX4AutoPilotPlugin.cc :
//	const QVariantList& PX4AutoPilotPlugin::vehicleComponents(void)
//		src/AutoPilotPlugins/PX4/AirframeComponent.qml			机架

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2

import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.ScreenTools 1.0

SetupPage {
	id:             airframePage
	pageComponent:  (controller && controller.showCustomConfigPanel) ? customFrame : pageComponent
	AirframeComponentController {        id:         controller    }
	Component {
		id: customFrame
		Column {
			width:          availableWidth
			spacing:        ScreenTools.defaultFontPixelHeight
			Item {
				width:      1
				height:     1
			}
			QGCLabel {
				anchors.horizontalCenter: parent.horizontalCenter
				width:      parent.width * 0.5
				height:     ScreenTools.defaultFontPixelHeight * 4
				wrapMode:   Text.WordWrap
				text:       qsTr("Your vehicle is using a custom airframe configuration. ") +
							qsTr("This configuration can only be modified through the Parameter Editor.\n") +
							qsTr("If you want to reset your airframe configuration and select a standard configuration, click 'Reset' below.")
			}
			QGCButton {
				text:       qsTr("Reset")
				enabled:    sys_autostart
				anchors.horizontalCenter: parent.horizontalCenter
				property Fact sys_autostart: controller.getParameterFact(-1, "SYS_AUTOSTART")
				onClicked: {
					if(sys_autostart) {
						sys_autostart.value = 0
					}
				}
			}
		}
	}
	Component {
		id: pageComponent
		Column {
			id:     mainColumn
			width:  availableWidth
			property real _minW:        ScreenTools.defaultFontPixelWidth * 26
			property real _boxWidth:    _minW
			property real _boxSpace:    0
			onWidthChanged: {
				computeDimensions()
			}
			Component.onCompleted: computeDimensions()
			function computeDimensions() {
				var sw  = 0
				var rw  = 0
				var idx = Math.floor(mainColumn.width / _minW)
				if(idx < 1) {
					_boxWidth = mainColumn.width
					_boxSpace = 0
				} else {
					_boxSpace = 0
					if(idx > 1) {
						_boxSpace = 8 // ScreenTools.defaultFontPixelWidth
						sw = _boxSpace * (idx - 1)
					}
					rw = mainColumn.width - sw
					_boxWidth = rw / idx
				}
			}
			Component {
				id: applyRestartDialogComponent
				QGCViewDialog {
					id: applyRestartDialog
					function accept() {
						controller.changeAutostart()
						applyRestartDialog.hideDialog()
					}
					QGCLabel {
						anchors.fill:   parent
						wrapMode:       Text.WordWrap
						text:           qsTr("Clicking “Apply” will save the changes you have made to your airframe configuration.<br><br>\
All vehicle parameters other than Radio Calibration will be reset.<br><br>\
Your vehicle will also be restarted in order to complete the process.")
					}
				}
			}
			Item {
				id:             helpApplyRow
				anchors.left:   parent.left
				anchors.right:  parent.right
				height:         Math.max(helpText.contentHeight, applyButton.height)
				QGCLabel {
					id:             helpText
					width:          parent.width - applyButton.width - 5
					text:           (controller.currentVehicleName != "" ?
										 qsTr("You've connected a %1.").arg(controller.currentVehicleName) :
										 qsTr("Airframe is not set.")) +
									qsTr("To change this configuration, select the desired airframe below then click “Apply and Restart”.")
					font.family:    ScreenTools.demiboldFontFamily
					wrapMode:       Text.WordWrap
				}
				QGCButton {
					id:             applyButton
					anchors.right:  parent.right
					text:           qsTr("Apply and Restart")
					onClicked:      mainWindow.showComponentDialog(applyRestartDialogComponent,
																   qsTr("Apply and Restart"),
																   mainWindow.showDialogDefaultWidth,
																   StandardButton.Apply | StandardButton.Cancel)
				}
			}
			Item {
				id:             lastSpacer
				height:         ScreenTools.defaultFontPixelHeight
				width:          10
			}
			Flow {
				id:         flowView
				width:      parent.width
				spacing:    _boxSpace
				ExclusiveGroup {                    id: airframeTypeExclusive                }
				Repeater {
					model: controller.airframeTypes
					// Outer summary item rectangle
					Rectangle {
						width:  _boxWidth
						height: ScreenTools.defaultFontPixelHeight * 12
						color:   "transparent" // qgcPal.window
						border.width: 0
						opacity: 1 // 透明度
						radius: 2
						Rectangle {
							z: -2
							anchors.fill: parent
							anchors.margins: 0
							color: qgcPal.window
							border.width: 0
							opacity: 0.8 // 透明度
							radius: 2
						}
						MouseArea {
							anchors.fill: parent
							anchors.margins: 0
							onClicked: {
								applyButton.primary = true
								airframeCheckBox.checked = true
							}
						}
						QGCLabel {
							id:     title
							height: ScreenTools.defaultFontPixelHeight * 1.6
							anchors.margins: 0
							anchors.left:       parent.left
							anchors.right:      parent.right
							text:   modelData.name
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter
						}
						Rectangle {
							anchors.margins: 0
							anchors.top:        title.bottom
							anchors.bottom:     parent.bottom
							anchors.left:       parent.left
							anchors.right:      parent.right
							color: "transparent"
							border.width: 0
							opacity: 1 // 透明度
							radius: 2
							Rectangle {
								z: -2
								anchors.margins: 0
								anchors.fill: parent
								color:  airframeCheckBox.checked ? qgcPal.buttonHighlight :
																   qgcPal.windowShade
								border.width: 0
								opacity: 0.7 // 透明度
								radius: 2
							}
							Image {
								id:                 image
								anchors.margins:    4 // ScreenTools.defaultFontPixelWidth
								anchors.top:        parent.top
								anchors.bottom:     combo.top
								anchors.left:       parent.left
								anchors.right:      parent.right
								fillMode:           Image.PreserveAspectFit
								smooth:             true
								mipmap:             true
								source:             modelData.imageResource
							}
							QGCComboBox {
								id:                 combo
								objectName:         modelData.airframeType + "ComboBox"
								anchors.margins:    5 // ScreenTools.defaultFontPixelWidth
								anchors.topMargin:	0
								anchors.bottom:     parent.bottom
								anchors.left:       parent.left
								anchors.right:      parent.right
								model:              modelData.airframes
								textRole:           "text"
								Component.onCompleted: {
									if (airframeCheckBox.checked) {
										currentIndex = controller.currentVehicleIndex
									}
								}
								onActivated: {
									applyButton.primary = true
									airframeCheckBox.checked = true;
									console.log("combo change", index)
									controller.autostartId = modelData.airframes[index].autostartId
								}
							}
							QGCCheckBox {
								// Although this item is invisible we still use it to manage state
								id:             airframeCheckBox
								checked:        modelData.name === controller.currentAirframeType
								exclusiveGroup: airframeTypeExclusive
								visible:        false
								onCheckedChanged: {
									if (checked && combo.currentIndex !== -1) {
										console.log("check box change", combo.currentIndex)
										controller.autostartId = modelData.airframes[combo.currentIndex].autostartId
									}
								}
							}
						}
					}
				} // Repeater - summary boxes
			} // Flow - summary boxes
		} // Column
	} // Component
} // SetupPage
