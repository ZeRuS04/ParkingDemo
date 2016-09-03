import QtQuick 2.0

import "./singletons" as Singletons

Rectangle {
    id: root

    property var links: []

    property int roadCount: Singletons.common.roadCount
    property real placeWidth: Singletons.common.placeWidth
    property real placeHeight: Singletons.common.placeHeight
    property var streetBegins: []

    property int firstPlaceIndex
    property int countOfPlaces

    property int rows: Math.floor(longEdge / Math.min(root.placeHeight, root.placeWidth))
    property int columns: Math.floor(shortEdge / (2*Math.max(root.placeHeight, root.placeWidth) +
                                                  roadCount * Math.min(root.placeHeight, root.placeWidth)))

    property real longEdge: root.width >= root.height ? root.width : root.height;
    property real shortEdge: root.width < root.height ? root.width : root.height;
    property real mainEdge: (2*Math.max(root.placeHeight, root.placeWidth) + roadCount * Math.min(root.placeHeight, root.placeWidth)) * columns

    property rect bigIsland: Qt.rect(0,0, longEdge, shortEdge % (2*Math.max(root.placeHeight, root.placeWidth) + roadCount * Math.min(root.placeHeight, root.placeWidth)))
    property rect smallIsland: Qt.rect(0,0, shortEdge, longEdge % placeHeight)

    property bool horizontal: width >= root.height
    property real w: horizontal ? Math.min(root.placeHeight, root.placeWidth) : Math.max(root.placeHeight, root.placeWidth)
    property real h: !horizontal ? Math.min(root.placeHeight, root.placeWidth) : Math.max(root.placeHeight, root.placeWidth)

    property real shortOffset: bigIsland.height < w ? bigIsland.height / 2 : 0
    property real longOffset: smallIsland.height / 2
    color: "#44999999"
    border.color: "black"
    clip: false
    
    function start() {
        firstPlaceIndex = parking.placeArray.length;
        fillMainIsland();
        fillBigIsland();
        mergeStreets();
        countOfPlaces = parking.placeArray.length - firstPlaceIndex;

        neighbors.requestPaint()
        neighborRoad.requestPaint()
        neighborPlaces.requestPaint()
    }

    function findRoad(place, path, maxDeep) {
        for (var neighbor = 0; neighbor < place.neighbors.length; neighbor++) {
            if (path.length === 0 && parking.placeArray[place.neighbors[neighbor]].isRoad
                    || (path.indexOf(parking.placeArray[place.neighbors[neighbor]]) !== -1))
                continue;
            path.push(place);
            if (parking.placeArray[place.neighbors[neighbor]].isRoad && parking.placeArray[place.neighbors[neighbor]].neighbors.indexOf(path[0].index) === -1) {
                path.push(parking.placeArray[place.neighbors[neighbor]]);
                return path;
            }
            if (path.length === maxDeep) {
                path.pop();
                return path;
            }
            var pathSize = path.length;
            var arr = findRoad(parking.placeArray[place.neighbors[neighbor]], path, maxDeep);

            if (arr.length === pathSize) {
                path.pop();
                continue;
            }

            return arr;
        }

        return path;
    }

    function mergeStreets() {
        console.log("mergeStreets started")
        if (roadCount === 2) {
            for (var street = 0; street < streetBegins.length - 1; street++) {
                var place = streetBegins[street],
                        oldPlace = null;
                for (var i = 0; i < Math.floor(rows / 2); i++) {
                    for (var neighbor = 0; neighbor < place.neighborRoad.length; neighbor++) {
                        if (parking.placeArray[place.neighborRoad[neighbor]] !== oldPlace) {
                            oldPlace = place;
                            place = parking.placeArray[place.neighborRoad[neighbor]];
                            break;
                        }
                    }
                }

                var foundedRoads = findRoad(place, [], 3);
                var last = null;
                var indexDelta = 0;
                var param;
                foundedRoads.forEach(function(entry) {
                    if (last === null || entry.isRoad) {
                        if (last !== null) {
                            if (last && entry.neighborRoad.indexOf(last.index) === -1)
                                entry.neighborRoad.push(last.index);
                            if (last.neighborRoad.indexOf(entry.index) === -1)
                                last.neighborRoad.push(entry.index);
                            if (last && entry.neighborPlaces.indexOf(last.index) === -1)
                                entry.neighborPlaces.push(last.index);
                            if (last.neighborPlaces.indexOf(entry.index) === -1)
                                last.neighborPlaces.push(entry.index);
                        }

                        last = entry;
                        entry.isRoad = true;
                        return;
                    }

                    if (param === undefined) {
                        param = (entry.x === last.x) ? "y"
                                                     : "x";
                    }
                    for (var neighbor = 0; neighbor < entry.neighbors.length; neighbor++) {
                        if (parking.placeArray[entry.neighbors[neighbor]].isRoad ||
                                foundedRoads.indexOf(parking.placeArray[entry.neighbors[neighbor]]) !== -1)
                            continue;
                        if (indexDelta === 0) {
                            indexDelta = parking.placeArray[entry.neighbors[neighbor]][param] - entry[param];
                            mergePlaces(entry, parking.placeArray[entry.neighbors[neighbor]]);
                            break;
                        } else {
                            if ((parking.placeArray[entry.neighbors[neighbor]][param] - entry[param]) * indexDelta > 0) {
                                mergePlaces(entry, parking.placeArray[entry.neighbors[neighbor]]);
                                break;
                            }
                        }
                    }

                    if (last && entry.neighborRoad.indexOf(last.index) === -1)
                        entry.neighborRoad.push(last.index);
                    if (last.neighborRoad.indexOf(entry.index) === -1)
                        last.neighborRoad.push(entry.index);
                    if (last && entry.neighborPlaces.indexOf(last.index) === -1)
                        entry.neighborPlaces.push(last.index);
                    if (last.neighborPlaces.indexOf(entry.index) === -1)
                        last.neighborPlaces.push(entry.index);
                    last = entry;
                    entry.isRoad = true;
                })
            }
        }
        if (roadCount === 1) {
            for (var street = 0; street < streetBegins.length - 1; street++) {
                var place = streetBegins[street],
                        oldPlace = null;
                for (var i = 0; i < rows; i++) {
                    if (i === 0 || i === rows - 1) {
                        var foundedRoads = findRoad(place, [], 3);
                        var last = null;
                        var indexDelta = 0;
                        var param;
                        foundedRoads.forEach(function(entry) {
                            if (last !== null) {
                                if (last && entry.neighborRoad.indexOf(last.index) === -1)
                                    entry.neighborRoad.push(last.index);
                                if (last.neighborRoad.indexOf(entry.index) === -1)
                                    last.neighborRoad.push(entry.index);
                                if (last && entry.neighborPlaces.indexOf(last.index) === -1)
                                    entry.neighborPlaces.push(last.index);
                                if (last.neighborPlaces.indexOf(entry.index) === -1)
                                    last.neighborPlaces.push(entry.index);
                            }

                            last = entry;
                            entry.isRoad = true;
                        });
                    }

                    for (var neighbor = 0; neighbor < place.neighborRoad.length; neighbor++) {
                        if (parking.placeArray[place.neighborRoad[neighbor]] !== oldPlace) {
                            oldPlace = place;
                            place = parking.placeArray[place.neighborRoad[neighbor]];
                            break;
                        }
                    }
                }
            }
        }
        console.log("mergeStreets ended")
    }

    function mergePlaces(place1, place2) {
        var placeIndex1 = place1.index,
            placeIndex2 = place2.index;
        console.log("###", placeIndex1, place1, "\t", placeIndex2, place2)
        if (!place1 || !place2) {
            console.log("mergePlaces: ERROR.  Some place is null or undefined.");
            return;
        }

        place1.neighbors.concat(place2.neighbors)
        place1.neighbors.splice(place1.neighbors.indexOf(placeIndex1), 1);
        place1.neighbors.splice(place1.neighbors.indexOf(placeIndex2), 1);

        place2.neighbors.forEach(function (entry){
            var place = parking.placeArray[entry];
            place.neighbors.splice(place.neighbors.indexOf(placeIndex2), 1, placeIndex1);
        });
        place2.neighborPlaces.forEach(function (entry){
            var place = parking.placeArray[entry];
            place.neighborPlaces.splice(place.neighborPlaces.indexOf(placeIndex2), 1, placeIndex1);
        });
        if (place1.x === place2.x) {
            place1.height += place2.height;
        } else if (place1.y === place2.y) {
            place1.width += place2.width;
        } else console.log("CRITICAL ERROR");

        place1.x = Math.min(place1.x, place2.x)
        place1.y = Math.min(place1.y, place2.y)

        parking.placeArray[placeIndex2] = undefined;
        parking.placeArrayChanged();
    }

    function fillMainIsland() {
        var component = Qt.createComponent("Place.qml");

        var count = parking.placeArray.length;
        for( var i = 0; i < rows; i++) {
            for(var j = 0; j < columns; j++) {
                var roadWidth= horizontal ? w : roadCount * h;
                var roadHeight = horizontal ? roadCount * w : h;
                var coordX = (horizontal ?  w * i + longOffset : (w* 2 + roadWidth)* j + shortOffset) + root.x
                var coordY =  (!horizontal ?  h* i + longOffset : (h *2 + roadHeight)* j + shortOffset) + root.y

                var place1 = component.createObject(root.parent, {"width": w, "height": h, "index":count,
                                                            "x": coordX, "y": coordY  });
                var place2 = component.createObject(root.parent, {"width": w, "height": h,"index":count+2,
                                                        "x": coordX + (!horizontal ? w+roadWidth : 0), "y": coordY + (horizontal ? h+roadHeight : 0) });

                var road = component.createObject(root.parent, {"width": roadWidth ,  "height": roadHeight, "isRoad": true, "index":count+1,
                                                      "x": coordX + (!horizontal ? w : 0), "y": coordY+ (horizontal ? h : 0) });

                place1.addNeighborPlaces(road.index); place1.addNeighbors(road.index);
                if (j !== 0)
                     place1.addNeighbors(place1.index - 1);
                if (i !== 0)
                    place1.addNeighbors(place1.index - columns * 3);
                if (i !== rows - 1)
                    place1.addNeighbors(place1.index + columns * 3);
                place2.addNeighborPlaces(road.index); place2.addNeighbors(road.index);
                if (j !== columns-1)
                     place2.addNeighbors(place2.index + 1);
                if (i !== 0)
                    place2.addNeighbors(place2.index - columns * 3);
                if (i !== rows - 1)
                    place2.addNeighbors(place2.index + columns * 3);

                road.addNeighbors(place1.index); road.addNeighbors(place2.index)
                road.addNeighborPlaces(place1.index); road.addNeighborPlaces(place2.index)

                if (i !== 0) {
                    road.addNeighbors(road.index - columns * 3);
                    road.addNeighborRoad(road.index - columns * 3);
                    road.addNeighborPlaces(road.index - columns * 3);
                } else {
                    streetBegins.push(road);
                }

                if (i !== rows - 1) {
                    road.addNeighbors(road.index + columns * 3);
                    road.addNeighborRoad(road.index + columns * 3);
                    road.addNeighborPlaces(road.index - columns * 3);
                }

                parking.placeArray.push(place1, road, place2);
                parking.placeArrayChanged();
                count += 3;
            }
        }
    }

    function fillBigIsland() {
        var ih = bigIsland.height;

        var roadWidth = horizontal ? w : roadCount * h;
        var roadHeight = horizontal ? roadCount * w : h;

        var onlyRoad = roadCount * w; // Only Road
        var pPlaceRoad = roadCount * w + w; //parallel Place and Road
        var placeRoad = roadCount * w + h; // Place and Road
        var pPlaceRoadPlace = roadCount * w + w + h; //parallel Place and Road
        console.log("fillBigIsland: ", bigIsland.height, bigIsland.width, onlyRoad, pPlaceRoad, placeRoad, pPlaceRoadPlace)

        var component = Qt.createComponent("Place.qml");

        if (ih >= onlyRoad && ih < pPlaceRoad) {
            /* |road| */
            for( var i = 0; i < rows; i++) {
                var coordX = horizontal ? w * i + longOffset : mainEdge + shortOffset
                var coordY = !horizontal ? h* i + longOffset : mainEdge + shortOffset

                var road = component.createObject(root, {"width": roadWidth ,  "height": roadHeight, "isRoad": true,
                                                      "x": coordX, "y": coordY });
            }
        }
        if (ih >= pPlaceRoad && ih < placeRoad) {
            /* |p|road| */
            /* |l|road| */
            /* |a|road| */
            /* |c|road| */
            /* |e|road| */
            for( var i = 0; i < rows; i++) {
                var coordX = horizontal ? w * i + longOffset : mainEdge + shortOffset
                var coordY = !horizontal ? h* i + longOffset : mainEdge + shortOffset
                var road = component.createObject(root, {"width": roadWidth ,  "height": roadHeight, "isRoad": true,
                                                      "x": coordX, "y": coordY });
            }

            for( var i = 0; i < Math.floor(longEdge / Math.max(root.placeHeight, root.placeWidth)); i++) {
                var coordX = horizontal ? h * i + longOffset : mainEdge
                var coordY = !horizontal ? w * i + longOffset : mainEdge
                var place1 = component.createObject(root, {"width": h, "height": w,
                                                        "x": coordX + (!horizontal ? roadWidth : 0), "y": coordY  + (horizontal ? roadHeight : 0)});
            }

        }
        if (ih > placeRoad && ih < pPlaceRoadPlace) {
            /* |place|road| */
            for( var i = 0; i < rows; i++) {
                var coordX = horizontal ? w * i + longOffset : mainEdge + shortOffset
                var coordY = !horizontal ? h* i + longOffset : mainEdge + shortOffset

                var place1 = component.createObject(root, {"width": w, "height": h,
                                                        "x": coordX + (!horizontal ? roadWidth : 0), "y": coordY  + (horizontal ? roadHeight : 0)});
                var road = component.createObject(root, {"width": roadWidth ,  "height": roadHeight, "isRoad": true,
                                                      "x": coordX, "y": coordY });
            }

        }
        if (ih > pPlaceRoadPlace) {
            /* |p|road|place| */
            /* |l|road|place| */
            /* |a|road|place| */
            /* |c|road|place| */
            /* |e|road|place| */
            for( var i = 0; i < rows; i++) {
                var coordX = horizontal ? w * i + longOffset : mainEdge + shortOffset
                var coordY = !horizontal ? h* i + longOffset : mainEdge + shortOffset

                var place1 = component.createObject(root, {"width": w, "height": h,
                                                        "x": coordX, "y": coordY});
                var road = component.createObject(root, {"width": roadWidth ,  "height": roadHeight, "isRoad": true,
                                                      "x": coordX + (!horizontal ? w : 0), "y": coordY + (horizontal ? h : 0)});
            }

            for( var i = 0; i < Math.floor(longEdge / Math.max(root.placeHeight, root.placeWidth)); i++) {
                var coordX = horizontal ? h * i + longOffset : mainEdge
                var coordY = !horizontal ? w * i + longOffset : mainEdge
                var place1 = component.createObject(root, {"width": h, "height": w,
                                                        "x": coordX + (!horizontal ? roadWidth + w : 0), "y": coordY  + (horizontal ? roadHeight + h : 0)});
            }
        }
    }

    Connections {
        target: Singletons.common
        onReset: root.destroy();
        onStart: root.destroy();
        onClear: root.destroy();
    }

    Canvas {
        id: neighbors
        anchors.fill: parent

        Connections {
            target: parking
            onPlaceArrayChanged: neighbors.requestPaint()
        }
        Connections {
            target: Singletons.common
            onReset: neighbors.requestPaint()
            onStart: neighbors.requestPaint()
            onClear: neighbors.requestPaint()
        }
        visible: Singletons.common.visibleGraph === 0
        onPaint: {
            var ctx = neighbors.getContext("2d");

            ctx.clearRect (0, 0, neighbors.width, neighbors.height);
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 1);
            ctx.lineWidth = 3;
            ctx.beginPath ();

            for(var i = root.firstPlaceIndex; i < root.firstPlaceIndex + root.countOfPlaces; i++) {
                if (!parking.placeArray[i]) continue;
                for(var j = 0; j < parking.placeArray[i].neighbors.length; j++) {
                    ctx.moveTo(parking.placeArray[i].x +  parking.placeArray[i].width / 2 - root.x, parking.placeArray[i].y +  parking.placeArray[i].height / 2 - root.y);
                    var p = parking.placeArray[parking.placeArray[i].neighbors[j]]
                    ctx.lineTo(p.x +  p.width / 2 - root.x, p.y +  p.height / 2 - root.y);
                }
            }
            ctx.stroke();
            ctx.closePath();
        }
    }

    Canvas {
        id: neighborRoad
        anchors.fill: parent

        Connections {
            target: parking
            onPlaceArrayChanged: neighborRoad.requestPaint()
        }
        Connections {
            target: Singletons.common
            onReset: neighborRoad.requestPaint()
            onStart: neighborRoad.requestPaint()
            onClear: neighborRoad.requestPaint()
        }
        visible: Singletons.common.visibleGraph === 1
        onPaint: {
            var ctx = neighborRoad.getContext("2d");

            ctx.clearRect (0, 0, neighborRoad.width, neighborRoad.height);
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 1);
            ctx.lineWidth = 3;
            ctx.beginPath ();

            for(var i = root.firstPlaceIndex; i < root.firstPlaceIndex + root.countOfPlaces; i++) {
                if (!parking.placeArray[i]) continue;
                for(var j = 0; j < parking.placeArray[i].neighborRoad.length; j++) {
                    ctx.moveTo(parking.placeArray[i].x +  parking.placeArray[i].width / 2 - root.x, parking.placeArray[i].y +  parking.placeArray[i].height / 2 - root.y);
                    var p = parking.placeArray[parking.placeArray[i].neighborRoad[j]]
                    ctx.lineTo(p.x +  p.width / 2 - root.x, p.y +  p.height / 2 - root.y);
                }
            }
            ctx.stroke();
            ctx.closePath();
        }
    }

    Canvas {
        id: neighborPlaces
        anchors.fill: parent

        Connections {
            target: parking
            onPlaceArrayChanged: neighborPlaces.requestPaint()
        }
        Connections {
            target: Singletons.common
            onReset: neighborPlaces.requestPaint()
            onStart: neighborPlaces.requestPaint()
            onClear: neighborPlaces.requestPaint()
        }
        visible: Singletons.common.visibleGraph === 2
        onPaint: {
            var ctx = neighborPlaces.getContext("2d");

            ctx.clearRect (0, 0, neighborPlaces.width, neighborPlaces.height);
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 1);
            ctx.beginPath ();

            ctx.lineWidth = 3;

            for(var i = root.firstPlaceIndex; i < root.firstPlaceIndex + root.countOfPlaces; i++) {
                if (!parking.placeArray[i]) continue;
                for(var j = 0; j < parking.placeArray[i].neighborPlaces.length; j++) {
                    var p = parking.placeArray[parking.placeArray[i].neighborPlaces[j]]
                    if (!p) continue;

                    ctx.moveTo(parking.placeArray[i].x +  parking.placeArray[i].width / 2 - root.x, parking.placeArray[i].y +  parking.placeArray[i].height / 2 - root.y);
                    ctx.lineTo(p.x +  p.width / 2 - root.x, p.y +  p.height / 2 - root.y);
                }
            }
            ctx.stroke();
            ctx.closePath();
        }
    }


    Rectangle {
        id: big
        x: root.width - width
        y: root.height - height
        width: root.width >= root.height ? root.bigIsland.width : root.bigIsland.height
        height: root.width < root.height ? root.bigIsland.width : root.bigIsland.height
        color: "lightgreen"
        border.color: "black"

        visible: Singletons.common.visibleState === 0 || Singletons.common.visibleState === 3
        opacity: 0.5
    }

    Rectangle {
        id: small
        x: root.width - width
        y: root.height - height
        width: root.width < root.height ? root.smallIsland.width : root.smallIsland.height
        height: root.width >= root.height ? root.smallIsland.width : root.smallIsland.height
        color: "lightblue"
        border.color: "black"

        visible: Singletons.common.visibleState === 0 || Singletons.common.visibleState === 3
        opacity: 0.5
    }
}
