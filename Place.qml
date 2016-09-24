import QtQuick 2.0

import "./singletons" as Singletons

Rectangle {
    id: root

    property bool isRoad: false
    property bool __oldIsRoad: false
    property bool isEntry: false
    property bool isExit: false
    property int index: -1
    property int capacity: isRoad ? Singletons.common.roadCount
                                  : 1
    property var neighborPlaces: []
    property var neighborRoad: []
    property var neighbors: []

    function addNeighborPlaces(placeIndex) {
        if (neighborPlaces.indexOf(placeIndex) == -1 && placeIndex >= 0)
            neighborPlaces.push(placeIndex);
    }
    function addNeighborRoad(placeIndex) {
        if (neighborRoad.indexOf(placeIndex) == -1 && placeIndex >= 0)
            neighborRoad.push(placeIndex);
    }
    function addNeighbors(placeIndex) {
        if (neighbors.indexOf(placeIndex) == -1 && placeIndex >= 0)
            neighbors.push(placeIndex);
    }

    property int autoCount: 0
    property var autoFromArray: []
    function isBusy(placeIndex) {
        if (autoCount >= capacity)
            return true;
        if (autoCount > 0) {
            return autoFromArray.indexOf(placeIndex) !== -1;
        }
    }
    function takePlace(placeIndex) {
        autoFromArray.push(placeIndex);
        autoCount++;
    }
    function freePlace(placeIndex) {
        if (autoFromArray.indexOf(placeIndex) !== -1)
            autoFromArray.splice(autoFromArray.indexOf(placeIndex), 1);
        autoCount--;
    }

    Connections {
        target: Singletons.common
        onReset: root.destroy();
        onStart: root.destroy();
        onClear: root.destroy();
    }

    width: 50
    height: 60

    visible: Singletons.common.visibleState === 0 || Singletons.common.visibleState === 2
    color: {
        if (isEntry)
            return "green";
        if (isExit)
            return "orange";
        return isRoad ? "pink" : "grey"
    }
    opacity: 0.5
    border.color: "black"

    Row {
        visible: width > height
        Repeater {
            model: root.autoCount
            delegate: Rectangle {
                    width: root.width / 2
                    height: root.height
                    color: "orange"
            }
        }
    }

    Column {
        visible: width <= height
        Repeater {
            model: root.autoCount
            delegate: Rectangle {
                    width: root.width
                    height: root.height / root.capacity
                    color: "orange"
            }
        }
    }

    Text{
        anchors.centerIn: parent
        text: root.index
    }

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true
        onClicked: {
            if (Singletons.common.state === 1) {
                root.__oldIsRoad = root.isRoad;
                root.isRoad === true;
                if (root.capacity === 1) {
                    if (!root.isEntry && !root.isExit)
                        root.isEntry = !root.isEntry;
                    else if (root.isEntry && !root.isExit) {
                        root.isEntry = !root.isEntry;
                        root.isExit = !root.isExit;
                    } else if ((!root.isEntry && root.isExit)) {
                        root.isExit = false;
                        
                    }
                }
                if (root.capacity === 2) {
                    root.isEntry = !root.isEntry;
                    root.isExit = !root.isExit;
                }

                if ((root.isEntry || root.isExit) && parking.exitRects.indexOf(root.index) === -1) {
                    parking.exitRects.push(root.index);
                }
                if ((!root.isEntry && !root.isExit) && parking.exitRects.indexOf(root.index) !== -1) {
                    parking.exitRects.splice(parking.exitRects.indexOf(root.index), 1);
                }
            }
        }
    }
}
