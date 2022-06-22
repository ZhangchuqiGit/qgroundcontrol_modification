//SetupView.qml : 参数 : SetupParameterEditor.qml

import QtQuick                      2.3
import QtQuick.Controls             1.2
import QtQuick.Dialogs              1.2
import QtQuick.Layouts              1.2

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0

//import QGroundControl.Zcq_debug     1.0

Item {
	id:         _root
	property Fact   _editorDialogFact: Fact { }
	property int    _rowHeight:         ScreenTools.defaultFontPixelHeight * 1.2
	property int    _rowWidth:          10 // Dynamic adjusted at runtime
	property bool   _searchFilter:      searchText.text.trim() != ""   ///< true: showing results of search
	property var    _searchResults      ///< List of parameter names from search results
	property bool   _showRCToParam:     !ScreenTools.isMobile
										&& QGroundControl.multiVehicleManager.activeVehicle.px4Firmware
	property var    _appSettings:       QGroundControl.settingsManager.appSettings

//	Zcq_debug { id : zcq }
//	readonly property string zcqfile: " -------- ParameterEditor.qml "

	ParameterEditorController {
		id:                 controller
		onShowErrorMessage: mainWindow.showMessageDialog(qsTr("Parameter Load Errors"), errorMsg)
	}

	//---------------------------------------------
	//-- Header
	Row {
		id:             header
		anchors.margins: 5
		anchors.top:    parent.top
		anchors.left:   parent.left
		anchors.right:  parent.right
		spacing:        ScreenTools.defaultFontPixelWidth
		Timer {
			id:         clearTimer
			interval:   100;
			running:    false;
			repeat:     false
			onTriggered: {
				searchText.text = ""
				controller.searchText = ""
			}
		}
		QGCLabel {
			anchors.verticalCenter: parent.verticalCenter
			text: qsTr("Search:")
		}
		QGCTextField {
			id:                 searchText
			anchors.verticalCenter: parent.verticalCenter
			text:               controller.searchText
			onDisplayTextChanged: controller.searchText = displayText
		}
		QGCButton {
			text: qsTr("Clear")
			onClicked: {
				if(ScreenTools.isMobile) {
					Qt.inputMethod.hide();
				}
				clearTimer.start()
			}
			anchors.verticalCenter: parent.verticalCenter
		}
		QGCCheckBox {
			text:       qsTr("Show modified only")
			checked:    controller.showModifiedOnly
			anchors.verticalCenter: parent.verticalCenter
			onClicked: {
				controller.showModifiedOnly = !controller.showModifiedOnly
			}
		}
	} // Row - Header
	// Header - Tools 工具
	QGCButton {
		anchors.rightMargin: 5
		anchors.top:    header.top
		anchors.bottom: header.bottom
		anchors.right:  parent.right
		text:           qsTr("Tools")//工具
		visible:        !_searchFilter
		onClicked:      toolsMenu.popup()
	}
	QGCMenu {
		id:                 toolsMenu
		QGCMenuItem {
			text:           qsTr("Refresh")//刷新
			onTriggered:	controller.refresh()
		}
		QGCMenuItem {
			text:           qsTr("Reset all to firmware's defaults")//全部重置为固件's默认值
			onTriggered:    mainWindow.showComponentDialog( resetToDefaultConfirmComponent,
														   qsTr("Reset All"), //全部重置
														   mainWindow.showDialogDefaultWidth,
														   StandardButton.Cancel | StandardButton.Reset)
		}
		QGCMenuItem {
			text:           qsTr("Reset to vehicle's configuration defaults")//重置为载具的配置默认值
			visible:        !activeVehicle.apmFirmware
			onTriggered:    mainWindow.showComponentDialog(resetToVehicleConfigurationConfirmComponent,
														   qsTr("Reset All"),
														   mainWindow.showDialogDefaultWidth,
														   StandardButton.Cancel | StandardButton.Reset)
		}
		QGCMenuSeparator { }//MenuSeparator 用于在视觉上区分菜单中的项目组，用一行分隔它们。
		QGCMenuItem {
			text:           qsTr("Load from file...")//从文件载入
			onTriggered: {
				fileDialog.title =          qsTr("Load Parameters")
				fileDialog.selectExisting = true
				fileDialog.openForLoad()
			}
		}
		QGCMenuItem {
			text:           qsTr("Save to file...")//保存到文件
			onTriggered: {
				fileDialog.title =          qsTr("Save Parameters")//保存参数
				fileDialog.selectExisting = false
				fileDialog.openForSave()
			}
		}
		QGCMenuSeparator { visible: _showRCToParam }//MenuSeparator 用于在视觉上区分菜单中的项目组，用一行分隔它们。
		QGCMenuItem {
			text:           qsTr("Clear RC to Param")//清除遥控调整参数
			onTriggered:	controller.clearRCToParam()
			visible:        _showRCToParam
		}
		QGCMenuSeparator { }//MenuSeparator 用于在视觉上区分菜单中的项目组，用一行分隔它们。
		QGCMenuItem {
			text:           qsTr("Reboot Vehicle")//重启飞机
			onTriggered:    mainWindow.showComponentDialog(rebootVehicleConfirmComponent,
														   qsTr("Reboot Vehicle"),
														   mainWindow.showDialogDefaultWidth,
														   StandardButton.Cancel | StandardButton.Ok)
		}
	}

	//---------------------------------------------
	/// Left panel : Group buttons
	/* Flickable 可闪烁的项目将其子节点放在可拖动和轻弹的表面上，导致对子项的视图滚动。 */
	// Flickable: QGC版本的可闪烁控制，显示水平/垂直滚动指示
	QGCFlickable {
		id :                groupScroll
		visible:            !_searchFilter && !controller.showModifiedOnly
		anchors.top:        header.bottom
		anchors.bottom:     parent.bottom
		width:              ScreenTools.defaultFontPixelWidth * 19
		contentHeight:      groupedViewCategoryColumn.height
		pixelAligned:       true
		flickableDirection: Flickable.VerticalFlick // 滚动方式 垂直滚动
		clip:               true
		ColumnLayout {
			id:             groupedViewCategoryColumn
			anchors.margins: 0
			anchors.left:  parent.left
			anchors.right: parent.right
			spacing:        3 // Math.ceil(ScreenTools.defaultFontPixelHeight * 0.25)
			// ExclusiveGroup 提供了一种将多个可检查控件声明为互斥的方法
			// 支持的几个控件为：Action, MenuItem, Button 和 RadioButton
			ExclusiveGroup { id: sectionGroup }
			Repeater {
				model: controller.categories
				ColumnLayout {
					Layout.fillWidth:   true
					spacing:            3 // Math.ceil(ScreenTools.defaultFontPixelHeight * 0.25)
					readonly property string category: modelData
					SectionHeader {
						id:             categoryHeader
						Layout.fillWidth:   true
						text:           category
						checked:        controller.currentCategory === text
						exclusiveGroup: sectionGroup
						onCheckedChanged: {
							if (checked) {
								controller.currentCategory  = category
								controller.currentGroup     = controller.getGroupsForCategory(category)[0]
							}
						}
					}
					// ExclusiveGroup 提供了一种将多个可检查控件声明为互斥的方法
					// 支持的几个控件为：Action, MenuItem, Button 和 RadioButton
					ExclusiveGroup { id: buttonGroup }
					Repeater {
						model: categoryHeader.checked ? controller.getGroupsForCategory(category) : 0
						QGCButton {
							textLeft: true
							Layout.fillWidth:   true
							text:           groupName
							checked:        controller.currentGroup === text
							exclusiveGroup: buttonGroup
							readonly property string groupName: modelData
							onClicked: {
								if (!checked) _rowWidth = 10
								checked = true
								controller.currentCategory  = category
								controller.currentGroup     = groupName
							}
						}
					}
				}
			}
		}
	}

	//---------------------------------------------
	/// Right panel : Parameter list
	// 列表视图中的项目可以水平或垂直布局。列表视图本质上是可闪烁的，因为 ListView 继承自 Flickable
	QGCListView {
		id:                 editorListView
		anchors.margins: 0
		anchors.leftMargin: ScreenTools.defaultFontPixelWidth
		anchors.left:       (_searchFilter || controller.showModifiedOnly) ? parent.left : groupScroll.right
		anchors.right:      parent.right
		anchors.top:        header.bottom
		anchors.bottom:     parent.bottom
		orientation:        ListView.Vertical
		model:              controller.parameters
		cacheBuffer:        height > 0 ? height * 2 : 0
		clip:               true
		property real adaptwidth1: ScreenTools.defaultFontPixelWidth * 7.0
		property real adaptwidth2: ScreenTools.defaultFontPixelWidth * 7.0
		Component.onCompleted: {
			adaptwidth1 = ScreenTools.defaultFontPixelWidth * 7.0
			adaptwidth2 = ScreenTools.defaultFontPixelWidth * 7.0
		}
		delegate: Rectangle {
			height: factRow.height + zcq_bottombar.height
			width:  _rowWidth
			color: Qt.rgba(0,0,0,0) // "transparent"
			Row {
				id:     factRow
				spacing: ScreenTools.defaultFontPixelWidth
				property Fact modelFact: object
				QGCLabel {
					id:     nameLabel
					verticalAlignment: Text.AlignVCenter
					width:  editorListView.adaptwidth1 // ScreenTools.defaultFontPixelWidth  * 18
					text:   factRow.modelFact.name
					clip:   true
					Component.onCompleted: {
						if (nameLabel.implicitWidth > editorListView.adaptwidth1) {
							editorListView.adaptwidth1 = nameLabel.implicitWidth
						}
					}
				}
				QGCLabel {
					id:     valueLabel
					verticalAlignment: Text.AlignVCenter
					width:  editorListView.adaptwidth2 // ScreenTools.defaultFontPixelWidth  * 18
					color:  factRow.modelFact.defaultValueAvailable ?
								(factRow.modelFact.valueEqualsDefault ? qgcPal.text : qgcPal.warningText) : qgcPal.text
					text:   factRow.modelFact.enumStrings.length === 0 ?
								factRow.modelFact.valueString + " " + factRow.modelFact.units :
								factRow.modelFact.enumStringValue
					clip:   true
					Component.onCompleted: {
						if (valueLabel.implicitWidth > editorListView.adaptwidth2) {
							editorListView.adaptwidth2 = valueLabel.implicitWidth
						}
					}
				}
				QGCLabel {
					verticalAlignment: Text.AlignVCenter
					text:   factRow.modelFact.shortDescription
				}
				Component.onCompleted: {
					if(_rowWidth < factRow.width ) {
						_rowWidth = factRow.width
					}
				}
			}
			Rectangle {
				id: zcq_bottombar
				width:  _rowWidth
				height: 1
				color:  qgcPal.text
				opacity: 0.2
				anchors.bottom: parent.bottom
				anchors.left:   parent.left
			}
			MouseArea {
				anchors.margins: 0
				anchors.fill:       parent
				acceptedButtons:    Qt.LeftButton
				onClicked: {
					_editorDialogFact = factRow.modelFact
					mainWindow.showComponentDialog(editorDialogComponent,
												   qsTr("Parameter Editor"),
												   mainWindow.showDialogDefaultWidth,
												   StandardButton.Cancel | StandardButton.Save)
				}
			}
		}
	}

	//---------------------------------------------
	QGCFileDialog {
		id:             fileDialog
		folder:         _appSettings.parameterSavePath
		fileExtension:  _appSettings.parameterFileExtension
		nameFilters:    [ qsTr("Parameter Files (*.%1)").arg(_appSettings.parameterFileExtension) ,
			qsTr("All Files (*.*)") ]
		onAcceptedForSave: {
			controller.saveToFile(file)
			close()
		}
		onAcceptedForLoad: {
			controller.loadFromFile(file)
			close()
		}
	}

	//---------------------------------------------
	Component {
		id: editorDialogComponent
		ParameterEditorDialog {
			fact:           _editorDialogFact
			showRCToParam:  _showRCToParam
		}
	}
	Component {
		id: resetToDefaultConfirmComponent
		QGCViewDialog {
			function accept() {
				controller.resetAllToDefaults()
				hideDialog()
			}
			QGCLabel {
				width:              parent.width
				wrapMode:           Text.WordWrap
				text: qsTr("Select Reset to reset all parameters to their defaults.") + "\n"
					  + qsTr("Note that this will also completely reset everything, including UAVCAN nodes.")
				//点击“重置”将所有参数重置为默认值。注意，这也将完全重置一切，包括 UAVCAN 节点。
			}
		}
	}
	Component {
		id: resetToVehicleConfigurationConfirmComponent
		QGCViewDialog {
			function accept() {
				controller.resetAllToVehicleConfiguration()
				hideDialog()
			}
			QGCLabel {
				width:              parent.width
				wrapMode:           Text.WordWrap
				text:               qsTr("Select Reset to reset all parameters to the vehicle's configuration defaults.")
			}
		}
	}
	Component {
		id: rebootVehicleConfirmComponent
		QGCViewDialog {
			function accept() {
				activeVehicle.rebootVehicle()
				hideDialog()
			}
			QGCLabel {
				width:              parent.width
				wrapMode:           Text.WordWrap
				text:               qsTr("Select Ok to reboot vehicle.")
			}
		}
	}
}
