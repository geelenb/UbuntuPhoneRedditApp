import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Ubuntu.Components 0.1
import "storage.js" as Storage

Switch {
	property string name: ""

	anchors.top: parent.top
	anchors.bottom: parent.bottom

	onCheckedChanged: Storage.setSetting(name, "" + checked)

	function loadValue () {
		checked = (Storage.getSetting(name) == "true") ? true : false
	}
}
