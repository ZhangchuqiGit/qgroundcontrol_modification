
import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Layouts          1.2

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

TextField {
	id:                 root
	textColor:          qgcPal.textFieldText
	activeFocusOnPress: true
	antialiasing:       true
	//readOnly:           true
	//font.pointSize:     ScreenTools.defaultFontPointSize // ScreenTools.smallFontPointSize
	//font.family:        ScreenTools.normalFontFamily
	//implicitHeight:     ScreenTools.implicitTextFieldHeight
	verticalAlignment: Text.AlignVCenter

	property bool   showUnits:          false
	property bool   showHelp:           false
	property string unitsLabel:         ""
	property string extraUnitsLabel:    ""
	signal helpClicked
	property real _helpLayoutWidth: 0
	QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
	Component.onCompleted: selectAllIfActiveFocus()
	onActiveFocusChanged: selectAllIfActiveFocus()
	onEditingFinished: {
		if (ScreenTools.isMobile) {
			// Toss focus on mobile after Done on virtual keyboard. Prevent strange interactions.
			focus = false
		}
	}
	function selectAllIfActiveFocus() {
		if (activeFocus) {
			selectAll()
		}
	}
	QGCLabel {
		id:             unitsLabelWidthGenerator
		text:           unitsLabel
		width:          contentWidth + parent.__contentHeight * 0.666
		visible:        false
		antialiasing:   true
		color: "pink"
		verticalAlignment: Text.AlignVCenter
	}
	style: TextFieldStyle {
		id:             tfs
		renderType:     ScreenTools.isWindows ? Text.QtRendering : tfs.renderType
		// This works around font rendering problems on windows
		background: Item {
			id: backgroundItem
			anchors.margins: 0
			property bool showHelp: control.showHelp && control.activeFocus
			//            Rectangle {
			//				anchors.fill:           parent
			//                anchors.bottomMargin:   -1
			//				color:               "darkorange"//   "#44ffffff"
			//			}
			Rectangle {
				anchors.margins: 0
				anchors.fill:           parent
				border.width:           enabled ? 1 : 0
				border.color:           root.activeFocus ? "red" : "grey"
				color:                  qgcPal.textField
			}
			RowLayout {
				id:                     unitsHelpLayout
				anchors.top:            parent.top
				anchors.bottom:         parent.bottom
				anchors.rightMargin:	backgroundItem.showHelp ? 1 : control.__contentHeight * 0.333
				anchors.right:          parent.right
				spacing:                2 //ScreenTools.defaultFontPixelWidth / 4
				Component.onCompleted:  control._helpLayoutWidth = unitsHelpLayout.width
				onWidthChanged:         control._helpLayoutWidth = unitsHelpLayout.width
				Text {
					text:               control.unitsLabel
					verticalAlignment: Text.AlignVCenter
					Layout.alignment:   Qt.AlignVCenter
					font.pointSize:     backgroundItem.showHelp ?
											ScreenTools.smallFontPointSize :
											ScreenTools.defaultFontPointSize
					font.family:        ScreenTools.normalFontFamily
					antialiasing:       true
					color:              control.textColor
					visible:            control.showUnits && text !== ""
				}
				Text {
					text:               control.extraUnitsLabel
					verticalAlignment: Text.AlignVCenter
					Layout.alignment:   Qt.AlignVCenter
					font.pointSize:     ScreenTools.smallFontPointSize
					font.family:        ScreenTools.normalFontFamily
					antialiasing:       true
					color:              control.textColor
					visible:            control.showUnits && text !== ""
				}
				Rectangle { // ?
					Layout.margins:     2
					Layout.leftMargin:  0
					//Layout.rightMargin: 1
					Layout.fillHeight:  true
					width:              helpLabel.contentWidth * 2
					color:              control.textColor
					visible:            backgroundItem.showHelp
					QGCLabel {
						id:                 helpLabel
						verticalAlignment: Text.AlignVCenter
						anchors.centerIn:   parent
						color:              qgcPal.textField
						text:               qsTr("?")
					}
				}
			}
			MouseArea {
				anchors.margins:    ScreenTools.isMobile ?
										-(ScreenTools.defaultFontPixelWidth * 0.66) : 0
				// Larger touch area for mobile
				anchors.fill:       unitsHelpLayout
				enabled:            control.activeFocus
				onClicked:          root.helpClicked()
			}
		}
		padding.right: control._helpLayoutWidth
		//control.showUnits ? unitsLabelWidthGenerator.width : control.__contentHeight * 0.333
	}
}
