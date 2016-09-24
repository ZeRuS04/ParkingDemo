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

//    width: 980
//    height: 600
    width: 1600
    height: 960

    Area {
        id: area
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
                     id: placeHeight
                     width: 100
                     value: Singletons.common.placeHeight
                     minimumValue: 2
                     maximumValue: 10000
                     onValueChanged: Singletons.common.placeHeight = placeHeight.value
                 }
                 Text{
                     text: "Visible:";
                 }
                 ComboBox {
                     id: graphState
                     width: 100
                     model: [ "Main graph", "Road graph", "Access Graph", "None"]
                     currentIndex: 3
                     onCurrentIndexChanged: Singletons.common.visibleGraph = currentIndex;
                 }
                 ComboBox {
                     id: mode
                     width: 100
                     model: [ "All", "Parking", "Places", "Parking rects"]

                     onCurrentIndexChanged: Singletons.common.visibleState = currentIndex;
                 }

             }

             Row {

                 Layout.fillHeight: true
                 Layout.fillWidth: true
                 Layout.columnSpan: 2

                 spacing: 20
                 TextEdit {
                     id: saveKey
                     width: 120
                 }

                 Button{
                     width: 70
                    text: "Save"
                    enabled: saveKey.text !== ""
                    onClicked: {
                        Singletons.common.save(saveKey.text, area.vertexes);
                    }
                 }
                 ComboBox {
                     id: saved
                     width: 100
                     model: Singletons.common.keys
                     onModelChanged: currentIndex = -1
                 }

                 Button{
                    text: "Load"

                    Layout.fillHeight: true
                    enabled: saved.currentText !== ""

                    onClicked: {
                        Singletons.common.reset();
                        area.vertexes = Singletons.common.load(saved.currentText);
                    }
                 }

                 Button{
                    text: "Remove"

                    Layout.fillHeight: true
                    enabled: saved.currentText !== ""

                    onClicked: {
                        Singletons.common.remove(saved.currentText);
                    }
                 }
                 Button{
                    text: "Clear"

                    Layout.fillHeight: true
                    enabled: saved.currentText !== ""

                    onClicked: {
                        Singletons.common.clearAll();
                    }
                 }
             }
             Button{
                text: "Start"

                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 1

                onClicked: {
                    Singletons.common.start();
                }
             }
             Button{
                text: "Generate Maps"

                Layout.fillHeight: true

                onClicked: {
                    Singletons.common.genMaps();
                }
             }

             Button{
                text: "Send auto"

                Layout.fillHeight: true

                onClicked: {
                    Singletons.common.sendAuto();
                }
             }

             Button{
                text: Singletons.common.state !== 1 ? "Add Entry"
                                                    : "End"

                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 1

                onClicked: {
                    if (Singletons.common.state !== 1)
                        Singletons.common.state = 1;
                    else
                        Singletons.common.state = 0;
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
