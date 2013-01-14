function getBackgroundColor () {
	if (Storage.getSetting("nightmode") == "true")
		return "#333333"
	else
		return "#eeeeee"
}

function getFetchedArray () {
	return ["10", "15", "25", "50"]
}
