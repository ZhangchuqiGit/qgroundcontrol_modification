
import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtGraphicalEffects       1.0

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

//import QGroundControl.Zcq_debug     1.0

Button {
	id: _root
	onCheckedChanged: checkable = false
	property string mytitle: ""
	property bool   setupComplete: true                                    ///< true: setup complete indicator shows as completed
	property bool   setupIndicator: true                                    ///< true: show setup complete indicator
	property string imageResource:  "/qmlimages/subMenuButtonImage.png" //< Button image : resources/CogWheels.png
	activeFocusOnPress: true

//	Zcq_debug { id : zcq }
//	readonly property string zcqfile: " -------- SubMenuButton.qml "
//	Component.onCompleted: {
//		zcq.echo("Component.onCompleted" + zcqfile)
//		zcq.echo("height=" + height)
//		zcq.echo("width=" + width)
//	}

	style: ButtonStyle {
		id: buttonStyle
		QGCPalette { // 字体和调色板
			id:                 qgcPal
			colorGroupEnabled:  control.enabled
		}
		property bool showHighlight: control.pressed | control.checked
		background: Rectangle {
			id:     innerRect
			color:  showHighlight ? qgcPal.buttonHighlight : qgcPal.windowShade
			radius: 2
			border.width: 0
			anchors.margins: 0
			anchors.fill: parent
			implicitWidth: _image.width + _image.anchors.leftMargin + titleBar.width
						   + titleBar.anchors.leftMargin + 4
			implicitHeight: Math.max(_image.height, titleBar.height) + 4
//			Component.onCompleted: {
//				zcq.echo("Component.onCompleted" + zcqfile)
//				zcq.echo("height=" + height)
//				zcq.echo("width=" + width)
//				zcq.echo("implicitHeight=" + implicitHeight)
//				zcq.echo("implicitWidth=" + implicitWidth)
//				zcq.echo("_image.height=" + _image.height)
//				zcq.echo("_image.width=" + _image.width)
//				zcq.echo("titleBar.height=" + titleBar.height)
//				zcq.echo("titleBar.width=" + titleBar.width)
//			}
			QGCColoredImage {
				id:                     _image
				anchors.leftMargin:     4
				anchors.left:           parent.left
				anchors.verticalCenter: parent.verticalCenter
				width:                  30 // ScreenTools.defaultFontPixelHeight * 1.6
				height:                 width
				fillMode:               Image.PreserveAspectFit
				//		Image.Stretch - 拉伸
				//		Image.PreserveAspectFit - 均匀缩放以适应
				//		Image.PreserveAspectCrop - 均匀缩放以填充，如果需要的话进行裁剪
				//		Image.Tile - 图像平铺水平和垂直
				//		Image.TileVertically - 平铺垂直
				//		Image.TileHorizontally - 平铺水平
				//		Image.Pad - 图像没有被转换
				mipmap:                 true
				color:                  control.setupComplete ? "green" : "red" //qgcPal.button : "red"
				source:                 control.imageResource
				sourceSize.height:      height
				//sourceSize:             Qt.size(width, height)
			}
			QGCLabel {
				id:                     titleBar
				anchors.leftMargin:     4
				anchors.left:           _image.right
				anchors.verticalCenter: parent.verticalCenter
				verticalAlignment:      TextEdit.AlignVCenter
				color:                  showHighlight ? qgcPal.buttonHighlightText : qgcPal.buttonText
				text:                   _root.mytitle
			}
		}
	}
}
