pragma Singleton //xxx.qml with custom singleton type definition
// pragma Singleton 这句话是声明本 qml 文件是作为一个单例对象，不允许被构建多次

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Window 2.2

import QGroundControl                       1.0
import QGroundControl.ScreenToolsController 1.0

import QGroundControl.Zcq_debug     1.0

/*!  The ScreenTools Singleton provides information on QGC's standard font metrics.
 It also provides information on screen size which can be used to adjust user interface
 for varying available screen real estate.
 QGC has four standard font sizes: default, small, medium and large.
 The QGC controls use the default font for display and you should use this font
 for most text within the system that is drawn using something other than a standard QGC control. The small font is smaller than the default font.
 The medium and large fonts are larger than the default font.
提供有关QGC的标准字体指标的信息。 它还提供有关屏幕的信息 尺寸可用于调整用户界面以进行不同可用屏幕房地产。
QGC有四个标准字体大小：小，默认，中型和大。 QGC控件使用默认字体来显示，您应该使用此字体
对于系统内的大多数文本，使用标准QGC控件以外的某些内容绘制。 小字体小于默认字体。

 Usage:
		import QGroundControl.ScreenTools 1.0
		Rectangle {
			anchors.fill:       parent
			anchors.margins:    ScreenTools.defaultFontPixelWidth
			...
		} */
Item {
	id: _screenTools

	Zcq_debug { id : zcq }
	readonly property string zcqfile: " -------- ScreenTools.qml "

	//-- The point and pixel(像素) font size values are computed at runtime

	property real toolbar_height: 30 // 图标栏
	property real hufei_y: 0

	/// 工具栏
	//	property real y_Button: 0 /// 视图
	//	property real y_Buttonheight: 0 /// QGCToolBarButton.qml
	//	property real x_Buttonwidth: 0 /// QGCToolBarButton.qml

	property real smallFontPointSize:       10 // 小字体点大小
	property real defaultFontPointSize:     10 // 默认字体大小
	property real mediumFontPointSize:      10 // 中型字体点大小
	property real largeFontPointSize:       10 // 大字体点大小

	property real platformFontPointSize:    10 // 平台字体大小

	/* You can use this property to position ui elements in a screen resolution independent manner. Using fixed positioning values should not
	be done. All positioning should be done using anchors or a ratio of the defaultFontPixelHeight and defaultFontPixelWidth values. This way
	your ui elements will reposition themselves appropriately on varying screen sizes and resolutions.
	您可以使用此属性以屏幕分辨率为独立方式定位UI元素。 使用固定定位值不应 完成。
	所有定位应该使用锚点或默认字体像素高度和默认字体像素宽度值的比率进行。
	这边走 您的UI元素将在不同的屏幕大小和分辨率上适当地重新定位。 */
	property real defaultFontPixelHeight:   10 // 默认字体像素高度

	/* You can use this property to position ui elements in a screen resolution independent manner. Using fixed positioning values should not
	be done. All positioning should be done using anchors or a ratio of the defaultFontPixelHeight and defaultFontPixelWidth values. This way
	your ui elements will reposition themselves appropriately on varying screen sizes and resolutions.
	您可以使用此属性以屏幕分辨率为独立方式定位UI元素。 使用固定定位值不应 完成。
	所有定位应该使用锚点或默认字体像素高度和默认字体像素宽度值的比率进行。
	这边走 您的UI元素将在不同的屏幕大小和分辨率上适当地重新定位。 */
	property real defaultFontPixelWidth:    10 // 默认字体像素宽度

	readonly property real smallFontPointRatio:      0.80   // 小字体点比率
	readonly property real mediumFontPointRatio:     1 //1.10   // 中型字体点比率
	readonly property real largeFontPointRatio:      1.30    // 大字体点比率

	property real realPixelDensity: {
		//-- If a plugin defines it, just use what it tells us
		if(QGroundControl.corePlugin.options.devicePixelDensity != 0) {
			return QGroundControl.corePlugin.options.devicePixelDensity
		}
		//-- Android is rather unreliable
		if(isAndroid) {
			// Lets assume it's unlikely you have a tablet over 300mm wide
			if((Screen.width / Screen.pixelDensity) > 300) {
				return Screen.pixelDensity * 2
			}
		}
		//-- Let's use what the system tells us
		return Screen.pixelDensity // 3.645956202882199
	}

	property bool isAndroid:                        ScreenToolsController.isAndroid
	property bool isiOS:                            ScreenToolsController.isiOS
	property bool isMobile:                         ScreenToolsController.isMobile
	property bool isWindows:                        ScreenToolsController.isWindows
	property bool isDebug:                          ScreenToolsController.isDebug
	property bool isMac:                            ScreenToolsController.isMacOS
	property bool isTinyScreen: /*小屏幕*/   (Screen.width / realPixelDensity) < 120 // 120mm
	property bool isShortScreen:  /*短暂屏幕*/ ((Screen.height / realPixelDensity) < 120) || (ScreenToolsController.isMobile && ((Screen.height / Screen.width) < 0.6))
	property bool isHugeScreen:                     (Screen.width / realPixelDensity) >= (23.5 * 25.4) // 27" monitor
	property bool isSerialAvailable:                ScreenToolsController.isSerialAvailable

	readonly property real minTouchMillimeters:     10      ///< Minimum touch size in millimeters
	property real minTouchPixels:                   0       ///< Minimum touch size in pixels

	// The implicit heights/widths for our custom control set
	property real implicitButtonWidth:              Math.round(defaultFontPixelWidth *  (isMobile ? 1.1 : 1.0))
	property real implicitButtonHeight:             Math.round(defaultFontPixelHeight * (isMobile ? 1.1 : 1.0))
	property real implicitCheckBoxHeight:           Math.round(defaultFontPixelHeight * (isMobile ? 1.1 : 1.1))
	property real implicitRadioButtonHeight:        implicitCheckBoxHeight
	property real implicitTextFieldHeight:          Math.round(defaultFontPixelHeight * (isMobile ? 1.6 : 1.2))
	property real implicitComboBoxHeight:           Math.round(defaultFontPixelHeight * (isMobile ? 1.2 : 1.0))
	property real implicitComboBoxWidth:            Math.round(defaultFontPixelWidth *  (isMobile ? 1.0 : 1.0))
	property real comboBoxPadding:                  defaultFontPixelWidth
	property real implicitSliderHeight:             isMobile ?
														Math.max(defaultFontPixelHeight, minTouchPixels) :
														defaultFontPixelHeight
	// It's not possible to centralize an even number of pixels, checkBoxIndicatorSize should be an odd number to allow centralization
	property real checkBoxIndicatorSize:            Math.floor(defaultFontPixelHeight * (isMobile ? 1.2 : 1.0))
	property real radioButtonIndicatorSize:         checkBoxIndicatorSize

	readonly property string normalFontFamily:      ScreenToolsController.normalFontFamily
	readonly property string demiboldFontFamily:    ScreenToolsController.boldFontFamily
	readonly property string fixedFontFamily:       ScreenToolsController.fixedFontFamily

	//	Component.onCompleted: {
	//		zcq.echo("Component.onCompleted: {...}" + zcqfile)
	//	}

	/* This mostly works but for some reason, reflowWidths() in SetupView doesn't change size.
	   I've disabled (in release builds) until I figure out why. Changes require a restart for now.
	*/
	Connections {
		target: QGroundControl.settingsManager.appSettings.appFontPointSize
		onValueChanged: {
			zcq.echo("Connections:onValueChanged" + zcqfile)
			_setBasePointSize(QGroundControl.settingsManager.appSettings.appFontPointSize.value)
		}
	}

	onRealPixelDensityChanged: {
		zcq.echo("onRealPixelDensityChanged" + zcqfile)
		_setBasePointSize(defaultFontPointSize)
	}

	function printScreenStats() {
		zcq.echo('ScreenTools: Screen.width: ' + Screen.width + ' Screen.height: ' + Screen.height + ' Screen.pixelDensity: ' + Screen.pixelDensity)
	}

	/// Returns the current x position of the mouse in global screen coordinates.
	function mouseX() {
		return ScreenToolsController.mouseX()
	}

	/// Returns the current y position of the mouse in global screen coordinates.
	function mouseY() {
		return ScreenToolsController.mouseY()
	}

	/// private
	function _setBasePointSize(pointSize) {
		zcq.echo("_setBasePointSize(" + pointSize + ")" + zcqfile)

		_textMeasure.font.pointSize = pointSize
		/*默认字体大小*/
		defaultFontPointSize    = pointSize
		/*默认字体像素高度*/
		defaultFontPixelHeight  = Math.round(pointSize*1.45)
		/*默认字体像素宽度*/
		defaultFontPixelWidth   = Math.round(pointSize*1.0)
		/*小字体点大小*/
		smallFontPointSize      = defaultFontPointSize  * _screenTools.smallFontPointRatio
		/*中型字体点大小*/
		mediumFontPointSize     = defaultFontPointSize  * _screenTools.mediumFontPointRatio
		/*大字体点大小*/
		largeFontPointSize      = defaultFontPointSize  * _screenTools.largeFontPointRatio
		minTouchPixels          = Math.round(minTouchMillimeters * realPixelDensity)
		if (minTouchPixels / Screen.height > 0.15) {
			// If using physical sizing takes up too much of the vertical real estate fall back to font based sizing
			minTouchPixels      = defaultFontPixelHeight * 3
		}

		zcq.echo("小字体点大小 smallFontPointSize=" + smallFontPointSize)
		zcq.echo("默认字体大小 defaultFontPointSize=" + defaultFontPointSize)
		zcq.echo("中型字体点大小 mediumFontPointSize=" + mediumFontPointSize)
		zcq.echo("大字体点大小 largeFontPointSize=" + largeFontPointSize)
		zcq.echo("平台字体大小 platformFontPointSize=" + platformFontPointSize)
		zcq.echo("默认字体像素高度 defaultFontPixelHeight=" + defaultFontPixelHeight)
		zcq.echo("默认字体像素宽度 defaultFontPixelWidth=" + defaultFontPixelWidth)
		zcq.echo("realPixelDensity=" + realPixelDensity)
		zcq.echo("isTinyScreen=" + isTinyScreen)
		zcq.echo("isShortScreen=" + isShortScreen)
		zcq.echo("isHugeScreen=" + isHugeScreen)
		zcq.echo("isSerialAvailable=" + isSerialAvailable)
		zcq.echo("minTouchPixels=" + minTouchPixels)
		zcq.echo("implicitButtonWidth=" + implicitButtonWidth)
		zcq.echo("implicitButtonHeight=" + implicitButtonHeight)
		zcq.echo("implicitCheckBoxHeight=" + implicitCheckBoxHeight)
		zcq.echo("implicitTextFieldHeight=" + implicitTextFieldHeight)
		zcq.echo("implicitComboBoxHeight=" + implicitComboBoxHeight)
		zcq.echo("implicitComboBoxWidth=" + implicitComboBoxWidth)
		zcq.echo("normalFontFamily=" + normalFontFamily)
		zcq.echo("demiboldFontFamily=" + demiboldFontFamily)
		zcq.echo("toolbar_height=" + toolbar_height)
		zcq.echo("checkBoxIndicatorSize=" + checkBoxIndicatorSize)
		zcq.echo("")
	}

	Text {
		id:     _defaultFont
		text:   "X1"
	}

	Text {
		id:     _textMeasure
		text:   "X2"
		font.family:    normalFontFamily
		/*	contentHeight : 保存内容的高度。它用于计算导航栏的总隐式高度
			contentWidth : 保存内容的宽度。它用于计算导航栏的总隐式宽度 */
		Component.onCompleted: {
			//-- First, compute platform, default size
			if(ScreenToolsController.isMobile) {
				//-- Check iOS really tiny screens (iPhone 4s/5/5s)
				if(ScreenToolsController.isiOS) {
					if(ScreenToolsController.isiOS && Screen.width < 570) {
						// For iPhone 4s size we don't fit with additional tweaks to fit screen,
						// we will just drop point size to make things fit. Correct size not yet determined.
						platformFontPointSize = 11;  // This will be lowered in a future pull
					} else {
						platformFontPointSize = 13;
					}
				} else if((Screen.width / realPixelDensity) < 120) {
					platformFontPointSize = 11;
					// Other Android
				} else {
					platformFontPointSize = 13; // 平台字体大小
				}
			} else {
				platformFontPointSize = _defaultFont.font.pointSize;
			}
			//-- See if we are using a custom size
			var _appFontPointSizeFact = QGroundControl.settingsManager.appSettings.appFontPointSize
			var baseSize = _appFontPointSizeFact.value
			//-- Sanity check
			if(baseSize < _appFontPointSizeFact.min || baseSize > _appFontPointSizeFact.max) {
				baseSize = platformFontPointSize;
				_appFontPointSizeFact.value = baseSize
			}
			//-- Set size saved in settings
			_screenTools._setBasePointSize(baseSize);
		}
	}
}
