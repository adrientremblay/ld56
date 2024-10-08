extends Panel

var LOWER_WEIGHT_BOUND = 100.0
var UPPER_WEIGHT_BOUND = 250.0
var FIRST_NAMES = ["Michael", "Bill", "Steve", "Randal", "Mary", "Angela"]
var LAST_NAMES = ["Smith", "Tremblay", "Deforges", "Williams"]
var MIN_REWARD = 25.0
var MAX_REWARD = 100.0

var FIRST_CONTRACT_TEXT = "Greetings. I am the spokesman for Nautilus. Your abilities for disposing bodies are well known to us. Please select among the following contracts..."
var NORMAL_CONTRACT_TEXT = "Please select among the following contracts..."
var NO_CONTRACTS_AVAILABLE_TEXT = "It seems you have no space for more bodies. Do not dissapoint us again."

var first_time_opening = true

@onready var contract_vbox: VBoxContainer = $VBoxContainer/CorpsePanelContainer/MarginContainer/ContractVBox
@export var contract_scene: PackedScene

var rng = RandomNumberGenerator.new()

signal should_spawn_corpse(person_name, weight, reward)
signal contract_menu_opened

func _ready() -> void:
	self.visible = false
	$Spokesman.play()

func _on_new_contract_timer_timeout() -> void:
	# empty contract list
	for child in contract_vbox.get_children():
		child.queue_free()
	# add a new contract to the list
	generateNewContract()
	generateNewContract()
	generateNewContract()
	# make the menu visible
	self.visible = true
	
	$NewContractTimer.stop()
	$NewContractTimer.wait_time = 30
	$SpokesmanSpeechNormal.play()
	
	if (first_time_opening):
		$Label.text = FIRST_CONTRACT_TEXT
	else:
		$Label.text = NORMAL_CONTRACT_TEXT
	
	$X.visible = false
	
	contract_menu_opened.emit()
	
	first_time_opening = false
	
func generateNewContract():
	var weight = snapped(rng.randf_range(LOWER_WEIGHT_BOUND, UPPER_WEIGHT_BOUND), 0.01)
	var first_name = FIRST_NAMES[rng.randi_range(0, FIRST_NAMES.size()-1)]
	var last_name = LAST_NAMES[rng.randi_range(0, LAST_NAMES.size()-1)]
	var reward = snapped(rng.randf_range(MIN_REWARD, MAX_REWARD), 0.01)
	
	var new_contract: Contract = contract_scene.instantiate()
	new_contract.construct(first_name + " " + last_name, weight, reward)
	new_contract.connect("contract_accepted", self.contract_accepted)
	contract_vbox.add_child(new_contract)
	
func contract_accepted(person_name, weight, reward):
	should_spawn_corpse.emit(person_name, weight, reward)
	contract_menu_opened.emit()
	
func no_contracts_available():
	$X.visible = true
	$Label.text = NO_CONTRACTS_AVAILABLE_TEXT
	
	$SpokesmanSpeechNormal.stop()
	$SpokesmanSpeechNo.play()

func _on_close_contract_menu_pressed() -> void:
	self.visible = false
	$NewContractTimer.start()
	$SpokesmanSpeechNormal.stop()
	$SpokesmanSpeechNo.stop()
