extends Panel

var LOWER_WEIGHT_BOUND = 120.0
var UPPER_WEIGHT_BOUND = 200.0
var FIRST_NAMES = ["Michael", "Bill", "Steve", "Randal", "Mary", "Angela"]
var LAST_NAMES = ["Smith", "Tremblay", "Deforges", "Williams"]
var MIN_REWARD = 25.0
var MAX_REWARD = 100.0

@onready var contract_vbox: VBoxContainer = $VBoxContainer/CorpsePanelContainer/MarginContainer/ContractVBox
@export var contract_scene: PackedScene

var rng = RandomNumberGenerator.new()

signal should_spawn_corpse(person_name, weight, reward)
signal contract_menu_opened

func _onready():
	self.visible = false

func _on_new_contract_timer_timeout() -> void:
	# add a new contract to the list
	generateNewContract()
	# make the menu visible
	self.visible = true
	$NewContractTimer.stop() # TODO: remove
	
	contract_menu_opened.emit()
	
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
	self.visible = false
