import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtGraphicalEffects 1.0

import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0

FocusScope {
	id:     _root
	height: column.height
	property alias          color:          label.color
	property alias          text:           label.text
	property bool           checked:        true
    property bool           showSpacer:     true
	property ExclusiveGroup exclusiveGroup: null
	// spacing between section headings
    property real   _sectionSpacer: ScreenTools.defaultFontPixelWidth / 2  // spacing between section headings
	onExclusiveGroupChanged: {
		if (exclusiveGroup)
			exclusiveGroup.bindCheckable(_root)
	}
	QGCPalette { id: qgcPal; colorGroupEnabled: enabled }// 字体和调色板
	QGCMouseArea {
		anchors.margins: 0
		anchors.fill: parent
		onClicked: {
			_root.focus = true
			checked = !checked
		}
		ColumnLayout {
			id:             column
			anchors.margins: 0
			anchors.left:   parent.left
			anchors.right:  parent.right
			spacing: 0
			Item {
				height:     5 // ScreenTools.defaultFontPixelWidth / 2
				width:      1
				visible:    true
			}
			QGCLabel {
				id:                 label
				Layout.fillWidth:   true
				Layout.leftMargin: 2 // ScreenTools.defaultFontPixelWidth
				QGCColoredImage {
					id:                     image
					anchors.right:          parent.right
					anchors.verticalCenter: parent.verticalCenter
					width:                  label.height * 0.6
					height:                 width
					source:                 "/qmlimages/arrow-down.png"
					color:                  qgcPal.text
					visible:                !_root.checked
				}
			}
			Rectangle {
				Layout.fillWidth:   true
				height:             1
				color:              qgcPal.text
			}
		}
	}
}
