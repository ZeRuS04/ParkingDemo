import QtQuick 2.0

import "./singletons" as Singletons

Item {
    id: root

    property alias vertexes: parking.vertexes

    Parking{
        id: parking

        anchors.fill: parent

        MouseArea{
            id: parkingMA
            anchors.fill: parent;
            hoverEnabled: Singletons.common.state === 1
            preventStealing: true
            propagateComposedEvents: true
            onPressed: {
                switch(Singletons.common.state){
                case 0:
                    if(parking.currentIndex === -1) {
                        parking.addVertex(mouse.x, mouse.y);
                        parking.currentIndex = parking.vertexCount-1;
                    }
                    break;
                case 1:
//                        parking.addEntry(mouse.x, mouse.y, entry.rotation)
                    break;
                }
            }

            onPositionChanged: {
                switch(Singletons.common.state){
                case 0:
                    var point = parking.checkNeighboring(mouse.x,mouse.y, parking.currentIndex);
                    parking.changeVertex(point.x, point.y, parking.currentIndex);
                    break;
                }
            }

            onReleased:{
                parking.currentIndex = -1;
            }
        }
    }
}
