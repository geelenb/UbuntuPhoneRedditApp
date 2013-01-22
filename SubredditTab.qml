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

//	what are the real icon names for these?
//	is it possible to see icon and title in the title bar?
//	iconSource: (url == "/") ? "image://gicon/go-home" :
//				(url == "/r/all") ? "image://gicon/help-about" : ""

	title: (url == "/") ? "reddit.com" : url.substring(1)

	MyFlipable {
		id: flipable
		anchors.fill: parent

		flipsvertically: false

		onFlippedChanged: {
			if (!flipped) {
				pagestack.clear()
				webview.url = ""
			}
		}

		JSONListModel {
			id: linkslistmodel
			source: "http://www.reddit.com" + url + ".json" + "?limit=" + Js.getFetchedArray()[Storage.getSetting("numberfetchedposts")]
			query: "$.data.children[*]"
		}

		front: Rectangle {
			anchors.fill: parent
			enabled: !flipable.flipped

			color: Js.getBackgroundColor()

			ListView {
				anchors.fill: parent

				model: linkslistmodel.model

				delegate: ListItem.Standard {
					id: listitem
					height: units.gu(parseInt(Storage.getSetting("postheight")))
					width: parent.width

					UbuntuShape {
						id: thumbshape
						height: parent.height
						width: (model.data.thumbnail == "self" || Storage.getSetting("enablethumbnails") != "true") ? 0 : parent.height
						anchors.left: (Storage.getSetting("thumbnailsonleftside") == "true") ? parent.left : undefined
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

						Flipable { // why can't this be made into a myflipable?
							id: itemflipable
							anchors.fill: parent

							property bool flipped: false

							front: Rectangle {
								anchors.fill: parent
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

								MouseArea {
									anchors.fill: parent

									enabled: !itemflipable.flipped
									onClicked: itemflipable.flip()
								}
							}

							back: Rectangle {
								anchors.fill: parent
//								color: Js.getBackgroundColor()

								Row {
									anchors.fill: parent

									Rectangle {
										width: parent.width / 5
										height: parent.height
										color: Js.getBackgroundColor()

										Rectangle {
											height: (parent.width < parent.height) ? parent.width : parent.height
											width: height
											color: Js.getBackgroundColor()

											anchors.left: parent.left

											Image {
												anchors.fill: parent
												source: "upvoteEmpty.png"
												fillMode: Image.Stretch
											}
										}

										MouseArea {
											anchors.fill:parent
											enabled: itemflipable.flipped
											onClicked: console.log("Upvoted!")
										}
									}

									Rectangle {
										width: parent.width / 5
										height: parent.height
										color: Js.getBackgroundColor()

										Label {
											anchors.centerIn: parent
											text: "Comments"
										}

										MouseArea {
											anchors.fill: parent
											enabled: itemflipable.flipped
											onClicked: {
												flipable.flip()
												commentrectangle.loadPage(model.data.permalink)
												backside.commentpage = true
											}
										}
									}

									Rectangle {
										width: parent.width / 5
										height: parent.height
										color: Js.getBackgroundColor()

										Label {
											anchors.centerIn: parent
											text: "back"
										}

										MouseArea {
											anchors.fill: parent
											enabled: itemflipable.flipped
											onClicked: itemflipable.flip()
										}
									}

									Rectangle {
										width: parent.width / 5
										height: parent.height
										color: Js.getBackgroundColor()

										Label {
											anchors.centerIn: parent
											text: "u/" + model.data.author
										}

										MouseArea {
											anchors.fill: parent
											enabled: itemflipable.flipped
											onClicked: console.log("Go to the user's page!")
										}
									}

									Rectangle {
										width: parent.width / 5
										height: parent.height

										color: Js.getBackgroundColor()

										Rectangle {
											height: (parent.width < parent.height) ? parent.width : parent.height //smallest of width and height
											width: height
											color: Js.getBackgroundColor()

											anchors.right: parent.right

											Image {
												source: "downvoteEmpty.png"
												fillMode: Image.Stretch
												anchors.fill: parent
											}
										}

										MouseArea {
											anchors.fill: parent
											enabled: itemflipable.flipped
											onClicked: console.log("Downvoted!")
										}
									}
								}
							}

							transform: Rotation {
								id: rotation
								origin.x: itemflipable.width / 2
								origin.y: itemflipable.height / 2
								axis.x: 1; axis.y: 0; axis.z: 0     // add option: which axis
								angle: 0    // the default angle
							}

							states: State {
								name: "back"
								PropertyChanges { target: rotation; angle: 180 }
								when: itemflipable.flipped
							}

							transitions: Transition {
								NumberAnimation { target: rotation; property: "angle"; duration: 200 }
							}

							function flip () {
								itemflipable.flipped = !itemflipable.flipped
							}
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
			enabled: flipable.flipped

			Button {
				id: backbutton
				text: "Go back"
				height: units.gu(4)
				width: parent.width
				onClicked: flipable.flip()
			}

			Rectangle {
				id: commentrectangle
				opacity: (backside.commentpage)? 1 : 0
				color: Js.getBackgroundColor()

				// why isn't this enabled?
				// TODO: fix contents

				height: parent.height - backbutton.height
				width: parent.width
				anchors.top: backbutton.bottom

				property string permalink: ""

				function loadPage (n_permalink) {
					permalink = n_permalink;
					commentslistmodel.source = "http://www.reddit.com" + permalink + ".json"
					pagestack.clear()
					pagestack.push(rootpage)
				}

				JSONListModel {
					id: commentslistmodel
					query: "$[1].data.children[*]"
				}

				PageStack {
					id: pagestack
					anchors.fill: parent

					// try to merge these next 2
					Component {
						id: rootpage
						Page {
							title: "test1"

							ListView {
								anchors.fill: parent
								model: commentslistmodel.model

								delegate: ListItem.Standard {
									text: model.data.body

									progression: true
									onClicked: {
										console.log("clicked")
										pagestack.push(newpage, {commentsModel: model.data.replies.data.children})
									}
								}
							}
						}
					}

					Component {
						id: newpage

						Page {
							id: page
							title: "test2"

							property variant commentsModel: []

							ListView {
								anchors.fill: parent
								model: commentsModel

								delegate: ListItem.Standard {
									text: modelData.data.body


									progression: true
									onClicked: pagestack.push(newpage, {commentsModel: modelData.data.replies.data.children})
								}
							}
						}
					}
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
	}
}
