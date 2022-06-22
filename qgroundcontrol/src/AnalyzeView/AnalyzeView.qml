/// Analyze 分析视图

import QtQuick          2.3
import QtQuick.Window   2.2
import QtQuick.Controls 1.2

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0

Rectangle {
    id:     setupView
	color: "transparent" // qgcPal.window
	//z:      QGroundControl.zOrderTopMost
	//opacity: 1 // 透明度
	border.width: 0
	anchors.margins: 0
	anchors.fill:   parent

	// ExclusiveGroup 提供了一种将多个可检查控件声明为互斥的方法
	// 支持的几个控件为：Action, MenuItem, Button 和 RadioButton
	ExclusiveGroup { id: setupButtonGroup }

//    readonly property real  _defaultTextHeight:     ScreenTools.defaultFontPixelHeight
//    readonly property real  _defaultTextWidth:      ScreenTools.defaultFontPixelWidth
//	readonly property real  _horizontalMargin:      _defaultTextWidth / 2
//	readonly property real  _verticalMargin:        _defaultTextHeight / 2
//	readonly property real  _buttonWidth:           _defaultTextWidth * 18

    property int _curIndex: 0

    GeoTagController {
        id: geoController
    }

    LogDownloadController {
        id: logController
    }

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
		Column {
            id:         buttonColumn
			width:      _maxButtonWidth							// auto adjust width
			anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
			spacing:    4
            property real _maxButtonWidth: 0
			function reflowWidths() {
				buttonColumn._maxButtonWidth = 0
				for (var i = 0; i < children.length; i++) {
					buttonColumn._maxButtonWidth = Math.max(buttonColumn._maxButtonWidth, children[i].width)
				}
				for (var j = 0; j < children.length; j++) {
					children[j].width = buttonColumn._maxButtonWidth
				}
			}
			Component.onCompleted: reflowWidths()
			// I don't know why this does not work
            Connections {
                target:         QGroundControl.settingsManager.appSettings.appFontPointSize
                onValueChanged: buttonColumn.reflowWidths()
            }
            QGCLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                text:                   qsTr("Analyze")
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
                id:                     buttonRepeater
                model:                  QGroundControl.corePlugin ? QGroundControl.corePlugin.analyzePages : []
                Component.onCompleted:  itemAt(0).checked = true
                SubMenuButton {
                    id:                 subMenu
                    imageResource:      modelData.icon
                    setupIndicator:     false
                    exclusiveGroup:     setupButtonGroup
					mytitle:               modelData.title
                    property var window:    analyzeWidgetWindow
                    property var loader:    analyzeWidgetLoader
                    onClicked: {
                        _curIndex = index
                        panelLoader.source = modelData.url
                        checked = true
                    }
                    Window {
                        id:             analyzeWidgetWindow
						width:          ScreenTools.defaultFontPixelWidth  * 95
                        height:         ScreenTools.defaultFontPixelHeight * 40
                        visible:        false
                        title:          modelData.title
                        Rectangle {
							color:       qgcPal.window
                            anchors.fill:  parent
							anchors.margins: 0
                            Loader {
                                id:             analyzeWidgetLoader
                                anchors.fill:   parent
                            }
                        }
                        onClosing: {
                            analyzeWidgetWindow.visible = false
                            analyzeWidgetLoader.source = ""
                            _curIndex = index
                            panelLoader.source = modelData.url
                            subMenu.visible = true
                            subMenu.checked = true
                        }
                    }
                }
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
    Connections {
        target:                 panelLoader.item
        onPopout: {
            buttonRepeater.itemAt(_curIndex).window.visible = true
            var source = panelLoader.source
            panelLoader.source = ""
            buttonRepeater.itemAt(_curIndex).loader.source = source
            buttonRepeater.itemAt(_curIndex).visible = false
            buttonRepeater.itemAt(_curIndex).loader.item.poped = true
        }
    }
    Loader {
        id:                     panelLoader
		anchors.margins: 0
		anchors.top:            parent.top
		anchors.bottom:         parent.bottom
		anchors.left:           bar_vertical.right
		anchors.right:          parent.right
//        anchors.topMargin:      _verticalMargin
//        anchors.bottomMargin:   _verticalMargin
//        anchors.leftMargin:     _horizontalMargin
//        anchors.rightMargin:    _horizontalMargin
		source:                 "LogDownloadPage.qml" // 分析视图 面板
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
