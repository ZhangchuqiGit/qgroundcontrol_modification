
import QtQuick          2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.12
import QtGraphicalEffects.private 1.12

import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

//import QGroundControl.Zcq_debug     1.0

Button {
	id:                 button
	width:					_icon.width
	checkable:          false
	onCheckedChanged: checkable = false
//	Zcq_debug { id : zcq }
//	onHeightChanged: {
//		zcq.echo("QGCToolBarButton.qml  height=" + height)
//		ScreenTools.y_Buttonheight = height
//	}
//	onWidthChanged: {
//		zcq.echo("QGCToolBarButton.qml  width=" + width)
//		ScreenTools.x_Buttonwidth = width
//	}
	background: Rectangle {
		anchors.fill: parent
		anchors.margins: 0
		border.width: 0
		opacity: button.checked ? 0.8 : 0 // 透明度
		radius: 6
		color: button.checked ? qgcPal.buttonHighlight : "transparent" // Qt.rgba(0,0,0,0) // transparent
	}
	contentItem: Column {
		id:                     column_icon
		spacing: 0
		padding: 0 // topPadding: 0; bottomPadding: 0; leftPadding: 0; rightPadding: 0
		anchors.margins: 0
		anchors.horizontalCenter: button.horizontalCenter
		QGCColoredImage {
			id:                     _icon
			anchors.horizontalCenter: parent.horizontalCenter
			width:					26
			height:					width
			sourceSize.width:		width
			fillMode: Image.PreserveAspectFit
			//		Image.Stretch - 拉伸
			//		Image.PreserveAspectFit - 均匀缩放以适应
			//		Image.PreserveAspectCrop - 均匀缩放以填充，如果需要的话进行裁剪
			//		Image.Tile - 图像平铺水平和垂直
			//		Image.TileVertically - 平铺垂直
			//		Image.TileHorizontally - 平铺水平
			//		Image.Pad - 图像没有被转换
			color: button.checked ? qgcPal.buttonHighlightText : qgcPal.buttonText
			source: button.icon.source
		}
	}
}
