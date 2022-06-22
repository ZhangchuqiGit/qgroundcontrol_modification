// pragma Singleton //xxx.qml with custom singleton type definition
// pragma Singleton 这句话是声明本 qml 文件是作为一个单例对象，不允许被构建多次

import QtQuick          2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs  1.3
import QtQuick.Layouts  1.11
import QtQuick.Window   2.11

import QGroundControl 1.0

Item {
	property alias zcq: zcq
	id : zcq
	function echo(_value) {
		var tmp=_value
		console.debug("" + tmp)
	}
}

