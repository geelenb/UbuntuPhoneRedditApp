import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import QtWebKit 3.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "storage.js" as Storage
import "javascript.js" as Js

Tab {
	anchors.fill: parent
	property string url: "/"

	title: (url == "/") ? "reddit.com" : url.substring(1)

	Flipable {
		id: flipable
		anchors.fill: parent

		property bool flipped: false

		JSONListModel {
			id: linkslistmodel
			source: "http://www.reddit.com" + url + ".json" + "?limit=" + Js.getFetchedArray()[Storage.getSetting("numberfetchedposts")]
			query: "$.data.children[*]"
		}

		front: Rectangle {
			anchors.fill: parent

			color: Js.getBackgroundColor()

			ListView {
				anchors.fill: parent

				model: linkslistmodel.model
				enabled: !flipable.flipped

				delegate: ListItem.Standard {
					id: listitem
					height: units.gu(parseInt(Storage.getSetting("postheight")))
					width: parent.width


					UbuntuShape {
						id: thumbshape
						height: parent.height
						width: (model.data.thumbnail == "self" || Storage.getSetting("enablethumbnails") != "true") ? 0 : parent.height
						anchors.left: (Storage.getSetting("thumbnailsonleftside") == "true") ? parent.left : undefined //make option
						anchors.right: (Storage.getSetting("thumbnailsonleftside") == "true") ? undefined : parent.right
						radius: (Storage.getSetting("rounderthumbnails") == "true") ? "medium" : "small"

						image: Image {
							id: thumbimage

							fillMode: Image.Stretch

							function mustBeShown (link) {
								return !(link == "self" || link == "nsfw" || link == "default")
							}

							source: (mustBeShown (model.data.thumbnail))?
										model.data.thumbnail : ""
						}

						MouseArea {
							anchors.fill: parent
							onClicked: {
								flipable.flipped = true
								backside.commentpage = false
								backside.urlviewing = model.data.url
							}
							enabled: !flipable.flipped
						}
					}

					Rectangle {
						height: parent.height
						width: parent.width - thumbshape.width

						anchors.left: (Storage.getSetting("thumbnailsonleftside") == "true") ? undefined : parent.left
						anchors.right: (Storage.getSetting("thumbnailsonleftside") == "true") ? parent.right : undefined

						color: Js.getBackgroundColor()

						Label {
							width: parent.width
							text: model.data.title
							wrapMode: Text.Wrap
							maximumLineCount: 2

							font.pixelSize: parent.height / 4
						}

						Label {
							width: parent.width
							wrapMode: Text.Wrap
							maximumLineCount: 1
							font.pixelSize: parent.height / 5

							anchors.bottom: parent.bottom
							//							anchors.left: thumbshape.right

							text: "Score: " + model.data.score +
								  ((url == "/" || url == "/r/all") ? " in r/" + model.data.subreddit : "") +
								  " by " + model.data.author +
								  " (" + model.data.domain + ")"
						}
					}
				}
			}
		}

		back: Rectangle {
			id: backside

			property bool commentpage: false
			property string urlviewing: ""

			anchors.fill: parent
			color: Js.getBackgroundColor()

			Button {
				id: backbutton
				text: "Go back"
				height: units.gu(4)
				width: parent.width
				onClicked: {
					flipable.flip()
					webview.stop
				}
				enabled: flipable.flipped
			}

			Rectangle {
				id: commentrectangle
				opacity: (backside.commentpage)? 1 : 0

				height: parent.height - backbutton.height
				width: parent.width
				anchors.top: backbutton.bottom

				property string permalink: ""

				Rectangle {
					id: postrectangle
					//	anchors.
				}
			}

			Rectangle {
				id: linkrectangle
				opacity: (backside.commentpage)? 0 : 1

				height: parent.height - backbutton.height
				width: parent.width
				anchors.top: backbutton.bottom

				WebView {
					id: webview
					anchors.fill: parent

					url: backside.urlviewing
					smooth: true
				}
			}
		}

		transform: Rotation {
			id: rotation
			origin.x: flipable.width/2
			origin.y: flipable.height/2
			axis.x: 0; axis.y: 1; axis.z: 0
			angle: 0    // the default angle
		}

		states: State {
			name: "back"
			PropertyChanges { target: rotation; angle: 180 }
			when: flipable.flipped
		}

		transitions: Transition {
			NumberAnimation { target: rotation; property: "angle"; duration: Storage.getSetting("flipspeed")  } // add option: speed
		}

		function flip () {
			flipable.flipped = !flipable.flipped
		}
	}
}
