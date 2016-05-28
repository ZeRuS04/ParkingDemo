import QtQuick 2.0

import "./singletons" as Singletons

Item {
    id: parking

    property point currentVertex: currentIndex >= 0 && currentIndex < vertexCount ? vertexes[currentIndex]
                                                                                  : Qt.point(-1,-1)
    property int currentIndex: -1
    property int vertexCount: vertexes.length
    signal posChanged(var ind)

    property var vertexes: []

    function removeVertex(index) {
        if((index < 0) || (index >= vertexes.length))
            return;
        var point = vertexes.splice(index, 1);
        parking.vertexesChanged();
        return point;
    }

    function addVertex(x, y) {
        vertexes.push(Qt.point(x,y));
        parking.vertexesChanged();
        console.log("vertex (%1;%2) has been added".arg(x).arg(y));
    }

    function checkNeighboring(x, y, index) {
        var retPoint = Qt.point(x,y);
        for(var i = 0; i < vertexCount; i++){
            if(i == index)
                continue;
            var vertex = parking.vertexes[i];
            if(Math.abs(vertex.x - x) < 20){
                retPoint.x = vertex.x;
            }
            if(Math.abs(vertex.y - y) < 20){
                retPoint.y = vertex.y;
            }
        }
        return retPoint;
    }

    function changeVertex(x, y, index) {
        if((index < 0) || (index >= vertexes.length))
            return;

        vertexes[index].x = x;
        vertexes[index].y = y;

        parking.vertexesChanged();
    }

    focus: true

    Keys.onPressed: {
        if (event.key === Qt.Key_Z && (event.modifiers & Qt.ControlModifier))
            removeVertex(vertexCount - 1);
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        Connections {
            target: parking
            onVertexesChanged: canvas.requestPaint()
        }

        onPaint: {
            if(parking.vertexCount === 0)
                return;

            var ctx = canvas.getContext("2d");

            ctx.clearRect (0, 0, canvas.width, canvas.height);
            ctx.strokeStyle = Qt.rgba(1, 0, 0, 1);
            ctx.beginPath ();
            ctx.moveTo(parking.vertexes[0].x, parking.vertexes[0].y);
            for(var i = parking.vertexCount - 1; i >= 0; i--) {
                ctx.lineTo(parking.vertexes[i].x, parking.vertexes[i].y);
            }
            ctx.closePath();
            ctx.stroke();
        }
    }

    Repeater{
        id: parkingVertecies
        anchors.fill: parent
        model: parking.vertexes
        delegate: Rectangle{
            id: vertex
            property alias select: vertexMA.pressed
            property int i: index
            x: modelData.x - width/2
            y: modelData.y - height/2
            color: (index == 0) || (index == parking.vertexCount-1) ? "red" : "green"
            border.color: "black"
            border.width: select ? 1 : 0
            width: parking.currentIndex === vertex.i ? 15 : 10
            height: width
            radius: width/2

            MouseArea{
                id: vertexMA
                anchors.fill: parent;
                hoverEnabled: true;

                onEntered: parking.currentIndex = vertex.i;
                onExited: parking.currentIndex = -1
            }
        }
    }
}
