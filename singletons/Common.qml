pragma Singleton

import QtQuick 2.0

QtObject {
    id: root

    property int state: 0

    property int roadCount: 2

    property real placeWidth: 10
    property real placeHeight: 10

    signal reset()

    onReset: {
        state = 0;
    }

}
