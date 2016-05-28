import QtQuick 2.0

Rectangle {
    id: root

    property  list<Place> placeArray
    property int roadCount: 2
    property real placeWidth: 60
    property real placeHeight: 40

    property int rows: Math.floor(longEdge / placeHeight)
    property int columns: Math.floor(shortEdge / (2*placeWidth + roadCount * placeHeight))

    property real longEdge: root.width >= root.height ? root.width : root.height;
    property real shortEdge: root.width < root.height ? root.width : root.height;

    property rect bigIsland: Qt.rect(0,0, longEdge, shortEdge % (2*placeWidth + roadCount * placeHeight))
    property rect smallIsland: Qt.rect(0,0, shortEdge, longEdge % placeHeight)

    property bool horizontal: width >= root.height
    property real w: horizontal ? root.placeHeight : root.placeWidth;
    property real h: !horizontal ? root.placeHeight : root.placeWidth;

    color: "transparent"
    border.color: "black"

    function start() {
        placeArray.length = 0;

        var component = Qt.createComponent("Place.qml");

        for( var i = 0; i < rows; i++) {
            for(var j = 0; j < columns; j++) {
//                console.log("### ", i, j)
                var roadWidth= horizontal ? w : roadCount * w;
                var roadHeight = horizontal ? roadCount * w : w;
                var coordX = horizontal ?  w * i  : (w* 2 + roadWidth)* j
                var coordY =  !horizontal ?  h* i  : (h *2 + roadHeight)* j

                var place1 = component.createObject(root, {"width": w, "height": h,
                                                                                "x": coordX, "y": coordY  });
                var place2 = component.createObject(root, {"width": w, "height": h,
                                                        "x": coordX + (!horizontal ? w+roadWidth : 0), "y": coordY + (horizontal ? h+roadHeight : 0) });

                var road = component.createObject(root, {"width": roadWidth ,  "height": roadHeight, "isRoad": true,
                                                      "x": coordX + (!horizontal ? w : 0), "y": coordY+ (horizontal ? h : 0) });

            }
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
        opacity: 0.5
    }
}
