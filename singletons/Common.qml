pragma Singleton

import QtQuick 2.0
import Qt.labs.settings 1.0

QtObject {
    id: root

    property int state: 0

    property int roadCount: 2

    property real placeWidth: 41
    property real placeHeight: 23

    property int visibleGraph: 4
    property int visibleState: 0
    signal start()
    signal reset()
    signal clear()
    signal genMaps()
    signal sendAuto()

    property var vetexes: []
    property var keys: []

    signal clearAll()
    signal remove(string key)
    signal save(string key, var value)

    onClearAll:{
        vetexes.length = 0;
        keys.length = 0;
        vetexesChanged();
        keysChanged();
    }

    onSave: {
        console.log("Save %1 : %2".arg(key).arg(value), "\n",vetexes, keys);
        var val = [];
        value.forEach(function (v) {
            val.push([v.x, v.y])
        });
        vetexes.push(JSON.stringify(val));
        keys.push(key);
        vetexesChanged();
        keysChanged();
    }

    onRemove: {
        console.log("Remove %1 : %2".arg(key).arg(vetexes[keys.indexOf(key)]), "\n",vetexes, keys);
        vetexes.splice(keys.indexOf(key), 1);
        keys.splice(keys.indexOf(key), 1);
        vetexesChanged();
        keysChanged();
    }

    function load(key) {
        console.log("Load %1 : %2".arg(key).arg(vetexes[keys.indexOf(key)]), "\n",vetexes, keys);
        var value = [];
        JSON.parse(vetexes[keys.indexOf(key)]).forEach(function (array) {
            value.push(Qt.point(array[0], array[1]));
        });
        return value;
    }

    property Settings settings: Settings {
        property alias vetexes: root.vetexes
        property alias keys: root.keys
    }
}
