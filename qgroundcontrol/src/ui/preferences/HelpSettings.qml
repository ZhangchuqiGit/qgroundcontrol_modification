// Settings 配置视图 应用程序设置
// 帮助

import QtQuick          2.3
import QtQuick.Layouts  1.11

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Rectangle {
	color:          qgcPal.window
	anchors.fill:   parent

	readonly property real _margins: ScreenTools.defaultFontPixelHeight

	QGCPalette { id: qgcPal; colorGroupEnabled: true }

	/* Flickable 可闪烁的项目将其子节点放在可拖动和轻弹的表面上，导致对子项的视图滚动。 */
	// Flickable: QGC版本的可闪烁控制，显示水平/垂直滚动指示
	QGCFlickable {
		anchors.margins:    _margins
		anchors.fill:       parent
		contentWidth:       grid.width
		contentHeight:      grid.height
		clip:               true

		GridLayout {
			id:         grid
			columns:    2

			QGCLabel { text: qsTr("QGroundControl User Guide") }
			QGCLabel {
				linkColor:          qgcPal.text
				text:               "<a href=\"https://docs.qgroundcontrol.com\">https://docs.qgroundcontrol.com</a>"
				onLinkActivated:    Qt.openUrlExternally(link)
			}

			QGCLabel { text: qsTr("PX4 Users Discussion Forum") }
			QGCLabel {
				linkColor:          qgcPal.text
				text:               "<a href=\"http://discuss.px4.io/c/qgroundcontrol\">http://discuss.px4.io/c/qgroundcontrol</a>"
				onLinkActivated:    Qt.openUrlExternally(link)
			}

			QGCLabel { text: qsTr("ArduPilot Users Discussion Forum") }
			QGCLabel {
				linkColor:          qgcPal.text
				text:               "<a href=\"https://discuss.ardupilot.org/c/ground-control-software/qgroundcontrol\">https://discuss.ardupilot.org/c/ground-control-software/qgroundcontrol</a>"
				onLinkActivated:    Qt.openUrlExternally(link)
			}
		}
	}
}
