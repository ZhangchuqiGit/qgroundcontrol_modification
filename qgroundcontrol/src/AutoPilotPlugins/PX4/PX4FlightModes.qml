//SetupView.qml : Repeater : model
//	src/AutoPilotPlugins/PX4/PX4AutoPilotPlugin.cc :
//	const QVariantList& PX4AutoPilotPlugin::vehicleComponents(void)
//		src/AutoPilotPlugins/PX4/PX4FlightModes.qml				飞行模式

import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtQuick.Layouts          1.2

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0

//import QGroundControl.Zcq_debug     1.0
//Zcq_debug { id : zcq }
//readonly property string zcqfile: " -------- MainRootWindow.qml "

/// PX4 Flight Mode configuration. This control will load either the Simple or Advanced Flight Mode config
/// based on current parameter settings.
SetupPage {
	pageComponent:  pageComponent
	Component {
		id: pageComponent
		Loader {
			width:  availableWidth
			height: availableHeight
			source: _simpleMode ?
						"qrc:/qml/PX4SimpleFlightModes.qml" : "qrc:/qml/PX4AdvancedFlightModes.qml"
			property Fact _nullFact
			property bool _rcMapFltmodeExists: controller.parameterExists(-1, "RC_MAP_FLTMODE")
			property Fact _rcMapFltmode: _rcMapFltmodeExists ?
											 controller.getParameterFact(-1, "RC_MAP_FLTMODE") : _nullFact
			property Fact _rcMapModeSw: controller.getParameterFact(-1, "RC_MAP_MODE_SW")
			property bool _simpleMode: _rcMapFltmodeExists ?
										   _rcMapFltmode.value > 0 || _rcMapModeSw.value === 0 : false
			FactPanelController {           id:         controller        }
		}
	}
}
