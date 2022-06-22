import QtQuick 2.3

import QGroundControl.Palette 1.0

/// QGC version of Flickable control that shows horizontal/vertial scroll indicators
///QGC版本的可闪烁控制，显示水平/垂直滚动指示

/* Flickable 可闪烁的项目将其子节点放在可拖动和轻弹的表面上，导致对子项的视图滚动。 */
// Flickable: QGC版本的可闪烁控制，显示水平/垂直滚动指示
Flickable {
    id:             root
    boundsBehavior: Flickable.StopAtBounds
	//clip:           true
	property color indicatorColor: "yellow" //qgcPal.text
    Component.onCompleted: {
		var indicatorComponent = Qt.createComponent("QGCFlickableVerticalIndicator.qml") // 滚动方式 垂直滚动
        indicatorComponent.createObject(root)
		indicatorComponent = Qt.createComponent("QGCFlickableHorizontalIndicator.qml") // 滚动方式 水平滚动
        indicatorComponent.createObject(root)
    }
}

/* boundsBehavior
Flickable.StopAtBounds -内容不能被拖到闪烁的边界之外，而且闪烁不会超过范围。
Flickable.DragOverBounds -内容可以被拖到闪烁的边界之外，但闪烁不会超过边界。
Flickable.OvershootBounds 超出界限-内容可以超出界限时，轻弹，但内容不能拖到超出界限的闪烁。(因为QtQuick 2.5)
Flickable.DragAndOvershootBounds(默认)-内容可以被拖到闪烁的边界之外，并且在闪烁时可以超过边界。
*/
