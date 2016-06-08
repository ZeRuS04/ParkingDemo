import QtQuick 2.0

import "./singletons" as Singletons

Rectangle {
    id: root

    property var links: []

    property int roadCount: Singletons.common.roadCount
    property real placeWidth: Singletons.common.placeWidth
    property real placeHeight: Singletons.common.placeHeight

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
        fillMainIsland();
        fillBigIsland();
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
