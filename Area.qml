import QtQuick 2.0

Item {
    id: root

    property rect  parking: Qt.rect(-1,-1,0,0)
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
           root.parking.height = Math.abs(height);
//           if(width  < 0)
//               root.parking.x = mouse.x;
//           if (height < 0)
//               root.parent.y = mouse.y;
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
}
