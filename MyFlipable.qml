import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import "storage.js" as Storage

Flipable {
	property bool flipped: false
	property bool flipsvertically: false // true means the bottom goes up
	property int flipspeed: Number(Storage.getSetting("flipspeed"))

	transform: Rotation {
		id: rotation
		origin.x: flipable.width / 2
		origin.y: flipable.height / 2
		axis.x: (flipsvertically)? 1 : 0; axis.y: (flipsvertically)? 0 : 1; axis.z: 0     // add option: which axis
		angle: 0    // the default angle
	}

	states: State {
		name: "back"
		PropertyChanges { target: rotation; angle: 180 }
		when: flipable.flipped
	}

	transitions: Transition {
		NumberAnimation { target: rotation; property: "angle"; duration: flipspeed } // add option: speed
	}

	function flip () {
		flipable.flipped = !flipable.flipped
	}
}
