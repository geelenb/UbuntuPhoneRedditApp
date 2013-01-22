import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "storage.js" as Storage
import "javascript.js" as Js

Tab {
	id: settingstab

	anchors.fill: parent

	title: "Settings"

	MyFlipable {
		id: flipable
		anchors.fill: parent

		flipsvertically: false

		front: Rectangle {
			id: frontside
			anchors.fill: parent

			color: Js.getBackgroundColor()
			enabled: !flipable.flipped

			Column {
				anchors.fill: parent

				Component.onCompleted: {
					Storage.initialize()

					numberfetchedposts.selectedIndex = parseInt(Storage.getSetting("numberfetchedposts"))
					numberfetchedcomments.selectedIndex = parseInt(Storage.getSetting("numberfetchedcomments"))
					// account...
					// subreddits...
					enablethumbnails.loadValue()
					thumbnailsonleftside.loadValue()
					rounderthumbnails.loadValue()
					postheight.value = parseInt(Storage.getSetting("postheight"))
					nightmode.loadValue()
					flippages.loadValue()
				}

				ListItem.Header {
					text: "Reddit options"
				}

				ListItem.ValueSelector {
					id: numberfetchedposts
					text: "Number of fetched posts"

					property string value: values[selectedIndex]

					values: Js.getFetchedArray()

					onSelectedIndexChanged: Storage.setSetting("numberfetchedposts", selectedIndex)
				}

				ListItem.ValueSelector {
					id: numberfetchedcomments
					text: "Number of fetched comments"

					values: ["10", "15", "25", "50"]

					onSelectedIndexChanged: Storage.setSetting("numberfetchedcomments", selectedIndex)
				}

				ListItem.SingleControl {
					control: Button {
						width: parent.width * 3 / 4
						anchors.topMargin: units.gu(1)
						anchors.bottomMargin: units.gu(1)
						anchors.centerIn: parent

						text: "Account..."

						onClicked: backside.loadLogin()
					}
				}

				ListItem.SingleControl {
					control: Button {
						width: parent.width * 3 / 4
						anchors.topMargin: units.gu(1)
						anchors.bottomMargin: units.gu(1)
						anchors.centerIn: parent

						text: "Subreddits..."

						onClicked: backside.loadSubreddits()
					}
				}

				ListItem.Divider{}

				ListItem.Header {
					text: "Thumbnails"
				}

				ListItem.Standard {
					text: "Enable thumbnails"

					control: SettingSwitch {
						id: enablethumbnails
						name: "enablethumbnails"
					}
				}

				ListItem.Standard {
					text: "Display thumbnails on left side"
					enabled: enablethumbnails.checked

					control: SettingSwitch {
						id: thumbnailsonleftside
						name: "thumbnailsonleftside"
					}
				}

				ListItem.Standard {
					text: "Rounder thumbnails"
					enabled: enablethumbnails.checked

					control: SettingSwitch {
						id: rounderthumbnails
						name: "rounderthumbnails"
					}
				}

				ListItem.Divider{}

				ListItem.Header {
					text: "Appearance"
				}

				ListItem.Standard {
					text: "Height of posts:"
				}

				ListItem.SingleControl {
					control: Slider {
						id: postheight

						anchors.margins: units.gu (1)
						anchors.fill: parent
						minimumValue: 5
						maximumValue: 16
						live: true

						value: 8

						onValueChanged: Storage.setSetting("postheight", value)
					}
				}

				ListItem.Standard {
					text: "Flip pages"

					control: SettingSwitch {
						id: flippages
						name: "flippages"
					}
				}

				ListItem.Standard {
					text: "Night mode"

					control: SettingSwitch {
						id: nightmode
						name: "nightmode"
					}
				}
			}
		}

		back: Rectangle {
			id: backside

			anchors.fill: parent
			color: Js.getBackgroundColor()
			enabled: flipable.flipped

			function loadLogin () {
				loginpage.opacity = 1
				subredditlist.opacity = 0

				flipable.flipped = true
			}

			function loadSubreddits () {
				loginpage.opacity = 0
				subredditlist.opacity = 1

				flipable.flipped = true
			}

			property bool commentpage: false
			property string urlviewing: ""

			Button {
				id: backbutton
				text: "Go back"
				height: units.gu(4)
				width: parent.width
				onClicked: {
					flipable.flip()
				}
			}

			Rectangle {
				height: parent.height - backbutton.height
				width: parent.width
				anchors.bottom: parent.bottom
				color: parent.color

				Rectangle {
					id: loginpage
					opacity: 1

					anchors.fill: parent
					color: parent.color

					Column {
						anchors.fill:parent

						ListItem.Empty {
							width: parent.width
							height: accounttextfield.height

							TextField {
								id: accounttextfield

								width: parent.width
								height: units.gu(Storage.getSetting("postheight"))

								placeholderText: "Account name"

								onTextChanged: Storage.setSetting("accountname", text)

								enabled: loginpage.opacity == 1

								font.pixelSize: parent.height / 2
							}
						}

						ListItem.Empty {
							width: parent.width
							height: passwordtextfield.height

							TextField {
								id: passwordtextfield

								width: parent.width
								height: accounttextfield.height

								placeholderText: "password"

								onTextChanged: Storage.setSetting("password", text)

								enabled: loginpage.opacity == 1

								echoMode: TextInput.Password
								font.pixelSize: parent.height / 2
							}
						}
					}
				}

				Rectangle {
					id: subredditlist

					anchors.fill: parent
					color: Js.getBackgroundColor()

//					Column {
//						anchors.fill: parent


//						Repeater {
//							model: ["reddit a", "reddit b"]//Storage.getSubreddits()

//							anchors.fill: parent

//							delegate: ListItem.Standard {
//								text: model[0]

//								width: parent.width
//								height: units.gu(Storage.getSetting("postheight"))
//							}
//						}
//					}
				}

			}
		}
	}
}
