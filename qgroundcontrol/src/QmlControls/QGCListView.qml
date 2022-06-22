import QtQuick 2.3

import QGroundControl.Palette 1.0

// 列表视图中的项目可以水平或垂直布局。列表视图本质上是可闪烁的，因为 ListView 继承自 Flickable
/// QGC version of ListVIew control that shows horizontal/vertial scroll indicators
ListView {
    id:             root
    boundsBehavior: Flickable.StopAtBounds

    property color indicatorColor: qgcPal.text

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    Component.onCompleted: {
        var indicatorComponent = Qt.createComponent("QGCFlickableVerticalIndicator.qml")
        indicatorComponent.createObject(root)
        indicatorComponent = Qt.createComponent("QGCFlickableHorizontalIndicator.qml")
        indicatorComponent.createObject(root)
    }
}

/*
ListView 显示 从 内置QML类型(如ListModel和XmlListModel)
或c++中定义的继承自QAbstractItemModel或QAbstractListModel的自定义模型类创建的模型中的数据。
ListView有一个模型，它定义要显示的数据，还有一个委托，它定义数据应该如何显示。
列表视图中的项目可以水平或垂直布局。列表视图本质上是可闪烁的，因为 ListView 继承自 Flickable
*/
