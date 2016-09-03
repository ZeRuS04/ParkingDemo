pragma Singleton

import QtQuick 2.0

QtObject {
    id: root

    property int state: 0

    property int roadCount: 2

    property real placeWidth: 25
    property real placeHeight: 15

    property int visibleGraph: 4
    property int visibleState: 0
    signal start()
    signal reset()
    signal clear()
}
