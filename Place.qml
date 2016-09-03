import QtQuick 2.0

import "./singletons" as Singletons

Rectangle {
    id: root

    property bool isRoad: false
    property int index: -1
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

    Connections {
        target: Singletons.common
        onReset: root.destroy();
        onStart: root.destroy();
        onClear: root.destroy();
    }

    width: 50
    height: 60

    visible: Singletons.common.visibleState === 0 || Singletons.common.visibleState === 2
    color: isRoad ? "steelBlue" : "grey"
    opacity: 0.5
    border.color: "black"

    Text{
        anchors.centerIn: parent
        text: root.index
    }
}
