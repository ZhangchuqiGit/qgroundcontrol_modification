/// Saves main window position and size

import QtQuick          2.11
import QtQuick.Window   2.11
import QtQuick.Controls 2.4
import Qt.labs.settings 1.0

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0

import QGroundControl.Zcq_debug     1.0

Item {
    property Window window

    property bool _enabled: !ScreenTools.isMobile && QGroundControl.corePlugin.options.enableSaveMainWindowPosition

    Settings {
        id:         s
        category:   "MainWindowState"

        property int x
        property int y
        property int width
        property int height
        property int visibility
    }

	 Zcq_debug { id : zcq }
	 readonly property string zcqfile: " -------- MainWindowSavedState.qml "

    Component.onCompleted: {
        if (_enabled && s.width && s.height) {
            window.x = s.x;
            window.y = s.y;
            window.width = s.width;
            window.height = s.height;
            window.visibility = s.visibility;
        }
		zcq.echo("Component.onCompleted: {...}" + zcqfile)
    }

    Connections {
        target:                 window
        onXChanged:             if(_enabled) saveSettingsTimer.restart()
        onYChanged:             if(_enabled) saveSettingsTimer.restart()
        onWidthChanged:         if(_enabled) saveSettingsTimer.restart()
        onHeightChanged:        if(_enabled) saveSettingsTimer.restart()
        onVisibilityChanged:    if(_enabled) saveSettingsTimer.restart()
    }

    Timer {
        id:             saveSettingsTimer
        interval:       1000
        repeat:         false
        onTriggered:    saveSettings()
    }

    function saveSettings() {
        if(_enabled) {
            switch(window.visibility) {
            case ApplicationWindow.Windowed:
                s.x = window.x;
                s.y = window.y;
                s.width = window.width;
                s.height = window.height;
                s.visibility = window.visibility;
                break;
            case ApplicationWindow.FullScreen:
                s.visibility = window.visibility;
                break;
            case ApplicationWindow.Maximized:
                s.visibility = window.visibility;
                break;
            }
        }
    }
}
