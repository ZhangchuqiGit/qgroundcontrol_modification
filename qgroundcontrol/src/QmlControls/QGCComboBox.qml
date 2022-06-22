
import QtQuick                  2.11
import QtQuick.Window           2.3
import QtQuick.Controls         2.4
import QtQuick.Controls.impl    2.4
import QtQuick.Templates        2.4 as T

import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0

//import QGroundControl.Zcq_debug     1.0

T.ComboBox {
	id:             control
	font.pointSize: ScreenTools.defaultFontPointSize
	font.family:    ScreenTools.normalFontFamily
	//	implicitWidth:  ScreenTools.implicitComboBoxWidth
	//	implicitHeight: ScreenTools.implicitComboBoxHeight
	implicitWidth:  contentItem.implicitWidth + leftPadding + rightPadding
	implicitHeight: Math.max(contentItem.implicitHeight, indicator ? indicator.implicitHeight : 0)
					+ topPadding + bottomPadding
	readonly property real _padding:  3
	topPadding: 0
	bottomPadding:	_padding
	leftPadding:    _padding
	rightPadding:   _padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width)

	//	Zcq_debug{ id: zcq }
	Component.onCompleted: {
		_onCompleted = true
		_adjustSizeToContents()
		//		zcq.echo("Component.onCompleted: {...} ------ QGCComboBox.qml ")
		//		zcq.echo("height=" + height)
		//		zcq.echo("width=" + width)
		//		zcq.echo("implicitHeight=" + implicitHeight)
		//		zcq.echo("implicitWidth=" + implicitWidth)
		//		zcq.echo("leftPadding=" + leftPadding)
		//		zcq.echo("rightPadding=" + rightPadding)
	}

	property bool   centeredLabel:  false
	property bool   sizeToContents: false
	property string alternateText:  ""

	property var    _qgcPal:            QGCPalette { colorGroupEnabled: enabled }
	property real   _largestTextWidth:  0
	property real   _popupWidth:        sizeToContents ?
											_largestTextWidth + itemDelegateMetrics.leftPadding
											+ itemDelegateMetrics.rightPadding : control.width
	property bool   _onCompleted:       false

	TextMetrics {
		id:                 textMetrics
		font.family:        control.font.family
		font.pointSize:     control.font.pointSize
	}
	ItemDelegate {
		id:             itemDelegateMetrics
		visible:        false
		font.family:    control.font.family
		font.pointSize: control.font.pointSize
	}

	function _adjustSizeToContents() {
		if (_onCompleted && sizeToContents) {
			_largestTextWidth = 0
			for (var i = 0; i < model.length; i++){
				textMetrics.text = model[i]
				_largestTextWidth = Math.max(textMetrics.width, _largestTextWidth)
			}
		}
	}

	onModelChanged: _adjustSizeToContents()

	// The label of the button
	contentItem: Item {
		implicitWidth:                  text.width
		implicitHeight:                 text.height
		anchors.margins: 0
		QGCLabel {
			id:                         text
			anchors.margins: 0
			anchors.verticalCenter:     parent.verticalCenter
			anchors.horizontalCenter:   centeredLabel ? parent.horizontalCenter : undefined
			text:                       control.alternateText === "" ? control.currentText : control.alternateText
			font:                       control.font
			color:                      _qgcPal.text
			verticalAlignment: Text.AlignVCenter
		}
	}
	indicator: QGCColoredImage {
		anchors.rightMargin:    control._padding
		anchors.right:          parent.right
		anchors.verticalCenter: parent.verticalCenter
		height:                 ScreenTools.defaultFontPixelWidth
		width:                  height
		source:                 "/qmlimages/arrow-down.png"
		color:                  _qgcPal.text
	}

	background: Rectangle {
		anchors.margins: 0
		anchors.fill: parent
		color:          _qgcPal.window
		border.width:   enabled ? 1 : 0
		border.color: "#999"
		radius: 2
	}

	// The items in the popup
	delegate: ItemDelegate {
		id: zcqfunc_
		width:  _popupWidth
		height: popupItemMetrics.height + 4
		property string _text: control.textRole ?
								   (Array.isArray(control.model) ?
										modelData[control.textRole] :
										model[control.textRole]) : modelData
		TextMetrics {
			id:             popupItemMetrics
			font:           control.font
			text:           _text
		}
		contentItem: Text {
			anchors.margins: 0
			anchors.verticalCenter: parent.verticalCenter
			text:                   _text
			font:                   control.font
			color:                  control.currentIndex === index ? "blue" : _qgcPal.buttonText
			//_qgcPal.buttonHighlightText : _qgcPal.buttonText
			verticalAlignment:      Text.AlignVCenter
		}
		background: Rectangle {
			anchors.margins: 0.50
			anchors.fill: parent
			color:  control.currentIndex === index ? _qgcPal.buttonHighlight : _qgcPal.button
			border.width:  0
			radius: 2
		}
		highlighted:                control.highlightedIndex === index
	}

	popup: T.Popup {
		y:              control.height
		width:          _popupWidth
		height:         Math.min(contentItem.implicitHeight, control.Window.height - topMargin - bottomMargin)
		topMargin:      0
		bottomMargin:   0
		contentItem: ListView {
			clip:                   true
			implicitHeight:         contentHeight
			model:                  control.delegateModel
			currentIndex:           control.highlightedIndex
			highlightMoveDuration:  0
			T.ScrollIndicator.vertical: ScrollIndicator { }
		}
		background: Rectangle {
			anchors.margins: 0
			anchors.fill: parent
			color: "cyan" // control.palette.window // "transparent"
			border.width: 0
			opacity: 0.5 // 透明度
			radius: 2
		}
	}
}
