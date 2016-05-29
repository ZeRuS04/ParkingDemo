import QtQuick 2.0

import "./singletons" as Singletons
import My.Utils 1.0
Item {
    id: parking

    property point currentVertex: currentIndex >= 0 && currentIndex < vertexCount ? vertexes[currentIndex]
                                                                                  : Qt.point(-1,-1)
    property int currentIndex: -1
    property int vertexCount: vertexes.length

    property var vertexes: []
    property var isConcaveVertex: []

    property var __allPoints: []
    property var rects: []
    property var intersectPoints: []

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

    function angle(index) {
        if(vertexCount < 3)
            return;
        var v1, v2;
        if(index === 0)
            v1 = vertexes[vertexCount-1];
        else
            v1 = vertexes[index-1];
        if(index === vertexCount-1)
            v2 = vertexes[0];
        else
            v2 = vertexes[index+1];
        var x1 = v1.x - vertexes[index].x;
        var y1 = v1.y - vertexes[index].y;
        var angle1 = x1 || y1 ? Math.atan2(-y1, x1) : 0;
        var x2 = v2.x - vertexes[index].x;
        var y2 = v2.y - vertexes[index].y;
        var angle2 = x2 || y2 ? Math.atan2(-y2, x2) : 0;

        var angle = MathUtils.normalizedAngleRad(angle2 - angle1);

        return Math.ceil(MathUtils.radToDeg(angle));
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

        if(index === 0)
            isConcaveVertex[vertexCount - 1] = angle(vertexCount - 1) > 180;
        else
            isConcaveVertex[index-1] = angle(index-1) > 180;
        isConcaveVertex[index] = angle(index) > 180;
        if(index === vertexCount-1)
            isConcaveVertex[0] = angle(0) > 180;
        else
            isConcaveVertex[index+1] = angle(index+1) > 180;

        isConcaveVertexChanged();
        vertexesChanged();
    }

    function fillParking() {
        for (var i = 0; i < intersectPoints.length; i++) {
            generateRect(intersectPoints[i].index, intersectPoints[i].point);
        }

        var component = Qt.createComponent("ParkingRect.qml");
        for(var r = 0; r < rects.length; r++) {
            var rectObject = component.createObject(parking, {"width": rects[r].width, "height": rects[r].height,
                                                        "x": rects[r].x, "y": rects[r].y });
        }
    }

    function generateRect(i, newPoint) {
        var newRect = Qt.rect(-1,-1,0,0);
        var point = vertexes[i];

        var leftIndex = i, rightIndex = i, leftPoint, rightPoint;

        do {
            leftIndex = leftIndex === 0 ? vertexCount - 1 : leftIndex - 1;
            leftPoint = vertexes[leftIndex]
        } while(!isConcaveVertex[leftIndex] && (leftPoint.x === newPoint.x || leftPoint.y === newPoint.y));

        if (isConcaveVertex[leftIndex]) {
            for (var j = 0; j < intersectPoints.length; j++) {
                if (intersectPoints[j].index === leftIndex) {
                    leftPoint = intersectPoints[j].point;
                    break;
                }
            }
        }
        newRect.width = Math.abs(newPoint.x - leftPoint.x);
        newRect.height = Math.abs(newPoint.y - leftPoint.y);
        newRect.x = Math.min(newPoint.x, leftPoint.x);
        newRect.y = Math.min(newPoint.y, leftPoint.y);
        console.log("### newRect1", newRect)
        if(parking.rects.indexOf(newRect) === -1)
            parking.rects.push(newRect);

        newRect = Qt.rect(-1,-1,0,0);
        do {
            rightIndex = rightIndex === vertexCount - 1 ? 0 : rightIndex + 1;
            rightPoint = vertexes[rightIndex]
            console.log('###', i, rightIndex, rightPoint)
        } while(!isConcaveVertex[rightIndex] && (rightPoint.x === newPoint.x || rightPoint.y === newPoint.y));

        if (isConcaveVertex[rightIndex]) {
            for (var j = 0; j < intersectPoints.length; j++) {
                if (intersectPoints[j].index === rightIndex) {
                    rightPoint = intersectPoints[j].point;
                    break;
                }
            }
        }
        newRect.width = Math.abs(newPoint.x - rightPoint.x);
        newRect.height = Math.abs(newPoint.y - rightPoint.y);
        newRect.x = Math.min(newPoint.x, rightPoint.x);
        newRect.y = Math.min(newPoint.y, rightPoint.y);
        console.log("### newRect2", newRect)
        if(parking.rects.indexOf(newRect) === -1)
            parking.rects.push(newRect);
    }

    function splitParking() {
        var hLines = [];
        var vLines = [];
        var line;
        for(var i = 0; i < vertexCount; i++) {
            line = {"p1":vertexes[i], "p2":(i === vertexCount -1 ? vertexes[0] : vertexes[i+1])}
//            console.log("### lines", vertexes[0], )
            if (line.p1.x !== line.p2.x)
                hLines.push(line);
            else
                vLines.push(line);
        }

            // Пройдем по всем вершинам
        for(var i = 0; i < vertexCount; i++) {
            if (!isConcaveVertex[i])
                continue;
            // Если вершина вогнутая

            var intersectPoint, intersectPoints = [];
            var point = vertexes[i];
            // Рассмотрим соседнюю вершину слева
            var leftPoint = i === 0 ? vertexes[vertexCount - 1] : vertexes[i-1]
            if(leftPoint.x === point.x) {
                // Проверим пересечения с горизонтальными линиями
                for (var j = 0; j < hLines.length; j++) {
                    if(leftPoint.y < point.y) {
                        intersectPoint = MathUtils.intersect(hLines[j].p1, hLines[j].p2, point, Qt.point(point.x, parking.height))
                        if (intersectPoint.x !== -1 && intersectPoint.y !== -1 && MathUtils.lineLength(point, intersectPoint) > 0 &&
                                leftPoint !== intersectPoint) {
                            intersectPoints.push({"p": intersectPoint, "length": MathUtils.lineLength(point, intersectPoint)})

                        }
                    } else {
                        intersectPoint = MathUtils.intersect(hLines[j].p1, hLines[j].p2, point, Qt.point(point.x, 0))
                        if (intersectPoint.x !== -1 && intersectPoint.y !== -1 && MathUtils.lineLength(point, intersectPoint) > 0 &&
                                leftPoint !== intersectPoint) {
                            intersectPoints.push({"p": intersectPoint, "length": MathUtils.lineLength(point, intersectPoint)})
                        }
                    }
                }
            } else {
                // Проверим пересечения с вертикальными линиями
                for (var j = 0; j < vLines.length; j++) {
                    if(leftPoint.x < point.x) {
                        intersectPoint = MathUtils.intersect(vLines[j].p1, vLines[j].p2, point, Qt.point(parking.width, point.y))
                        if (intersectPoint.x !== -1 && intersectPoint.y !== -1 && MathUtils.lineLength(point, intersectPoint) > 0 &&
                                leftPoint !== intersectPoint) {
                            intersectPoints.push({"p": intersectPoint, "length": MathUtils.lineLength(point, intersectPoint)})
                        }
                    } else {
                        intersectPoint = MathUtils.intersect(vLines[j].p1, vLines[j].p2, point, Qt.point(0, point.y))
                        if (intersectPoint.x !== -1 && intersectPoint.y !== -1 && MathUtils.lineLength(point, intersectPoint) > 0 &&
                                leftPoint !== intersectPoint) {
                            intersectPoints.push({"p": intersectPoint, "length": MathUtils.lineLength(point, intersectPoint)})
                        }
                    }
                }
            }

            // Рассмотрим соседнюю вершину справа
            var rightPoint = i === vertexCount - 1 ? vertexes[0] : vertexes[i+1]
            if(rightPoint.x === point.x) {
                // Проверим пересечения с горизонтальными линиями
                for (var j = 0; j < hLines.length; j++) {
                    if(leftPoint.y < point.y) {
                        intersectPoint = MathUtils.intersect(hLines[j].p1, hLines[j].p2, point, Qt.point(point.x, parking.height))
                        if (intersectPoint.x !== -1 && intersectPoint.y !== -1 && MathUtils.lineLength(point, intersectPoint) > 0 &&
                                rightPoint !== intersectPoint) {
                            intersectPoints.push({"p": intersectPoint, "length": MathUtils.lineLength(point, intersectPoint)})
                        }
                    } else {
                        intersectPoint = MathUtils.intersect(hLines[j].p1, hLines[j].p2, point, Qt.point(point.x, 0))
                        if (intersectPoint.x !== -1 && intersectPoint.y !== -1 && MathUtils.lineLength(point, intersectPoint) > 0 &&
                                rightPoint !== intersectPoint) {
                            intersectPoints.push({"p": intersectPoint, "length": MathUtils.lineLength(point, intersectPoint)})
                        }
                    }
                }
            } else {
                // Проверим пересечения с вертикальными линиями
                for (var j = 0; j < vLines.length; j++) {
                    if(rightPoint.x < point.x) {
                        intersectPoint = MathUtils.intersect(vLines[j].p1, vLines[j].p2, point, Qt.point(parking.width, point.y))
                        if (intersectPoint.x !== -1 && intersectPoint.y !== -1 && MathUtils.lineLength(point, intersectPoint) > 0 &&
                                rightPoint !== intersectPoint) {
                            intersectPoints.push({"p": intersectPoint, "length": MathUtils.lineLength(point, intersectPoint)})
                        }
                    } else {
                        intersectPoint = MathUtils.intersect(vLines[j].p1, vLines[j].p2, point, Qt.point(0, point.y))
                        if (intersectPoint.x !== -1 && intersectPoint.y !== -1 && MathUtils.lineLength(point, intersectPoint) > 0 &&
                                rightPoint !== intersectPoint) {
                            intersectPoints.push({"p": intersectPoint, "length": MathUtils.lineLength(point, intersectPoint)})
                        }
                    }
                }
            }

            //Пройдем по всем найденым вариантам и найдем кратчайший
            var newPoint;
            var currentLength = Math.max(parking.width, parking.height);
            for(var k = 0; k < intersectPoints.length; k++) {
                if (currentLength > intersectPoints[k].length) {
                    newPoint = intersectPoints[k].p;
                    currentLength = intersectPoints[k].length
                }
            }
            parking.intersectPoints.push({"point": newPoint, "length": currentLength, "index": i});

            // добавили новую линию в массив что бы избежать наложений
            line = {"p1":newPoint, "p2":point};
            if (newPoint.x === point.x)
                vLines.push(line)
            else
                hLines.push(line)
            __allPoints.push(newPoint)
        }

        fillParking(i, newPoint);

        __allPointsChanged();
        console.log("###",__allPoints );
    }

    focus: true

    Keys.onPressed: {
        if (event.key === Qt.Key_Z && (event.modifiers & Qt.ControlModifier))
            removeVertex(vertexCount - 1);
    }


    Connections {
        target: Singletons.common

        onStart: {
            splitParking();
        }
        onReset: {
            parking.__allPoints.length = 0;
            parking.__allPointsChanged();
            parking.intersectPoints.length = 0;
            parking.rects.length = 0;
            parking.isConcaveVertex.length = 0;
            parking.vertexes.length = 0;
            parking.vertexesChanged();
            parking.currentIndex = 0;
            canvas.requestPaint();
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        Connections {
            target: parking
            onVertexesChanged: canvas.requestPaint()
        }

        onPaint: {

            var ctx = canvas.getContext("2d");

            ctx.clearRect (0, 0, canvas.width, canvas.height);
            ctx.strokeStyle = Qt.rgba(1, 0, 0, 1);
            ctx.beginPath ();

            if(parking.vertexCount === 0) {
                ctx.closePath();
                return;
            }

            ctx.moveTo(parking.vertexes[0].x, parking.vertexes[0].y);
            for(var i = parking.vertexCount - 1; i >= 0; i--) {
                ctx.lineTo(parking.vertexes[i].x, parking.vertexes[i].y);
            }
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
            color: parking.isConcaveVertex[index] ? "red" : "green"
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

    Repeater{
        id: phantomVertecies
        anchors.fill: parent
        model: parking.__allPoints
        delegate: Rectangle{
            id: phVertex

            x: modelData.x - width/2
            y: modelData.y - height/2
            color: "blue"
            width: 3
            height: width
            radius: width/2
        }
    }

}
