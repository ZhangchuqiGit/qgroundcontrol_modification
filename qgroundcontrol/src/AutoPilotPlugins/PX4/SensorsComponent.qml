//SetupView.qml : Repeater : model
//	src/AutoPilotPlugins/PX4/PX4AutoPilotPlugin.cc :
//	const QVariantList& PX4AutoPilotPlugin::vehicleComponents(void)
//		src/AutoPilotPlugins/PX4/SensorsComponent.qml			传感器

import QtQuick 2.3

import QGroundControl.Controls  1.0
import QGroundControl.PX4       1.0

SetupPage {
    pageComponent:  pageComponent
    Component {
        id: pageComponent
        SensorsSetup {
            width:      availableWidth
            height:     availableHeight
        }
    }
}
