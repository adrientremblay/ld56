extends Panel

@onready var message_label = $MarginContainer/VBoxContainer/PanelContainer/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Variables used to determine if the assistant should ASSIST the player (noob) or not
var player_has_bought_a_filter = false
var player_has_bought_a_plant = false
var player_has_bought_a_creature = false

# Variables to determine what warnings have been triggered
var filter_warning_given = false
var neutralizer_warning_given = false
var plant_warning_given = false
var nn_warning_given = false
var health_warning_given = false

# Variable determines what warning is active
var filter_warning_active = false
var neutralizer_warning_active = false
var plant_warning_active = false
var nn_warning_active = false
var health_warning_active = false
var contract_warning_active = false
var creatures_warning_active = false

# Don't want to launch the noob timers more than once
var contract_noob_timer_used = false
var creature_noob_timer_used = false

func _ready() -> void:
	self.visible = false
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
	self.open("Ammonia levels are critical! You should buy the ammonia neutralizer item!")
	neutralizer_warning_given = true
	neutralizer_warning_active = true

func open_nitrate_warning():
	dismiss()
	self.open("The nitrate level is getting dangerous! You should buy plants to reduce it!")
	plant_warning_given = true
	plant_warning_active = true

func open_severe_nitrate_warning():
	dismiss()
	self.open("Nitrate levels are critical! You should buy the nitrate neutralizer item!")
	nn_warning_given = true
	nn_warning_active = true

func open_health_warning():
	dismiss()
	self.open("Your creatures are in poor health! You should buy the health booster item!")
	health_warning_given = true
	health_warning_active = true

func open_contract_warning():
	dismiss()
	self.open("Click the Contracts button to add corpses to the aquarium!")
	contract_warning_active = true
	
func open_creature_warning():
	if player_has_bought_a_creature:
		return
	dismiss()
	self.open("Click the Creatures button to add creatures to the aquarium!")
	creatures_warning_active = true

func _on_dismiss_button_pressed() -> void:
	dismiss()
	$DismissSound.play()

func dismiss():
	animation_player.play("close_animation")
	if filter_warning_active:
		filter_warning_active = false
	if neutralizer_warning_active:
		neutralizer_warning_active = false
	if plant_warning_active:
		plant_warning_active = false
	if nn_warning_active:
		nn_warning_active = false
	if health_warning_active:
		health_warning_active = false
	if contract_warning_active:
		contract_warning_active = false
	if creatures_warning_active:
		creatures_warning_active = false

func _on_noob_timer_has_not_opened_contract_menu_timeout() -> void:
	open_contract_warning()
	$NoobTimerHasNotOpenedContractMenu.stop()

func _on_noob_timer_has_not_bought_creature_timeout() -> void:
	open_creature_warning()
	$NoobTimerHasNotBoughtCreature.stop()
