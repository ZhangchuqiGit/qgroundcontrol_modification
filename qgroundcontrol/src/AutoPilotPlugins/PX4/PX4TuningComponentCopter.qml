//SetupView.qml : Repeater : model
//	src/AutoPilotPlugins/PX4/PX4AutoPilotPlugin.cc :
//	const QVariantList& PX4AutoPilotPlugin::vehicleComponents(void)
//		src/AutoPilotPlugins/PX4/PX4TuningComponentPlane.qml	调参
//		src/AutoPilotPlugins/PX4/PX4TuningComponentCopter.qml	调参 +
//		src/AutoPilotPlugins/PX4/PX4TuningComponentVTOL.qml		调参

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtCharts         2.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.ScreenTools   1.0

SetupPage {
    id:             tuningPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Column {
            width: availableWidth

            Component.onCompleted: {
                // We use QtCharts only on Desktop platforms
                showAdvanced = !ScreenTools.isMobile
            }

            FactPanelController {
                id:         controller
            }

            // Standard tuning page
            FactSliderPanel {
                width:          availableWidth
                visible:        !advanced

                sliderModel: ListModel {
                    ListElement {
						title:          qsTr("Hover Throttle")//悬停油门
                        description:    qsTr("Adjust throttle so hover is at mid-throttle. Slide to the left if hover is lower than throttle center. Slide to the right if hover is higher than throttle center.")
						//调整油门使得在油门中位时能保持悬停。如果悬停时油门摇杆低于中位时请向左滑，如果悬停时油门高于中位时请向右滑。
                        param:          "MPC_THR_HOVER"
                        min:            20
                        max:            80
                        step:           1
                    }
                    ListElement {
						title:          qsTr("Manual minimum throttle")//手动最小油门
                        description:    qsTr("Slide to the left to start the motors with less idle power. Slide to the right if descending in manual flight becomes unstable.")
						//向左滑动滑块使电机启动时怠速功率更小。如果自稳模式飞行的下降过程变得不稳定请向右滑动滑块。
                        param:          "MPC_MANTHR_MIN"
                        min:            0
                        max:            15
                        step:           1
                    }
                }
            }

            Loader {
                anchors.left:       parent.left
                anchors.right:      parent.right
                sourceComponent:    advanced ? advancePageComponent : undefined
            }

            Component {
                id: advancePageComponent

                PIDTuning {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
					// 横滚 俯仰 偏航
                    tuneList:            [ qsTr("Roll"), qsTr("Pitch"), qsTr("Yaw") ]
                    params:              [
                        [ controller.getParameterFact(-1, "MC_ROLL_P"),
                         controller.getParameterFact(-1, "MC_ROLLRATE_P"),
                         controller.getParameterFact(-1, "MC_ROLLRATE_I"),
                         controller.getParameterFact(-1, "MC_ROLLRATE_D"),
                         controller.getParameterFact(-1, "MC_ROLLRATE_FF") ],
                        [ controller.getParameterFact(-1, "MC_PITCH_P"),
                         controller.getParameterFact(-1, "MC_PITCHRATE_P"),
                         controller.getParameterFact(-1, "MC_PITCHRATE_I"),
                         controller.getParameterFact(-1, "MC_PITCHRATE_D"),
                         controller.getParameterFact(-1, "MC_PITCHRATE_FF") ],
                        [ controller.getParameterFact(-1, "MC_YAW_P"),
                         controller.getParameterFact(-1, "MC_YAWRATE_P"),
                         controller.getParameterFact(-1, "MC_YAWRATE_I"),
                         controller.getParameterFact(-1, "MC_YAWRATE_D"),
                         controller.getParameterFact(-1, "MC_YAWRATE_FF") ] ]
                }
            } // Component - Advanced Page
        } // Column
    } // Component - pageComponent
} // SetupPage
