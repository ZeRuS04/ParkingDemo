import QtQuick 2.0

Rectangle {
    id: root

    property bool isRoad: false

    width: 50
    height: 60

    color: isRoad ? "blue" : "red"
    opacity: 0.7
    border.color: "black"
}
