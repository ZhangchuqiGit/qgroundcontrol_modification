
import QtQuick          2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs  1.3
import QtQuick.Layouts  1.11
import QtQuick.Window   2.11
import QtQuick.Controls.Styles 1.4			//导入Qt Quick控件样式库

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Controllers           1.0
import QGroundControl.FactControls      1.0
import QGroundControl.FlightMap         1.0

import QGroundControl.Zcq_debug     1.0

/// @brief Native QML top level window
/// All properties defined here are visible to all QML pages.
ApplicationWindow {
	id:             mainWindow
	minimumWidth:   ScreenTools.isMobile ? Screen.width  : Math.min(250 * Screen.pixelDensity, Screen.width)
	minimumHeight:  ScreenTools.isMobile ? Screen.height : Math.min(250 * Screen.pixelDensity, Screen.height)
	visible:        true

	property var                _rgPreventViewSwitch:       [ false ]

	readonly property real      _topBottomMargins: ScreenTools.defaultFontPixelHeight * 0.5
	readonly property string    _mainToolbar: QGroundControl.corePlugin.options.mainToolbarUrl
	readonly property string    _planToolbar: QGroundControl.corePlugin.options.planToolbarUrl

	//-------------------------------------------------------------------------
	//-- Global Scope Variables

	/// Current active Vehicle
	property var                activeVehicle:              QGroundControl.multiVehicleManager.activeVehicle
	/// Indicates communication with vehicle is list (no heartbeats)
	property bool               communicationLost:          activeVehicle ? activeVehicle.connectionLost : false
	property string             formatedMessage:            activeVehicle ? activeVehicle.formatedMessage : ""
	/// Indicates usable height between toolbar and footer
	property real availableHeight: mainWindow.height - mainWindow.header.height - mainWindow.footer.height

	property var                currentPlanMissionItem:     planMasterControllerPlan ? planMasterControllerPlan.missionController.currentPlanViewItem : null
	property var                planMasterControllerPlan:   null
	property var                planMasterControllerView:   null
	property var                flightDisplayMap:           null

	readonly property string    navButtonWidth:             ScreenTools.defaultFontPixelWidth * 24
	readonly property real      defaultTextHeight:          ScreenTools.defaultFontPixelHeight
	readonly property real      defaultTextWidth:           ScreenTools.defaultFontPixelWidth

	Zcq_debug { id : zcq }
	readonly property string zcqfile: " -------- MainRootWindow.qml "

	Component.onCompleted: {
		zcq.echo("Component.onCompleted: {...}" + zcqfile)
		//-- Full screen on mobile or tiny screens
		if(ScreenTools.isMobile || Screen.height / ScreenTools.realPixelDensity < 120) {
			mainWindow.showFullScreen()
		} else {
			width   = ScreenTools.isMobile ? Screen.width  : Math.min(280 * Screen.pixelDensity, Screen.width)
			height  = ScreenTools.isMobile ? Screen.height : Math.min(250 * Screen.pixelDensity, Screen.height)
		}
		zcq_data()
		// 飞行视图 (默认)
		buttonColumn.clearAllChecks()
		flyButton.checked = true
		mainWindow.showFlyView()
	}

	function zcq_data() {
		zcq.echo("----------------------------------------------")
		zcq.echo("ScreenTools.toolbar_height=" + ScreenTools.toolbar_height)
		zcq.echo("header.width=" + header.width)
		zcq.echo("header.height=" + header.height)
		zcq.echo("width=" + width)
		zcq.echo("height=" + height)
		zcq.echo("mainWindow.width=" + mainWindow.width)
		zcq.echo("mainWindow.height=" + mainWindow.height)
		zcq.echo("zcq_Popup_menu.width=" + zcq_Popup_menu.width)
		zcq.echo("zcq_Popup_menu.height=" + zcq_Popup_menu.height)
		zcq.echo("view_popup.contentWidth=" + view_popup.contentWidth)
		zcq.echo("view_popup.width=" + view_popup.width)
		zcq.echo("view_popup.height=" + view_popup.height)
		zcq.echo("settingsWindow.width=" + settingsWindow.width)
		zcq.echo("settingsWindow.height=" + settingsWindow.height)

	}

	/* 字体和调色板
QGC有一套标准的字体和调色板，应该被所有用户界面使用。
QGCPalette
此项目公开QGC调色板。这个调色板有两个变种：明亮和黑暗。调色板适用于户外使用，黑色调色板适用于室内。
通常，您不应该直接为UI指定颜色，您应该始终使用调色板中的颜色。
如果您不遵循此规则，则您创建的用户界面将无法从明暗风格中更改。 */
	/// Default color palette used throughout the UI
	QGCPalette { id: qgcPal; colorGroupEnabled: true }

	//-------------------------------------------------------------------------
	/// Main, full window background (Fly View)
	background: Item {
		id:             rootBackground
		anchors.fill:   parent
	}

	//-------------------------------------------------------------------------
	/// Toolbar 工具栏
	header: ToolBar {
		height:        0
		visible:        false
		Loader {
			id:             toolbar
		}
	}

	//-------------------------------------------------------------------------
	/// 图标栏
	Popup {		// Popup 弹出式顶层窗口
		id: zcq_Popup_icon
		y: 0
		x: 0
		modal: false // 默认为 false 非模态,非阻塞调用,指出现该对话框时,也可以与父窗口进行交互
		focus: true
		closePolicy: Popup.NoAutoClose /*只有在手动调用close()后，弹出窗口才会关闭*/
		opacity: 0.9 // 透明度
		visible: true
		padding: 0 // topPadding: 0; bottomPadding: 0; leftPadding: 0; rightPadding: 0
		topInset: 0; bottomInset: 0; leftInset: 0; rightInset: 0
		//background: id		//设置窗口的背景控件，不设置的话Popup的边框会显示出来
		background: Rectangle {
			color: "transparent"
			//opacity: 1 // 透明度
			border.width: 0
			//border.color: "green" // "transparent"
			//radius: 6
		}
		/*background: BorderImage {
				source: ":/images/background.png"
			}*/
		Column {			// 列布局 01
			id: zcq_Popup_icon_Column01
			anchors.fill: parent
			anchors.margins: 0
			spacing: 0
			Loader {
				id: zcq_RowLayout_Loader
				anchors.margins: 0
				source:           "/toolbar/MainToolBarIndicators.qml"
				visible:          activeVehicle && !communicationLost
			}
			Rectangle {		// Small parameter download progress bar
				id: smallProgressBar
				visible: !largeProgressBar.visible
				anchors.margins: 0
				height: visible ? 2 : 0
				width: activeVehicle ? activeVehicle.parameterManager.loadProgress * parent.width : 0
				color:         qgcPal.colorGreen
			}
			Rectangle {		// Large parameter download progress bar
				id: largeProgressBar
				visible: _showLargeProgress
				anchors.margins: 0
				height: visible ? largeProgressBar_QGCLabel.font.pointSize * 2.0 : 0
				width: parent.width
				color:          qgcPal.window
				property bool _initialDownloadComplete: activeVehicle ?
															activeVehicle.parameterManager.parametersReady : true
				property bool _userHide: false
				property bool _showLargeProgress: !_initialDownloadComplete && !_userHide
				// && qgcPal.globalTheme === QGCPalette.Light
				Connections {
					target:                 QGroundControl.multiVehicleManager
					onActiveVehicleChanged: largeProgressBar._userHide = false
				}
				Rectangle {
					anchors.top:    parent.top
					anchors.bottom: parent.bottom
					anchors.margins: 0
					width:          activeVehicle ? activeVehicle.parameterManager.loadProgress * parent.width : 0
					color:          qgcPal.colorGreen
				}
				QGCLabel {
					id: largeProgressBar_QGCLabel
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.verticalCenter: parent.verticalCenter
					text:               qsTr("Downloading Parameters")
				}
				/*MouseArea {
					anchors.fill:   parent
					onClicked:      largeProgressBar._userHide = true
				}*/
			}
			Row {				//-- Connection Status
				id: zcq_Popup_icon_ConnectionStatus
				visible: activeVehicle && communicationLost
				spacing: ScreenTools.defaultFontPixelWidth
				height: visible ? Math.max(zcq_connectionLost.height, zcq_disconnectButton.height)+2 : 0
				width: visible ? zcq_connectionLost.width+zcq_disconnectButton.width : 0
				QGCLabel {
					id:                     zcq_connectionLost
					anchors.verticalCenter: parent.verticalCenter
					text:                   qsTr("COMMUNICATION LOST")
					font.pointSize:         ScreenTools.largeFontPointSize
					font.family:            ScreenTools.demiboldFontFamily
					color:                  qgcPal.colorRed
				}
				QGCButton {
					id:                     zcq_disconnectButton
					anchors.verticalCenter: parent.verticalCenter
					height: ScreenTools.largeFontPointSize * 1.6
					text:                   qsTr("Disconnect")
					primary:                true
					onClicked:              activeVehicle.disconnectInactiveVehicle()
				}
			}
			QGCLabel {				//-- Waiting for a vehicle
				id: zcq_QGCLabel_icon01
				visible: !activeVehicle
				text:                   qsTr("Waiting For Vehicle Connection")
				font.pointSize:         ScreenTools.mediumFontPointSize
				font.family:            ScreenTools.demiboldFontFamily
				color:                  qgcPal.colorRed
				height: visible ? font.pointSize * 1.2 : 0
			}
		}
	}

	//-------------------------------------------------------------------------
	/// 工具栏
	Popup {		// Popup 弹出式顶层窗口
		id: zcq_Popup_menu
		x: 0
		y: ScreenTools.toolbar_height * 3
		// y: (mainWindow.height - height + ScreenTools.toolbar_height) * 0.5
		//width: buttonColumn.width
		//height: buttonColumn.height
		modal: false // 默认为 false 非模态,非阻塞调用,指出现该对话框时,也可以与父窗口进行交互
		focus: true
		closePolicy: Popup.NoAutoClose /*只有在手动调用close()后，弹出窗口才会关闭*/
		opacity: 1 // 透明度
		visible: true
		padding: 0 // topPadding: 0; bottomPadding: 0; leftPadding: 0; rightPadding: 0
		topInset: 0; bottomInset: 0; leftInset: 0; rightInset: 0
		background: Rectangle {
			anchors.fill: parent
			color:  "black" // "transparent"
			border.width: 0
			opacity: 0.7 // 透明度
			radius: 6
		}
		//		onYChanged: {
		//			ScreenTools.y_Button=zcq_Popup_menu.y /// 视图
		//			zcq.echo("zcq_Popup_menu  ScreenTools.y_Button=" + ScreenTools.y_Button)
		//		}
		Component.onCompleted: {
			ScreenTools.hufei_y = zcq_Popup_menu.y + zcq_Popup_menu.height
			zcq.echo("ScreenTools.hufei_y="+ ScreenTools.hufei_y)
		}
		Connections {
			target: setupWindow 	/// Connections auto 设置视图 (默认)
			onVisibleChanged: {
				if(setupWindow.visible) {
					buttonColumn.clearAllChecks()
					setupButton.checked = true
				}
			}
		}
		ColumnLayout { // 列布局
			id: buttonColumn
			anchors.margins: 0
			anchors.fill: parent
			spacing: 0
			function clearAllChecks() {
				settingsButton.checked = false
				setupButton.checked = false
				planButton.checked = false
				analyzeButton.checked = false
				flyButton.checked = false
			}
			QGCToolBarButton {
				id:                 settingsButton		/// Settings 配置视图
				Layout.alignment: Qt.AlignHCenter
				icon.source:        "/res/QGCLogoWhite"
				onClicked: {
					if (mainWindow.preventViewSwitch()) { return }
					buttonColumn.clearAllChecks()
					settingsButton.checked = true
					mainWindow.showSettingsView()
				}
			}
			QGCToolBarButton {
				id:                 setupButton			/// Setup 设置视图
				Layout.alignment: Qt.AlignHCenter
				icon.source:        "/qmlimages/Gears.svg"
				onClicked: {
					if (mainWindow.preventViewSwitch()) { return }
					buttonColumn.clearAllChecks()
					setupButton.checked = true
					mainWindow.showSetupView()
				}
			}
			QGCToolBarButton {
				id:                 planButton			/// Plan View 任务规划视图
				Layout.alignment: Qt.AlignHCenter
				icon.source:        "/qmlimages/Plan.svg"
				onClicked: {
					if (mainWindow.preventViewSwitch()) { return }
					buttonColumn.clearAllChecks()
					planButton.checked = true
					mainWindow.showPlanView()
				}
			}
			QGCToolBarButton {
				id:                 flyButton			/// Fly View 飞行视图
				Layout.alignment: Qt.AlignHCenter
				icon.source:        "/qmlimages/PaperPlane.svg"
				onClicked: {
					if (mainWindow.preventViewSwitch()) { return }
					buttonColumn.clearAllChecks()
					flyButton.checked = true
					mainWindow.showFlyView()
				}
			}
			QGCToolBarButton {
				id:                 analyzeButton			/// Analyze 分析视图
				Layout.alignment: Qt.AlignHCenter
				icon.source:        "/qmlimages/Analyze.svg"
				onClicked: {
					if (mainWindow.preventViewSwitch()) { return }
					buttonColumn.clearAllChecks()
					analyzeButton.checked = true
					mainWindow.showAnalyzeView()
				}
			}
		}
	}
	/*ColorAnimation {
			from: "white"
			to: "black"
			duration: 200
		}*/
	/*BorderImage {
			id: name
			source: "file"
			width: 100; height: 100
			border.left: 5; border.top: 5
			border.right: 5; border.bottom: 5
		}*/
	/*Component.onCompleted: {
			zcq.echo("Popup.Component.onCompleted: {...}" + zcqfile)
			//此属性保存弹出窗口是否完全打开。当它是可见并未运行时，弹出窗口被视为打开。
			if ( true === zcq_Toolbar.opened )
			{
				// zcq_Toolbar.open() // 显示 弹出式顶层窗口
				zcq.echo("关闭 弹出式顶层窗口")
				zcq_Toolbar.close() // 关闭 弹出式顶层窗口
			}
		}*/
	/*Rectangle {
			id: rect
			anchors.fill: parent // width: 100; height: 100
			color: "#0090f6"
			// border.color: "black"
			border.width: 0
			radius: 10
			opacity: 1 // 透明度
			*/
	/*Rectangle {
				width: parent.width-4
				height: 2
				anchors.top: parent.top
				anchors.topMargin: 40
				anchors.left: parent.left
				anchors.leftMargin: 2
				radius: 8
				color: "#ee90f6"
				border.width: 0
			}*/
	/*Text {			//设置标题栏区域为拖拽区域
				width: parent.width
				height: 40
				anchors.top: parent.top
				text: qsTr("标题栏")
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				MouseArea {
					property point clickPoint: "0,0"
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton
					onPressed: {
						clickPoint  = Qt.point(mouse.x, mouse.y)
					}
					onPositionChanged: {
						var offset = Qt.point(mouse.x - clickPoint.x, mouse.y - clickPoint.y)
						setDlgPoint(offset.x, offset.y)
					}
				}
			}*/
	//}
	//	function setDlgPoint(dlgX ,dlgY) // 设置为拖拽区域
	//	{
	//		//设置窗口拖拽不能超过父窗口
	//		if(zcq_Toolbar.x + dlgX < 0)
	//		{
	//			zcq_Toolbar.x = 0
	//		}
	//		else if(zcq_Toolbar.x + dlgX > zcq_Toolbar.parent.width - zcq_Toolbar.width)
	//		{
	//			zcq_Toolbar.x = zcq_Toolbar.parent.width - zcq_Toolbar.width
	//		}
	//		else
	//		{
	//			zcq_Toolbar.x = zcq_Toolbar.x + dlgX
	//		}
	//		if(zcq_Toolbar.y + dlgY < 0)
	//		{
	//			zcq_Toolbar.y = 0
	//		}
	//		else if(zcq_Toolbar.y + dlgY > zcq_Toolbar.parent.height - zcq_Toolbar.height)
	//		{
	//			zcq_Toolbar.y = zcq_Toolbar.parent.height - zcq_Toolbar.height
	//		}
	//		else
	//		{
	//			zcq_Toolbar.y = zcq_Toolbar.y + dlgY
	//		}
	//	}

	//-------------------------------------------------------------------------
	footer: LogReplayStatusBar {
		visible: QGroundControl.settingsManager.flyViewSettings.showLogReplayStatusBar.rawValue
	}

	//-------------------------------------------------------------------------
	//-- Actions

	signal armVehicle
	signal disarmVehicle
	signal vtolTransitionToFwdFlight
	signal vtolTransitionToMRFlight

	//-------------------------------------------------------------------------
	//-- Global Scope Functions

	/// Prevent view switching
	function pushPreventViewSwitch() {
		_rgPreventViewSwitch.push(true)
	}

	/// Allow view switching
	function popPreventViewSwitch() {
		if (_rgPreventViewSwitch.length == 1) {
			console.warn("mainWindow.popPreventViewSwitch called when nothing pushed")
			return
		}
		_rgPreventViewSwitch.pop()
	}

	/// @return true: View switches are not currently allowed
	function preventViewSwitch() {
		return _rgPreventViewSwitch[_rgPreventViewSwitch.length - 1]
	}

	onWidthChanged: {
		view_popup.view_popup_width()
	}

	//-------------------------------------------------------------------------
	Popup {		// Popup 弹出式顶层窗口
		id: view_popup
		height: Math.round(mainWindow.height * 0.8) // Screen.width
		//width: Math.round( mainWindow.width >= 812 ? 650 :  mainWindow.width * 0.8 )
		x: (mainWindow.width - width + zcq_Popup_menu.width) * 0.5
		y: (mainWindow.height - height + ScreenTools.toolbar_height) * 0.5
		modal: false // 默认为 false 非模态,非阻塞调用,指出现该对话框时,也可以与父窗口进行交互
		focus: true
		closePolicy: Popup.NoAutoClose /*只有在手动调用close()后，弹出窗口才会关闭*/
		opacity: 1 // 透明度
		visible: false
		padding: 0 // topPadding: 0; bottomPadding: 0; leftPadding: 0; rightPadding: 0
		topInset: 0; bottomInset: 0; leftInset: 0; rightInset: 0
		background: Rectangle {
			anchors.margins: 0
			anchors.fill: parent
			color:  "transparent"
			border.width: 0
			opacity: 1 // 透明度
			//radius: 6
		}
		function view_popup_width() {
				view_popup.width = Math.round( mainWindow.width * 0.8 )
		}
		//		PropertyAnimation { 	// 侧边弹窗
		//			id: animation;
		//			target: settingsWindow;
		//			property: "x";
		//			from: 0 - width
		//			to: zcq_Popup_menu.width
		//			duration: 500
		//			easing.type: Easing.Linear
		//		}
		//		OpacityAnimator on opacity {
		//			id: animation;
		//			from: 0;
		//			to: 1;
		//			duration: 500
		//		}
		Loader {		/// Settings 配置视图 应用程序设置
			id: settingsWindow
			anchors.margins: 0
			anchors.fill:   parent
			visible: false
			source:         "AppSettings.qml"
		}
		Loader {	/// Setup 设置视图 载具设置
			id:             setupWindow
			anchors.margins: 0
			anchors.fill:   parent
			visible:        false
			source:         "SetupView.qml"
		}
		Loader {	/// Analyze 分析视图
			id:             analyzeWindow
			anchors.margins: 0
			anchors.fill:   parent
			visible:        false
			source:         "AnalyzeView.qml"
		}
	}
	Loader {	/// Plan View 任务规划视图
		id:             planViewLoader
		anchors.fill:   parent
		visible:        false
		source:         "PlanView.qml"
	}
	FlightDisplayView {		/// Fly View 飞行视图
		id:             flightView
		anchors.fill:   parent
		visible:        false
	}
	//-------------------------------------------------------------------------
	function viewSwitch(isPlanView) {
		//zcq_Popup_showPlanView.visible = isPlanView // 工具栏:任务规划视图
		view_popup.visible = false
		//		settingsWindow.visible  = false		// 配置视图
		//		setupWindow.visible     = false		// 设置视图
		//		planViewLoader.visible	= false		// 任务规划视图
		//		flightView.visible      = false		// 飞行视图
		//		analyzeWindow.visible   = false		// 分析视图
	}
	//-------------------------------------------------------------------------
	function showSettingsView() {
		view_popup.visible = true
		settingsWindow.visible  = true		// 配置视图
		setupWindow.visible     = false		// 设置视图
		analyzeWindow.visible   = false		// 分析视图
		zcq.echo("配置视图")
		view_popup.view_popup_width()
	}
	function showSetupView() {
		view_popup.visible = true
		settingsWindow.visible  = false		// 配置视图
		setupWindow.visible     = true		// 设置视图
		analyzeWindow.visible   = false		// 分析视图
		zcq.echo("设置视图")
		view_popup.view_popup_width()
	}
	function showPlanView() {
		viewSwitch(true) // isPlanView=true 工具栏:任务规划视图
		settingsWindow.visible  = false		// 配置视图
		setupWindow.visible     = false		// 设置视图
		planViewLoader.visible	= true		// 任务规划视图
		flightView.visible      = false		// 飞行视图
		analyzeWindow.visible   = false		// 分析视图
		zcq.echo("任务规划视图")
	}
	function showFlyView() {
		if (!flightView.visible) {
			flightView.showPreflightChecklistIfNeeded()
		}
		viewSwitch(false)
		settingsWindow.visible  = false		// 配置视图
		setupWindow.visible     = false		// 设置视图
		planViewLoader.visible	= false		// 任务规划视图
		flightView.visible      = true		// 飞行视图
		analyzeWindow.visible   = false		// 分析视图
		zcq.echo("飞行视图")
	}
	function showAnalyzeView() {
		view_popup.visible = true
		settingsWindow.visible  = false		// 配置视图
		setupWindow.visible     = false		// 设置视图
		analyzeWindow.visible   = true		// 分析视图
		zcq.echo("分析视图")
		view_popup.view_popup_width()
	}

	// Toolbar for Plan View 任务规划视图
//    Rectangle {
//        id: zcq_Popup_showPlanView
//        visible: false
//        width: zcq_Popup_showPlanView_01.width // 283
//        height: zcq_Popup_showPlanView_01.height //
//        x: parent.width - width
//        y: 0
//        color: "transparent"
//        opacity: 1 // 透明度
//        border.width: 0
//        //		Component.onCompleted: {
//        //			zcq.echo("zcq_Popup_showPlanView.Component.onCompleted:")
//        //			zcq.echo("height=" + height)
//        //			zcq.echo("width=" + width)
//        //			zcq.echo("zcq_Popup_showPlanView_01.height=" + zcq_Popup_showPlanView_01.height)
//        //			zcq.echo("zcq_Popup_showPlanView_01.width=" + zcq_Popup_showPlanView_01.width)
//        //		}
//        ColumnLayout {		// 列布局
//            anchors.fill: parent
//            anchors.margins: 0
//            spacing: 0
////			Zcq_PlanToolBarIndicators {
////				Layout.fillWidth: true
////				Layout.fillHeight: true
////				id: zcq_Popup_showPlanView_01
////			}
//        }
//    }

	//-------------------------------------------------------------------------
	/// Saves main window position and size
	MainWindowSavedState {
		window: mainWindow
	}

	//-------------------------------------------------------------------------
	//-- Global simple message dialog  全局简单消息对话框
	function showMessageDialog(title, text) {
		zcq.echo("全局 简单 消息对话框")
		if(simpleMessageDialog.visible) {
			simpleMessageDialog.close()
		}
		simpleMessageDialog.title = title
		simpleMessageDialog.text  = text
		simpleMessageDialog.open()
	}
	MessageDialog {
		id:                 simpleMessageDialog
		standardButtons:    StandardButton.Ok
		modality:           Qt.ApplicationModal
		visible:            false
	}

	//-------------------------------------------------------------------------
	//-- Global complex dialog 全局复杂消息对话框
	/// Shows a QGCViewDialogContainer based dialog
	///     @param component The dialog contents
	///     @param title Title for dialog
	///     @param charWidth Width of dialog in characters
	///     @param buttons Buttons to show in dialog using StandardButton enum

	readonly property int showDialogFullWidth:      -1  ///< Use for full width dialog
	readonly property int showDialogDefaultWidth:   40  ///< Use for default dialog width
	function showComponentDialog(component, title, charWidth, buttons) {
		zcq.echo("全局 复杂 消息对话框 showComponentDialog() title=" + title)
		var dialogWidth = charWidth === showDialogFullWidth ? mainWindow.width : ScreenTools.defaultFontPixelWidth * charWidth
		mainWindowDialog.width = dialogWidth
		mainWindowDialog.dialogComponent = component
		mainWindowDialog.dialogTitle = title
		mainWindowDialog.dialogButtons = buttons
		mainWindow.pushPreventViewSwitch()
		mainWindowDialog.open()
		if (buttons & StandardButton.Cancel || buttons & StandardButton.Close || buttons & StandardButton.Discard || buttons & StandardButton.Abort || buttons & StandardButton.Ignore) {
			mainWindowDialog.closePolicy = Popup.NoAutoClose;/*只有在手动调用close()后，弹出窗口才会关闭*/
			mainWindowDialog.interactive = false;
			zcq.echo("全局 复杂 消息对话框 if")
		} else {		// Popup 弹出式顶层窗口
			mainWindowDialog.closePolicy = Popup.CloseOnEscape | Popup.CloseOnPressOutside;
			mainWindowDialog.interactive = true;
			zcq.echo("全局 复杂 消息对话框 else")
		}
	}
	Drawer {
		id:             mainWindowDialog
		y:              mainWindow.header.height
		height:         mainWindow.height - mainWindow.header.height
		edge:           Qt.RightEdge
		interactive:    false
		background: Rectangle {
			anchors.margins: 0
			anchors.fill: parent
			border.width: 0
			opacity: 0.9 // 透明度
			color:  "#784A60"
			//radius: 2
		}
		property var    dialogComponent: null
		property var    dialogButtons: null
		property string dialogTitle: ""
		Loader {
			id:             dlgLoader
			anchors.fill:   parent
			onLoaded: {
				item.setupDialogButtons()
			}
		}
		onOpened: {
			dlgLoader.source = "QGCViewDialogContainer.qml" //设置视图 : 全局 复杂 消息对话框
		}
		onClosed: {
			//console.log("View switch ok")
			mainWindow.popPreventViewSwitch()
			dlgLoader.source = ""
		}
	}

	//-------------------------------------------------------------------------
	property bool _forceClose: false // 应用程序关闭，是否启用检查
	// On attempting an application close we check for: 应用程序关闭
	//  Unsaved missions - then
	//  Pending parameter writes - then
	//  Active connections
	onClosing: {
		if (_forceClose) {
			unsavedMissionCloseDialog.check()
			close.accepted = false
		}
	}
	function finishCloseProcess() {
		QGroundControl.linkManager.shutdown()
		QGroundControl.videoManager.stopVideo();
		_forceClose = false
		mainWindow.close()
	}
	MessageDialog {
		id:                 unsavedMissionCloseDialog
		/* qsTr() 返回 sourceText 的翻译版本，如果没有合适的翻译字符串可用，则返回sourceText本身。*/
		title:              qsTr("%1 close").arg(QGroundControl.appName)
		//text:               qsTr("You have a mission edit in progress which has not been saved/sent. If you close you will lose changes. Are you sure you want to close?")
		text:               "You have a mission edit in progress which has not been saved/sent. If you close you will lose changes. Are you sure you want to close?"
		standardButtons:    StandardButton.Yes | StandardButton.No
		modality:           Qt.ApplicationModal
		visible:            false
		onYes:              pendingParameterWritesCloseDialog.check()
		function check() {
			if (planMasterControllerPlan && planMasterControllerPlan.dirty) {
				zcq.echo("-- unsavedMissionCloseDialog:check():if")
				unsavedMissionCloseDialog.open()
			} else {
				pendingParameterWritesCloseDialog.check()
			}
		}
	}
	MessageDialog {
		id:                 pendingParameterWritesCloseDialog
		/* qsTr() 返回 sourceText 的翻译版本，如果没有合适的翻译字符串可用，则返回sourceText本身。*/
		title:              qsTr("%1 close").arg(QGroundControl.appName)
		//text:               qsTr("You have pending parameter updates to a vehicle. If you close you will lose changes. Are you sure you want to close?")
		text:               "You have pending parameter updates to a vehicle. If you close you will lose changes. Are you sure you want to close?"
		standardButtons:    StandardButton.Yes | StandardButton.No
		modality:           Qt.ApplicationModal
		visible:            false
		onYes:              activeConnectionsCloseDialog.check()
		function check() {
			for (var index=0; index<QGroundControl.multiVehicleManager.vehicles.count; index++) {
				if (QGroundControl.multiVehicleManager.vehicles.get(index).parameterManager.pendingWrites) {
					zcq.echo("-- pendingParameterWritesCloseDialog:check():if")
					pendingParameterWritesCloseDialog.open()
					return
				}
			}
			activeConnectionsCloseDialog.check()
		}
	}
	MessageDialog {
		id:                 activeConnectionsCloseDialog
		/* qsTr() 返回 sourceText 的翻译版本，如果没有合适的翻译字符串可用，则返回sourceText本身。*/
		title:              qsTr("%1 close").arg(QGroundControl.appName)
		//text:               qsTr("There are still active connections to vehicles. Are you sure you want to exit?")
		text:               "There are still active connections to vehicles. Are you sure you want to exit?"
		standardButtons:    StandardButton.Yes | StandardButton.Cancel
		modality:           Qt.ApplicationModal
		visible:            false
		onYes:              finishCloseProcess()
		function check() {
			if (QGroundControl.multiVehicleManager.activeVehicle) {
				zcq.echo("-- activeConnectionsCloseDialog:check():if")
				activeConnectionsCloseDialog.open()
			} else {
				finishCloseProcess()
			}
		}
	}

	//-------------------------------------------------------------------------
	//-- Vehicle Messages 车辆消息  zcq-qgroundcontrol/src/ui/toolbar/MessageIndicator.qml
	function formatMessage(message) {
		zcq.echo("++ Vehicle Messages 车辆消息")
		message = message.replace(new RegExp("<#E>", "g"),
								  "color: " + qgcPal.warningText + "; font: "
								  + (ScreenTools.defaultFontPointSize.toFixed(0) - 1)
								  + "pt monospace;");
		message = message.replace(new RegExp("<#I>", "g"),
								  "color: " + qgcPal.warningText + "; font: "
								  + (ScreenTools.defaultFontPointSize.toFixed(0) - 1)
								  + "pt monospace;");
		message = message.replace(new RegExp("<#N>", "g"),
								  "color: " + qgcPal.text + "; font: "
								  + (ScreenTools.defaultFontPointSize.toFixed(0) - 1)
								  + "pt monospace;");
		return message;
	}
	function showVehicleMessages() {
		if(!vehicleMessageArea.visible) {
			if(QGroundControl.multiVehicleManager.activeVehicleAvailable) {
				messageText.text = formatMessage(activeVehicle.formatedMessages)
				//-- Hack to scroll to last message
				for (var i = 0; i < activeVehicle.messageCount; i++)
					messageFlick.flick(0,-5000)
				activeVehicle.resetMessages()
			} else {
				//messageText.text = qsTr("No Messages")
				messageText.text = "No Messages"
			}
			vehicleMessageArea.open()
		}
	}
	onFormatedMessageChanged: {
		if(vehicleMessageArea.visible) {
			messageText.append(formatMessage(formatedMessage))
			//-- Hack to scroll down
			messageFlick.flick(0,-500)
		}
	}
	Popup {  // Popup 弹出式顶层窗口
		id:                 vehicleMessageArea
		width:              mainWindow.width  * 0.666
		height:             mainWindow.height * 0.666
		modal:              true
		focus:              true
		x:                  Math.round((mainWindow.width  - width)  * 0.5)
		y:                  Math.round((mainWindow.height - height) * 0.5)
		closePolicy:        Popup.CloseOnEscape | Popup.CloseOnPressOutside
		visible: false
		background: Rectangle {
			anchors.fill:   parent
			color:          qgcPal.window
			//border.width:	10
			border.color:   "red" // qgcPal.text
			radius:         ScreenTools.defaultFontPixelHeight * 0.5
		}
		QGCFlickable {///QGC版本的可闪烁控制，显示水平/垂直滚动指示
			id:                 messageFlick
			anchors.margins:    ScreenTools.defaultFontPixelHeight
			anchors.fill:       parent
			contentHeight:      messageText.height
			contentWidth:       messageText.width
			pixelAligned:       true
			clip:               true
			visible:			true
			TextEdit {
				id:             messageText
				readOnly:       true
				textFormat:     TextEdit.RichText
				color:          "blue" //qgcPal.text
			}
		}
		//-- Dismiss Vehicle Messages
		QGCColoredImage {
			anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
			anchors.top:        parent.top
			anchors.right:      parent.right
			width:              ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 1.5 : ScreenTools.defaultFontPixelHeight
			height:             width
			sourceSize.height:  width
			source:             "/res/XDelete.svg"		// 删除图标
			fillMode:           Image.PreserveAspectFit
			mipmap:             true
			smooth:             true
			color:              "#FF00B8" //qgcPal.text
			MouseArea {
				anchors.fill:       parent
				anchors.margins:    ScreenTools.isMobile ? -ScreenTools.defaultFontPixelHeight : 0
				onClicked: {
					vehicleMessageArea.close()
				}
			}
		}
		//-- Clear Messages
		QGCColoredImage {
			anchors.bottom:     parent.bottom
			anchors.right:      parent.right
			anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
			height:             ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 1.5 : ScreenTools.defaultFontPixelHeight
			width:              height
			sourceSize.height:   height
			source:             "/res/TrashDelete.svg"		// 删除图标
			fillMode:           Image.PreserveAspectFit
			mipmap:             true
			smooth:             true
			color:              "#FF0008" // qgcPal.text
			MouseArea {
				anchors.fill:   parent
				onClicked: {
					if(QGroundControl.multiVehicleManager.activeVehicleAvailable) {
						activeVehicle.clearMessages();
						vehicleMessageArea.close()
					}
				}
			}
		}
	}

	//-------------------------------------------------------------------------
	//-- System Messages 配置视图
	property var    _messageQueue:      []
	property string _systemMessage:     ""
	function showMessage(message) {
		zcq.echo("++ System Messages" + zcqfile)
		vehicleMessageArea.close()
		if(systemMessageArea.visible || QGroundControl.videoManager.fullScreen) {
			_messageQueue.push(message)
		} else {
			_systemMessage = message
			systemMessageArea.open()
		}
	}
	function showMissingParameterOverlay(missingParamName) {
		zcq.echo("++ showMissingParameterOverlay()" + zcqfile)
		showError(qsTr("Parameters missing: %1").arg(missingParamName))
	}
	function showFactError(errorMsg) {
		zcq.echo("++ showFactError()" + zcqfile)
		showError(qsTr("Fact error: %1").arg(errorMsg))
	}
	Popup {		// Popup 弹出式顶层窗口
		id:                 systemMessageArea
		y:                  ScreenTools.defaultFontPixelHeight
		x:                  Math.round((mainWindow.width - width) * 0.5)
		width:              mainWindow.width  * 0.55
		height:             ScreenTools.defaultFontPixelHeight * 6
		modal:              false
		focus:              true
		closePolicy:        Popup.CloseOnEscape
		background: Rectangle {
			anchors.fill:   parent
			color:          qgcPal.alertBackground
			radius:         ScreenTools.defaultFontPixelHeight * 0.5
			border.color:   qgcPal.alertBorder
			border.width:   2
		}
		onOpened: {
			systemMessageText.text = mainWindow._systemMessage
		}
		onClosed: {
			//-- Are there messages in the waiting queue?
			if(mainWindow._messageQueue.length) {
				mainWindow._systemMessage = ""
				//-- Show all messages in queue0
				for (var i = 0; i < mainWindow._messageQueue.length; i++) {
					var text = mainWindow._messageQueue[i]
					if(i) mainWindow._systemMessage += "<br>"
					mainWindow._systemMessage += text
				}
				//-- Clear it
				mainWindow._messageQueue = []
				systemMessageArea.open()
			} else {
				mainWindow._systemMessage = ""
			}
		}
		/* Flickable 项目将其子项目放置在一个可以被拖动和轻击的表面上，从而使子项目上的视图滚动。
这种行为形成了旨在显示大量子项(如 ListView 和 GridView )的Items的基础。
在传统的用户界面中，可以使用标准控件来滚动视图，例如滚动条和箭头按钮。
在某些情况下，还可以通过在移动光标时按住鼠标按钮直接拖动视图。
在基于触摸的用户界面中，这种拖动操作通常与一个轻弹操作相辅相成，在用户停止触摸视图后，滚动将继续。
Flickable不会自动剪辑其内容。如果它不是作为全屏项目使用，您应该考虑将clip属性设置为true。*/
		Flickable {
			id:                 systemMessageFlick
			anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
			anchors.fill:       parent
			contentHeight:      systemMessageText.height
			contentWidth:       systemMessageText.width
			boundsBehavior:     Flickable.StopAtBounds
			pixelAligned:       true
			clip:               true
			//visible:			true
			TextEdit {
				id:             systemMessageText
				width:          systemMessageArea.width - systemMessageClose.width - (ScreenTools.defaultFontPixelHeight * 2)
				anchors.centerIn: parent
				readOnly:       true
				textFormat:     TextEdit.RichText
				font.pointSize: ScreenTools.defaultFontPointSize
				font.family:    ScreenTools.demiboldFontFamily
				wrapMode:       TextEdit.WordWrap
				color:          "#B23AEE"
			}
		}
		//-- Dismiss Critical Message  解雇关键消息
		QGCColoredImage {
			id:                 systemMessageClose
			anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
			anchors.top:        parent.top
			anchors.right:      parent.right
			width:              ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 1.5 : ScreenTools.defaultFontPixelHeight
			height:             width
			sourceSize.height:  width
			source:             "/res/XDelete.svg"		// 删除图标
			fillMode:           Image.PreserveAspectFit
			color:              qgcPal.alertText
			MouseArea {
				anchors.fill:       parent
				anchors.margins:    -ScreenTools.defaultFontPixelHeight
				onClicked: {
					systemMessageArea.close()
				}
			}
		}
		//-- More text below indicator  更多指示文本
		QGCColoredImage {
			anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
			anchors.bottom:     parent.bottom
			anchors.right:      parent.right
			width:              ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 1.5 : ScreenTools.defaultFontPixelHeight
			height:             width
			sourceSize.height:  width
			source:             "/res/ArrowDown.svg"	// 下载图标
			fillMode:           Image.PreserveAspectFit
			visible:            systemMessageText.lineCount > 5
			color:              qgcPal.alertText
			MouseArea {
				anchors.fill:   parent
				onClicked: {
					systemMessageFlick.flick(0,-500)
				}
			}
		}
	}

	//-------------------------------------------------------------------------
	//-- Indicator Popups
	function showPopUp(item, dropItem) {
		zcq.echo("++ showPopUp() 显示 弹出式顶层窗口" + zcqfile)
		indicatorDropdown.currentIndicator = dropItem
		indicatorDropdown.currentItem = item
		indicatorDropdown.open()
	}
	function hidePopUp() {
		zcq.echo("++ hidePopUp() 关闭 弹出式顶层窗口" + zcqfile)
		indicatorDropdown.close()
		indicatorDropdown.currentItem = null
		indicatorDropdown.currentIndicator = null
	}
	Popup {		// Popup 弹出式顶层窗口
		id:             indicatorDropdown
		y:              ScreenTools.defaultFontPixelHeight
		modal:          true
		focus:          true
		closePolicy:    Popup.CloseOnEscape | Popup.CloseOnPressOutside
		property var    currentItem:        null
		property var    currentIndicator:   null
		background: Rectangle {
			width:  loader.width
			height: loader.height
			color:  "transparent" // "#8B6914" //Qt.rgba(0,0,0,0)
		}
		Loader {
			id:             loader
			onLoaded: {
				var centerX = mainWindow.contentItem.mapFromItem(indicatorDropdown.currentItem, 0, 0).x - (loader.width * 0.5)
				if((centerX + indicatorDropdown.width) > (mainWindow.width - ScreenTools.defaultFontPixelWidth)) {
					centerX = mainWindow.width - indicatorDropdown.width - ScreenTools.defaultFontPixelWidth
				}
				indicatorDropdown.x = centerX
			}
		}
		onOpened: {
			loader.sourceComponent = indicatorDropdown.currentIndicator
		}
		onClosed: {
			loader.sourceComponent = null
			indicatorDropdown.currentIndicator = null
		}
	}
}
