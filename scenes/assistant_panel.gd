extends Panel

@onready var message_label = $MarginContainer/VBoxContainer/PanelContainer/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Variables used to determine if the assistant should ASSIST the player (noob) or not
var player_has_bought_a_filter = false

# Variables to determine what warnings have been triggered
var filter_warning_given = false
var neutralizer_warning_given = false

# Variable determines what warning is active
var filter_warning_active = false
var neutralizer_warning_active = false

func _ready() -> void:
	$MarginContainer/VBoxContainer/AnimatedSprite2D.play()

func open(message: String):
	message_label.text = message
	self.visible = true
	animation_player.play("open_animation")
	#$AssistantSound.play()
	$AssistantSpeech.play()

func open_ammonia_warning():
	dismiss()
	self.open("The ammonia level is getting dangerous! You should probably buy a filter to reduce it!")
	filter_warning_given = true
	filter_warning_active = true
	
func open_severe_ammonia_warning():
	dismiss()
	self.open("The ammonia levels are critical! You should buy the ammonia neutralizer item!")
	neutralizer_warning_given = true
	neutralizer_warning_active = true
	
func _on_dismiss_button_pressed() -> void:
	dismiss()
	$DismissSound.play()

func dismiss():
	animation_player.play("close_animation")
	if filter_warning_active:
		filter_warning_active = false
	if neutralizer_warning_active:
		neutralizer_warning_active = false
