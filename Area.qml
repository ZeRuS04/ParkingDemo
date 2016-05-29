import QtQuick 2.0

import "./singletons" as Singletons

Item {
    id: root

//    property rect parking: Qt.rect(-1,-1,0,0)


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
                        parking.addEntry(mouse.x, mouse.y, entry.rotation)
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

/*
    MouseArea {
        anchors.fill: parent

        onPressed: {
            root.parking.x = mouse.x;
            root.parent.y = mouse.y;
        }

        onPositionChanged: {
            var width = mouse.x - root.parking.x;
           var height = mouse.y - root.parking.y;
           root.parking.width = Math.abs(width);
           root.parking.height = Math.abs(height);\
        }
        onReleased: parkingRect.start();
    }


    ParkingRect {
        id: parkingRect
        x: parking.x
        y: parking.y
        width: parking.width
        height: parking.height
    }
*/


}
