import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import "storage.js" as Storage
import "javascript.js" as Js

Flipable {
	property bool flipped: false
	property bool flipsvertically: false // true means the bottom goes up
	property int flipspeed: Js.getFlipSpeed()

	transform: Rotation {
		id: rotation
		origin.x: flipable.width / 2
		origin.y: flipable.height / 2
		axis.x: (flipsvertically)? 1 : 0; axis.y: (flipsvertically)? 0 : 1; axis.z: 0     // add option: which axis
		angle: 0  // the default angle
	}

	states: State {
		name: "back"
		PropertyChanges { target: rotation; angle: 180 }
		when: flipable.flipped
	}

	transitions: Transition {
		NumberAnimation { target: rotation; property: "angle"; duration: (Storage.getSetting("flippages") != "true")? 0 : flipspeed } // why does this always flip?
	}

	function flip () {
		flipable.flipped = !flipable.flipped
	}
}
