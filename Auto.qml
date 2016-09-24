import QtQuick 2.0

import "./singletons" as Singletons

QtObject {
    id: root
    property Parking parking
    property var path: []
    property Place currentPlace
    property Place nextPlace
    property Place fromPlace
    property Place exitIndex

    property int speed: 10
    property alias waitTime: waitTimer.interval
    property bool toExit: false

    Timer {
        id: moveTimer

        interval: 300
        repeat: true
        running: path.length > 0 && !nextPlace
        onRunningChanged: {
            if (!running && !toExit) {
                waitTimer.start();
            }
        }

        onTriggered: {
            if (root.currentPlace.index === root.exitIndex && toExit) {
                root.currentPlace.freePlace(root.fromPlace.index);
                root.destroy();
            }

            if (!root.nextPlace) {
                root.nextPlace = root.toExit ? parking.placeArray[path.shift()]
                                             : parking.placeArray[path.pop()];
            }
            if (root.nextPlace.isRoad) {
                if (!root.nextPlace.isBusy(root.currentPlace.index)) {
                    if (root.currentPlace)
                        root.currentPlace.freePlace(root.fromPlace.index);
                    root.nextPlace.takePlace(root.currentPlace.index);
                    root.fromPlace = root.currentPlace;
                    root.currentPlace = root.nextPlace;
                    root.nextPlace = undefined;
                }
            }
            root.pathChanged();
        }
    }

    Timer {
        id: waitTimer
        repeat: true
        running: false

        onTriggered: {
            toExit = true;
            root.fromPlace = undefined;
            root.path = root.parking.pathArray[root.exitIndex][currentPlace.index];
        }
    }
}
