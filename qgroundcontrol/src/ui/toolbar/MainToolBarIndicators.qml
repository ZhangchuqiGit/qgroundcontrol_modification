
import QtQuick          2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts  1.11

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//import QGroundControl.Zcq_debug     1.0
//Zcq_debug { id : zcq }

//-------------------------------------------------------------------------
/// 图标栏
//-- Toolbar Indicators
Row {
	spacing: 0
	Repeater {
		model: activeVehicle ? activeVehicle.toolBarIndicators : []
		Rectangle {
			id: zcq_Repeater
			height: ScreenTools.toolbar_height
			width: indicatorLoader.width + 6
			color: "black"
			opacity: 1 // "transparent" // 透明度
			border.width: 0
			//border.color: "yellow"
			visible: indicatorLoader.visible
			anchors.margins: 0
			Component.onCompleted: {
				if (implicitHeight > ScreenTools.toolbar_height)
					ScreenTools.toolbar_height = implicitHeight
				//				zcq.echo("++++ MainToolBarIndicators.qml  Component.onCompleted:")
				//				zcq.echo("height=" + height)
				//				zcq.echo("width=" + width)
			}
			Loader {
				id:                 indicatorLoader
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top:        parent.top
				anchors.bottom:     parent.bottom
				anchors.topMargin:		2
				anchors.bottomMargin:	2
				source:             modelData
				visible:            item.showIndicator
			}
		}
	}
}


/* const QVariantList &FirmwarePlugin::toolBarIndicators(const Vehicle*)
QVariant::fromValue(QUrl::fromUserInput("qrc:/toolbar/MessageIndicator.qml")),
QVariant::fromValue(QUrl::fromUserInput("qrc:/toolbar/GPSIndicator.qml")),
QVariant::fromValue(QUrl::fromUserInput("qrc:/toolbar/TelemetryRSSIIndicator.qml")),
QVariant::fromValue(QUrl::fromUserInput("qrc:/toolbar/RCRSSIIndicator.qml")),
QVariant::fromValue(QUrl::fromUserInput("qrc:/toolbar/BatteryIndicator.qml")),
QVariant::fromValue(QUrl::fromUserInput("qrc:/toolbar/GPSRTKIndicator.qml")),
QVariant::fromValue(QUrl::fromUserInput("qrc:/toolbar/ROIIndicator.qml")),
QVariant::fromValue(QUrl::fromUserInput("qrc:/toolbar/ArmedIndicator.qml")),
QVariant::fromValue(QUrl::fromUserInput("qrc:/toolbar/ModeIndicator.qml")),
QVariant::fromValue(QUrl::fromUserInput("qrc:/toolbar/VTOLModeIndicator.qml")),
QVariant::fromValue(QUrl::fromUserInput("qrc:/toolbar/MultiVehicleSelector.qml")),
QVariant::fromValue(QUrl::fromUserInput("qrc:/toolbar/LinkIndicator.qml")),
*/
