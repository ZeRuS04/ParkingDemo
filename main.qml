import QtQuick 2.6
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1

import "./singletons" as Singletons

Window {
    id: mainRect

    property real scaleCof: 1

    title: qsTr("Parking demo")
    visible: true

    width: 980
    height: 600
//    width: 1980
//    height: 1080

    Area {
        anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: data.top
    }

    Item{
        id: data
        height: 100
        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
        anchors.margins: 30
        GridLayout{
            rows: 3
            columns: 2
            anchors.fill: parent
//             Text{
//                 Layout.fillHeight: true
//                 Layout.fillWidth: true
//                 text: "Parking size = " + parking.size;
//                 verticalAlignment: Text.AlignVCenter
//             }
//             Text{
//                 Layout.fillHeight: true
//                 Layout.fillWidth: true
//                 text: "Parking capacity = " + parking.capacity;
//                 verticalAlignment: Text.AlignVCenter
//             }
             Row{
                 Layout.fillHeight: true
                 Layout.columnSpan: 2
                 spacing: 20
                 Text{
//                     width: 100
                     text: "Road count";
                 }
                 SpinBox{
                     id: roadCount
                     width: 100
                     value: 2
                     minimumValue: 1
                     maximumValue: 2
                     onValueChanged: Singletons.common.roadCount = roadCount.value
                 }
                 Text{
//                     width: 100
                     text: "Parking place size: w=";
                 }
                 SpinBox{
                     id: placeWidth
                     width: 100
                     value: Singletons.common.placeWidth
                     minimumValue: 2
                     maximumValue: 10000
                     onValueChanged: Singletons.common.placeWidth = placeWidth.value
                 }
                 Text{
                     text: " h=";
                 }
                 SpinBox{
                     id: placeHeigh
                     width: 100
                     value: Singletons.common.placeHeight
                     minimumValue: 2
                     maximumValue: 10000
                     onValueChanged: Singletons.common.placeHeigh = placeHeigh.value
                 }
                 Text{
                     text: "Visible:";
                 }
                 ComboBox {
                     id: graphState
                     width: 100
                     model: [ "Main graph", "Road graph", "Access Graph", "None"]

                     onCurrentIndexChanged: Singletons.common.visibleGraph = currentIndex;
                 }
                 ComboBox {
                     id: mode
                     width: 100
                     model: [ "All", "Parking", "Places", "Parking rects"]

                     onCurrentIndexChanged: Singletons.common.visibleState = currentIndex;
                 }
             }

             Button{
                text: "Start"

                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 2

                onClicked: {
                    Singletons.common.start();
                }
             }

             Button{
                text: "Reset"

                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 1

                onClicked: {
                    Singletons.common.reset();
                }
             }
             Button{
                text: "Clear"

                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 1

                onClicked: {
                    Singletons.common.clear();
                }
             }
        }
    }
}
