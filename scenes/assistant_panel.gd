extends Panel

@onready var message_label = $MarginContainer/VBoxContainer/PanelContainer/Label

# Variables used to determine if the assistant should ASSIST the player (noob) or not
var player_has_bought_a_filter = false

# Variables to determine what warnings have been triggered
var filter_warning_given = false

func open(message: String):
	message_label.text = message
	self.visible = true

func open_ammonia_warning():
	self.open("The ammonia level is getting dangerous! You should probably buy a filter to reduce it!")
	filter_warning_given = true
	
