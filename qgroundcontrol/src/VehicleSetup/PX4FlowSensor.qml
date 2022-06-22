//SetupView.qml : PX4Flow 光流摄像头

import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0

import QGroundControl.Zcq_debug     1.0

Item {
	Zcq_debug { id : zcq }
	Component.onCompleted: {
		zcq.echo("Component.onCompleted" + " ---- PX4FlowSensor.qml")
		zcq.echo("image://QGCImages/" + activeVehicle.id + "/" + activeVehicle.flowImageIndex)
	}

	QGCLabel {
		id:             titleLabel
		text:           qsTr("PX4Flow Camera")
		font.family:    ScreenTools.demiboldFontFamily
	}
	Image {
		source:         activeVehicle ? "image://QGCImages/" + activeVehicle.id
										+ "/" + activeVehicle.flowImageIndex : ""
		width:          parent.width * 0.75
		height:         width
		cache:          false
		fillMode:       Image.PreserveAspectFit
		anchors.centerIn: parent
	}
}
