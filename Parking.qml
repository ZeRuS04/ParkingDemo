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
    property var baseVertexes: []
    property var isConcaveVertex: {
        var arr = [];
        for(var i = 0; i < vertexes.length; i++) {
            if(i === 0)
                arr[vertexCount - 1] = angle(vertexCount - 1) > 180;
            else
                arr[i-1] = angle(i-1) > 180;
            arr[i] = angle(i) > 180;
            if(i === vertexCount-1)
                arr[0] = angle(0) > 180;
            else
                arr[i+1] = angle(i+1) > 180;
        }
        return arr;
    }

    property var __allPoints: []
    property var rects: []
    property var intersectPoints: []
    property var parkingRectList: []
    property var rectPairs: []

    property var exitRects: []
    property var placeArray: []
    property var pathArray: []

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
        var allPoints = __allPoints;
        var bonus = 0
        var component = Qt.createComponent("ParkingRect.qml");
        while (allPoints.length > 4) {
            var rectVertexes = findRectVertexes(allPoints[0+bonus], allPoints[1+bonus], allPoints);

            if (rectVertexes.length === 0) {
                bonus++;
                var p = allPoints[0];
                allPoints.splice(allPoints.indexOf(p), 1);
//                allPoints.push(p);
                continue;
            }
            allPoints = removeExtraVertex(rectVertexes, allPoints, allPoints[0+bonus]);
            var newRect = rectFromArray(rectVertexes);

            console.log("New rect finded: ",  newRect);
            if(parking.rects.indexOf(newRect) === -1) {
                parking.rects.push(newRect);
                var rectObject = component.createObject(parking, {"width": newRect.width, "height": newRect.height,
                                                                  "x":     newRect.x,     "y":      newRect.y });
                parkingRectList.push(rectObject);
            }
        }

        if (allPoints.length === 4) {
            newRect = rectFromArray(allPoints);
            console.log("New rect finded: ",  newRect);
            if(parking.rects.indexOf(newRect) === -1) {
                parking.rects.push(newRect);
                var rectObject = component.createObject(parking, {"width": newRect.width, "height": newRect.height,
                                                                  "x":     newRect.x,     "y":      newRect.y });
                parkingRectList.push(rectObject);
            }
        }
        console.log("Total %1 rect generated".arg(parkingRectList.length));
    }

    function removeExtraVertex (rectVertexes, array, p1) {
        for (var i = 0; i < rectVertexes.length; i++) {
            if ((vertexes.indexOf(rectVertexes[i])) !== -1 || rectVertexes[i] === p1) {
                array.splice(array.indexOf(rectVertexes[i]), 1);
            }
        }
        return array;
    }

    function findRectVertexes(point1, point2, array) {
        console.log("========Start findRectVertexes: ", point1, point2, array)
        var key, antikey, delta, findPoints = [];

        // Выберемо по какой кординате искать точки
        if (point1.x === point2.x) {
            key = "y";
            antikey = "x";
        } else if (point1.у === point2.у) {
            key = "x";
            antikey = "y";
        } else console.log("CRITICAL ERROR");

        delta = Math.abs(point1[key] - point2[key]);

        // пройдем все точки и найдем те что соответствуют кординате одной из точек
        for (var i = 2; i < array.length; i++) {
            if ((array[i][key] === point1[key]) || (array[i][key] === point2[key])) {
                for (var j = 0; j < findPoints.length; j++) {
                    if (Math.abs(findPoints[j][key] - array[i][key]) === delta &&
                        findPoints[j][antikey] === array[i][antikey]) {
                        return [point1, point2, array[i], findPoints[j]];
                    }
                }
                findPoints.push(array[i]);
            }
        }
        return [];
    }

    function rectFromArray(array) {
        var minX, minY, maxY, p4,width, height;

        var arrX = [array[0].x, array[1].x, array[2].x, array[3].x]
        var arrY = [array[0].y, array[1].y, array[2].y, array[3].y]

        arrX.sort(function(a,b) {
            return a - b;
        });

        arrY.sort(function(a,b) {
            return a - b;
        });

        return Qt.rect(arrX[0], arrY[0], arrX[3] - arrX[0], arrY[3] - arrY[0])
    }

    function splitParking() {
        var newVertexes = [];
        // Пройдем по всем внутренним вершинам:
        for(var i = 0; i < vertexCount; i++) {
            __allPoints.push(vertexes[i]);
            if (!isConcaveVertex[i])
                continue;

            // Для каждой внутренней вершины продолжим отрезки до ближайших пересечений
            var concavePoint = vertexes[i],
                prevPoint = i === 0 ? vertexes[vertexes.length - 1] : vertexes[i-1],
                nextPoint = i === (vertexes.length - 1) ? vertexes[0] : vertexes[i+1];

            // Найдем горизонтальные пересечения:
            var pairPoint = prevPoint.y === concavePoint.y ? prevPoint  // выбересм соседнюю точку по горизонтали
                                                           : nextPoint;
            var intersectHPoint = Qt.point(pairPoint.x > concavePoint.x ? 0 : parking.width, concavePoint.y), // получим тестовую точку для отрезка
                intersectHIndex = 0; // и её индекс в массиве

            // пройдем по всем ИЗВЕСТНЫМ отрезкам
            for (var p = 0; p < vertexes.length; p++) {
                var p1 = vertexes[p],
                    p2 = p === (vertexes.length - 1) ? vertexes[0] : vertexes[p+1];
                if (p1 === concavePoint || p2 === concavePoint || p1.y === p2.y) {
                    // Пропускаем горизонтальные отрезки и отрезки вершиной которых является текущая concavePoint
                    continue;
                }

                var foundPoint = MathUtils.intersect(p1, p2, concavePoint, intersectHPoint) // найдем пересечение
//                console.log("###H", p, foundPoint, p1, p2, intersectHPoint, MathUtils.lineLength(foundPoint, concavePoint),  MathUtils.lineLength(intersectVPoint, concavePoint))

                if (foundPoint.x >= 0 && foundPoint.y >= 0 &&
                        MathUtils.lineLength(foundPoint, concavePoint) < MathUtils.lineLength(intersectHPoint, concavePoint)) {
                    intersectHPoint = foundPoint; // если длинна отрезка минимальная - зафиксируем
                    intersectHIndex = p + 1;
                }
            }
            /// Так же пройдем по всем созданным отрезкам
            for(var n = 0; n < newVertexes.length; n++) {
                var p1 = newVertexes[n].point,
                    p2 = newVertexes[n].point2;
                var foundPoint = MathUtils.intersect(p1, p2, concavePoint, intersectHPoint) // найдем пересечение
                if (foundPoint.x >= 0 && foundPoint.y >= 0 &&
                        MathUtils.lineLength(foundPoint, concavePoint) < MathUtils.lineLength(intersectHPoint, concavePoint)) {
                    intersectHPoint = foundPoint; // если длинна отрезка минимальная - зафиксируем
                    intersectHIndex = vertexes.length - 1;
                }
            }

            // Найдем вертикальные пересечения:
            pairPoint = prevPoint.x === concavePoint.x ? prevPoint  // выбересм соседнюю точку по вертикали
                                                       : nextPoint;
            var intersectVPoint = Qt.point(concavePoint.x, pairPoint.y > concavePoint.y ? 0 : parking.height), // получим тестовую точку для отрезка
                intersectVIndex = 0; // и её индекс в массиве

            // пройдем по всем ИЗВЕСТНЫМ отрезкам
            for (var p = 0; p < vertexes.length; p++) {
                var p1 = vertexes[p],
                    p2 = p === (vertexes.length - 1) ? vertexes[0] : vertexes[p+1];
                if (p1 === concavePoint || p2 === concavePoint || p1.x === p2.x) {
                    // Пропускаем горизонтальные отрезки и отрезки вершиной которых является текущая concavePoint
                    continue;
                }

                var foundPoint = MathUtils.intersect(p1, p2, concavePoint, intersectVPoint) // найдем пересечение
//                console.log("###V", p, foundPoint, p1, p2, intersectVPoint, MathUtils.lineLength(foundPoint, concavePoint),  MathUtils.lineLength(intersectVPoint, concavePoint))
                if (foundPoint.x >= 0 && foundPoint.y >= 0 &&
                        MathUtils.lineLength(foundPoint, concavePoint) < MathUtils.lineLength(intersectVPoint, concavePoint)) {
                    intersectVPoint = foundPoint; // если длинна отрезка минимальная - зафиксируем
                    intersectVIndex = p + 1;
                }
            }
            /// Так же пройдем по всем созданным отрезкам
            for(var n = 0; n < newVertexes.length; n++) {
                var p1 = newVertexes[n].point,
                    p2 = newVertexes[n].point2;
                var foundPoint = MathUtils.intersect(p1, p2, concavePoint, intersectVPoint) // найдем пересечение
                if (foundPoint.x >= 0 && foundPoint.y >= 0 &&
                        MathUtils.lineLength(foundPoint, concavePoint) < MathUtils.lineLength(intersectVPoint, concavePoint)) {
                    intersectVPoint = foundPoint; // если длинна отрезка минимальная - зафиксируем
                    intersectVIndex = vertexes.length - 1;
                }
            }

            if (MathUtils.lineLength(intersectHPoint, concavePoint) < MathUtils.lineLength(intersectVPoint, concavePoint)) {
                if (vertexes.indexOf(intersectHPoint) === -1)
                    newVertexes.push({"point": intersectHPoint, "point2": concavePoint, "index": intersectHIndex});
            } else {
                if (vertexes.indexOf(intersectVPoint) === -1)
                    newVertexes.push({"point": intersectVPoint, "point2": concavePoint, "index": intersectVIndex});
            }
        }

        // ЦИКЛ вставки новых точек в массив всех точек
        var displacement = 0, disPoint = vertexCount;
        for(var i = 0; i < newVertexes.length; i++) {
            var index = newVertexes[i].index,
                point = newVertexes[i].point,
                bonus = 0;

            if (__allPoints.indexOf(point) !== -1)
                continue;

            for(var j = 0; j < i; j++) {
                if (newVertexes[j].index < index)
                    bonus++;
            }

            __allPoints.splice(index + bonus, 0, point);
        }

        vertexesChanged()
        __allPointsChanged();
    }

    function connectParkingRects() {
        rectPairs.forEach(function (pairs, index) {
            var firstRect = parkingRectList[index]
            for (var i = 0; i < pairs.length; i++) {
                var secondRect = pairs[i],
                    firstBoundPlaces = firstRect.links[i].boundaryPlaces,
                    line = firstRect.links[i].line;
                var secondBoundPlaces = [];
                for (var j = 0; j < secondRect.links.length; j++) {
                    if ((secondRect.links[j].line[0] === line[0] && secondRect.links[j].line[1] === line[1]) ||
                        (secondRect.links[j].line[0] === line[1] && secondRect.links[j].line[1] === line[0])) {
                        secondBoundPlaces  = secondRect.links[j].boundaryPlaces;
                        break;
                    }
                }

                var masterBoundPlaces, slaveBoundPlaces;
                if (secondBoundPlaces.length >= firstBoundPlaces.length) {
                    masterBoundPlaces = firstBoundPlaces;
                    slaveBoundPlaces = secondBoundPlaces;
                } else {
                    masterBoundPlaces = secondBoundPlaces;
                    slaveBoundPlaces = firstBoundPlaces;
                }
                masterBoundPlaces.forEach(function(place) {
                    var myPair,
                        minLength = 0xffffffff
                    for (var j = 0; j < slaveBoundPlaces.length; j++) {
                        var length = MathUtils.lineLength(Qt.point(place.x + place.width/2, place.y + place.height/2),
                                                          Qt.point(slaveBoundPlaces[j].x + slaveBoundPlaces[j].width/2, slaveBoundPlaces[j].y + slaveBoundPlaces[j].height/2));

                        if(length < minLength) {
                            minLength = length;
                            myPair = slaveBoundPlaces[j];
                        }
                    }

                    place.addNeighbors(myPair.index);
                    myPair.addNeighbors(place.index);
                    if (place.isRoad) {
                        if (!myPair.isRoad) {
                            myPair.isRoad = true;
                        }
                        place.addNeighborRoad(myPair.index);
                        myPair.addNeighborRoad(place.index);
                        place.addNeighborPlaces(myPair.index);
                        myPair.addNeighborPlaces(place.index);

                        myPair.neighbors.forEach(function (e) {
                            if (parking.placeArray[e].isRoad && myPair.neighborRoad.indexOf(e) === -1) {
                                myPair.addNeighborRoad(e);
                            }
                        });
                    }
                });
            }
        });
    }

    function pairRectFind() {
        for (var t = 0; t < parking.parkingRectList.length; t++) {
            var firstRect = parking.parkingRectList[t];
            var pairs = [];
            for (var i = 0; i < parking.parkingRectList.length; i++) {
                var secondRect = parking.parkingRectList[i];
                if (firstRect === secondRect)
                    continue;
                var firstPoints = [Qt.point(firstRect.x, firstRect.y), Qt.point(firstRect.x + firstRect.width, firstRect.y),
                                   Qt.point(firstRect.x + firstRect.width, firstRect.y + firstRect.height), Qt.point(firstRect.x, firstRect.y + firstRect.height)];
                var secondPoints = [Qt.point(secondRect.x, secondRect.y), Qt.point(secondRect.x + secondRect.width, secondRect.y),
                              Qt.point(secondRect.x + secondRect.width, secondRect.y + secondRect.height), Qt.point(secondRect.x, secondRect.y + secondRect.height)];

                var intersectLine = []

                for (var j = 0; j < 4; j++) {
                    var secondLine = [secondPoints[j], j === 3 ? secondPoints[0] : secondPoints[j+1]];
                    for (var k = 0; k < 4; k++) {
                        var firstLine = [firstPoints[k], k === 3 ? firstPoints[0] : firstPoints[k+1]];

                        var intersectPoint = MathUtils.intersect(secondLine[0], secondLine[1], firstLine[0], firstLine[1]);

                        if (intersectPoint.x === -1 && intersectPoint.y === -1)
                            continue;

                        if (intersectLine.indexOf(intersectPoint) === -1)
                            intersectLine.push(intersectPoint);
                        if (intersectLine.length === 2)
                            break;
                    }
                    if (intersectLine.length === 2)
                        break;
                }
                if (intersectLine.length < 2)
                    continue;
                console.log("### Intersect Rect Line", intersectLine[0], intersectLine[1]);
                pairs.push(secondRect)
                firstRect.links.push({"line": intersectLine, "boundaryPlaces": []});
            }
            rectPairs[t] = pairs;
        }
    }

    function depthFirstSearch(place, path, oldPlace, entry) {
        for (var n = 0; n < place.neighborPlaces.length; n++) {
            if (parking.placeArray[place.neighborPlaces[n]].isRoad) {
                if (parking.placeArray[place.neighborPlaces[n]] === oldPlace || path.indexOf(place.neighborPlaces[n]) !== -1)
                    continue;
                depthFirstSearch(parking.placeArray[place.neighborPlaces[n]], path.concat(place.index), place, entry);
            }
            else {
                parking.pathArray[entry].path[place.neighborPlaces[n]] = path.concat(place.index);
            }
        }
    }

    function generateMaps() {
        exitRects.forEach(function (entry) {
            var startPlace = placeArray[entry];
            parking.pathArray[entry] = {"path": []};
            depthFirstSearch(startPlace, [], undefined, entry);
        });

        parking.pathArray.forEach(function(entry) {
            console.log("####", entry)
            parking.pathArray[entry].path.forEach(function(e, index) {
                console.log("####", index, e)
            })
        })

    }
    // использование Math.round() даст неравномерное распределение!
    function getRandomInt(min, max)
    {
      return Math.floor(Math.random() * (max - min + 1)) + min;
    }
    focus: true

    Keys.onPressed: {
        if (event.key === Qt.Key_Z && (event.modifiers & Qt.ControlModifier))
            removeVertex(vertexCount - 1);
    }

    Component {
        id: autoComponent

        Item {
            id: root
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
//                running: root.path && root.path.length > 0 && !root.nextPlace
                onRunningChanged: {
                    if (!running && !root.toExit) {
                        waitTimer.start();
                    }
                }

                onTriggered: {
                    if (root.currentPlace.index === root.exitIndex && root.toExit) {
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

    }

    Connections {
        target: Singletons.common

        onStart: {
            parkingRectList.length = 0;
            splitParking();
            fillParking();
            pairRectFind();
            for(var i = 0; i < parkingRectList.length; i++) {
                parkingRectList[i].start();
            }
            connectParkingRects();
        }
        onGenMaps: generateMaps();

        onSendAuto: {
//            if (autoComponent.status === Component.Ready) {
                var currentPlace = placeArray[exitRects[getRandomInt(0, parking.exitRects.length - 1)]],
                       exitIndex = exitRects[getRandomInt(0, parking.exitRects.length - 1)],
                        waitTime = getRandomInt(1000, 10000);

                console.log("onSendAuto", currentPlace.index, exitIndex, waitTime)
            parking.pathArray.forEach(function(e, index) {
                console.log("####", index, e)
            })
//                var auto = autoComponent.createObject(parking, { "currentPlace": currentPlace,
//                                                                    "exitIndex": exitIndex,
//                                                                         "path": parking.pathArray[exitIndex][currentPlace.index],
//                                                                     "waitTime": waitTime
//                                                                });
//            }
        }

        onReset: {
            parking.placeArray.length = 0;
            parking.__allPoints.length = 0;
            parking.__allPointsChanged();
            parking.intersectPoints.length = 0;
            parking.rects.length = 0;
            parking.isConcaveVertex.length = 0;
            parking.vertexes.length = 0;
            parking.vertexesChanged();
            parking.currentIndex = 0;
            parking.parkingRectList.length = 0;
            canvas.requestPaint();
        }
        onClear: {
            parking.placeArray.length = 0;
            parking.__allPoints.length = 0;
            parking.__allPointsChanged();
            parking.intersectPoints.length = 0;
            parking.rects.length = 0;
            parking.isConcaveVertex.length = 0;
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

        visible: Singletons.common.visibleState === 0 || Singletons.common.visibleState === 1
        onPaint: {
            var ctx = canvas.getContext("2d");

            ctx.clearRect (0, 0, canvas.width, canvas.height);
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 1);
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

            ctx.closePath();
        }
    }

    Repeater{
        id: parkingVertecies
        anchors.fill: parent
        model: parking.vertexes

        visible: Singletons.common.visibleState === 0 || Singletons.common.visibleState === 1

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

            Text {
                anchors.centerIn: parent
                color: "darkred"
                text: "%1 : %2".arg(vertex.x + vertex.width/2).arg(vertex.y + vertex.height/2)
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
            Text {
                anchors.centerIn: parent
                color: "darkred"
                text: "%1 : %2".arg(phVertex.x + phVertex.width/2).arg(phVertex.y + phVertex.height/2)
            }
        }
    }
}
