extends Panel

var LOWER_WEIGHT_BOUND = 100.0
var UPPER_WEIGHT_BOUND = 250.0
var MALE_FIRST_NAMES = ["Michael", "Bill", "Steve", "Randal"]
var FEMALE_FIRST_NAMES = ["Mary", "Angela", "Jennifer", "Sarah"]
var LAST_NAMES = ["Smith", "Tremblay", "Deforges", "Williams"]
var MIN_REWARD = 25.0
var MAX_REWARD = 100.0

@onready var contract_vbox: VBoxContainer = $VBoxContainer/CorpsePanelContainer/MarginContainer/ScrollContainer/ContractVBox
@export var contract_scene: PackedScene

var rng = RandomNumberGenerator.new()

signal should_spawn_corpse(person_name, weight, reward, apperance)
signal contract_menu_opened
signal contract_menu_closed

func _ready() -> void:
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	$NewContractTimer.process_mode = Node.PROCESS_MODE_PAUSABLE

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
	
	$X.visible = false
	
	contract_menu_opened.emit()
	
	get_tree().paused = true
	
func generateNewContract():
	var weight = snapped(rng.randf_range(LOWER_WEIGHT_BOUND, UPPER_WEIGHT_BOUND), 0.01)
	var female = randf() > 0.5
	var first_names
	if female:
		first_names = FEMALE_FIRST_NAMES
	else:
		first_names = MALE_FIRST_NAMES
	var first_name = first_names[rng.randi_range(0, first_names.size()-1)]
	var last_name = LAST_NAMES[rng.randi_range(0, LAST_NAMES.size()-1)]
	var reward = snapped(rng.randf_range(MIN_REWARD, MAX_REWARD), 0.01)
	
	var new_contract: Contract = contract_scene.instantiate()
	new_contract.construct(first_name + " " + last_name, weight, reward, female)
	new_contract.connect("contract_accepted", self.contract_accepted)
	contract_vbox.add_child(new_contract)
	
func contract_accepted(person_name, weight, reward, appearance, female):
	should_spawn_corpse.emit(person_name, weight, reward, appearance, female)
	contract_menu_opened.emit()
	
func no_contracts_available():
	$X.visible = true

func _on_close_contract_menu_pressed() -> void:
	self.visible = false
	$NewContractTimer.start()
	get_tree().paused = false
	contract_menu_closed.emit()
