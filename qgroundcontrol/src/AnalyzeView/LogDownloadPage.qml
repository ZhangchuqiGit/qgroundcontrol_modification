// 分析视图 面板

import QtQuick              2.3
import QtQuick.Controls     1.2
import QtQuick.Dialogs      1.2
import QtQuick.Layouts      1.2

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0

AnalyzePage {
    id:                 logDownloadPage
    pageComponent:      pageComponent
	pageName:           qsTr("Log Download")//日志下载
    pageDescription:    qsTr("Log Download allows you to download binary log files from your vehicle. Click Refresh to get list of available logs.")
	//日志下载功能，可以让你从飞机上下载二进制日志文件。点击刷新查看可用日志列表。

    property real _margin:          ScreenTools.defaultFontPixelWidth
    property real _butttonWidth:    ScreenTools.defaultFontPixelWidth * 10
	readonly property real _textheight: ScreenTools.defaultFontPixelHeight

    QGCPalette { id: palette; colorGroupEnabled: enabled }

    Component {
        id: pageComponent

        RowLayout {
            width:  availableWidth
            height: availableHeight
            Connections {
                target: logController
                onSelectionChanged: {
                    tableView.selection.clear()
                    for(var i = 0; i < logController.model.count; i++) {
                        var o = logController.model.get(i)
                        if (o && o.selected) {
                            tableView.selection.select(i, i)
                        }
                    }
                }
            }
            TableView {
                id: tableView
                Layout.fillHeight:  true
                model:              logController.model
                selectionMode:      SelectionMode.MultiSelection
                Layout.fillWidth:   true

                TableViewColumn {
					title: qsTr("Id")									//ID
                    width: ScreenTools.defaultFontPixelWidth * 6
                    horizontalAlignment: Text.AlignHCenter
					delegate : Text  {
						height: _textheight
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						text: {
                            var o = logController.model.get(styleData.row)
                            return o ? o.id : ""
                        }
                    }
                }
                TableViewColumn {
					title: qsTr("Date")									//日期
					width: ScreenTools.defaultFontPixelWidth * 28
                    horizontalAlignment: Text.AlignHCenter
					delegate: Text  {
						id: text_height
						height: _textheight
						verticalAlignment: Text.AlignVCenter
						horizontalAlignment: Text.AlignLeft
						text: {
                            var o = logController.model.get(styleData.row)
                            if (o) {
                                //-- Have we received this entry already?
                                if(logController.model.get(styleData.row).received) {
                                    var d = logController.model.get(styleData.row).time
                                    if(d.getUTCFullYear() < 2010)
										return qsTr("Date Unknown")	//日期未知
                                    else
                                        return d.toLocaleString()
                                }
                            }
                            return ""
                        }
                    }
                }
                TableViewColumn {
					title: qsTr("Size")									//大小
					width: ScreenTools.defaultFontPixelWidth * 10
                    horizontalAlignment: Text.AlignHCenter
					delegate : Text  {
						height: _textheight
						verticalAlignment: Text.AlignVCenter
						horizontalAlignment: Text.AlignRight
                        text: {
                            var o = logController.model.get(styleData.row)
                            return o ? o.sizeStr : ""
                        }
                    }
                }
                TableViewColumn {
					title: qsTr("Status")								//状态
					width: ScreenTools.defaultFontPixelWidth * 10
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
						height: _textheight
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						text: {
                            var o = logController.model.get(styleData.row)
                            return o ? o.status : ""
                        }
                    }
                }
            }
            Column {
                spacing:            _margin
                Layout.alignment:   Qt.AlignTop | Qt.AlignLeft
                QGCButton {
                    enabled:    !logController.requestingList && !logController.downloadingLogs
					text:       qsTr("Refresh")//刷新
                    width:      _butttonWidth
                    onClicked: {
                        if (!QGroundControl.multiVehicleManager.activeVehicle || QGroundControl.multiVehicleManager.activeVehicle.isOfflineEditingVehicle) {
							mainWindow.showMessageDialog(
										qsTr("Log Refresh"),
										qsTr("You must be connected to a vehicle in order to download logs."))
                        } else {
                            logController.refresh()
                        }
                    }
                }
                QGCButton {
					enabled:    !logController.requestingList &&
								!logController.downloadingLogs &&
								tableView.selection.count > 0
					text:       qsTr("Download")//下载
                    width:      _butttonWidth
                    onClicked: {
                        //-- Clear selection
                        for(var i = 0; i < logController.model.count; i++) {
                            var o = logController.model.get(i)
                            if (o) o.selected = false
                        }
                        //-- Flag selected log files
                        tableView.selection.forEach(function(rowIndex){
                            var o = logController.model.get(rowIndex)
                            if (o) o.selected = true
                        })
                        fileDialog.title =          qsTr("Select save directory")
                        fileDialog.selectExisting = true
                        fileDialog.folder =         QGroundControl.settingsManager.appSettings.logSavePath
                        fileDialog.selectFolder =   true
                        fileDialog.openForLoad()
                    }
                    QGCFileDialog {
                        id: fileDialog
                        onAcceptedForLoad: {
                            logController.download(file)
                            close()
                        }
                    }
                }
                QGCButton {
                    enabled:    !logController.requestingList && !logController.downloadingLogs && logController.model.count > 0
					text:       qsTr("Erase All")//擦除全部
                    width:      _butttonWidth
                    onClicked:  mainWindow.showComponentDialog(
                        eraseAllMessage,
						qsTr("Delete All Log Files"), // 删除所有日志文件
                        mainWindow.showDialogDefaultWidth,
                        StandardButton.Yes | StandardButton.No)
                    Component {
                        id: eraseAllMessage
                        QGCViewMessage {
                            message:    qsTr("All log files will be erased permanently. Is this really what you want?")
                            function accept() {
                                logController.eraseAll()
                                hideDialog()
                            }
                        }
                    }
                }
                QGCButton {
                    text:       qsTr("Cancel")
                    width:      _butttonWidth
                    enabled:    logController.requestingList || logController.downloadingLogs
                    onClicked:  logController.cancel()
                }
            }
        }
    }
}
