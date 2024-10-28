extends Panel

var LOWER_WEIGHT_BOUND = 100.0
var UPPER_WEIGHT_BOUND = 250.0
var MALE_FIRST_NAMES = ["Michael", "Bill", "Steve", "Randal"]
var FEMALE_FIRST_NAMES = ["Mary", "Angela", "Jennifer", "Sarah"]
var LAST_NAMES = ["Smith", "Tremblay", "Deforges", "Williams"]
var MIN_REWARD = 25.0
var MAX_REWARD = 100.0
var ORGANIZATIONS = [
	{
		"name" : "PureGenus",
		"description1" : "They believe that the average human genetic composition has become inferior",
		"description2" : "Kidnap people they believe have inferior genes and forcefully sterilise them. There are often fatalities in the struggle",
		"description3" : "There is a heavy racial bias in determining if an individual is 'inferior' or not",
		"karma" : -0.3,
		"backstories" : [
			"Sadly, [Name] wore glasses. He was unlucky enough to bump into a member of PureGenus at a club. A week later he was kidnapped and perished during the attempted back-alley castration."
		]
	},
	{
		"name" : "Blackstone Pharma",
		"description1" : "Performs human experiments on people",
		"description2" : "Sells drugs at exorbitant markups",
		"description3" : "Markets unnecessary drugs to vulnerable groups of people",
		"karma" : -0.2,
		"backstories" : [
			"[Name] was a successful lawyer before alcoholism and undiagnosed schizophrenia got the best of him. He has been homeless for the last 20 years. Blackstone abducted him one fateful night. No one noticed his disappearance."
		]
	},
	{
		"name" : "The Reclamation Network",
		"description1" : "Anonymously donate organs to hospitals around the globe ultimately saving lives",
		"description2" : "Secretly sources their organs from proven rapists and pedophiles both in and out of prison",
		"description3" : "Comprised primarily by ex law enforcement",
		"karma" : 0.2,
		"backstories" : [
			"[Name] was a guidance councellor for underprivileged youth at a high school. They abused their position to molest students for 3 years. Video proof was presented to the reclamation network and the rest is history."
		]
	},
	{
		"name" : "Project Horizon",
		"description1" : "Performs experimental treatments on willing volunteers who are infected with fatal diseases",
		"description2" : "Their activity is illegal",
		"description3" : "Wish to dispose of bodies to avoid detection and public scrutiny",
		"karma" : 0.3,
		"backstories" : [
			"Facing the advanced stages of Multiple Sclerosis, [Name] resorted to Project Horizon's risky gene therapy treatement. Unfortunately, he succumbed to his condition. His body needs to be disposed of avoid connecting him to the organization."
		]
	},
]

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
	
	var organization = ORGANIZATIONS[rng.randi_range(0, ORGANIZATIONS.size()-1)]
	var backstory: String = organization.backstories[rng.randi_range(0, organization.backstories.size()-1)]
	backstory = backstory.replace("[Name]", first_name)
	
	var reward = calculate_reward_for_contract(weight, organization.karma)
	
	var new_contract: Contract = contract_scene.instantiate()
	new_contract.construct(first_name + " " + last_name, weight, reward, female, organization.name, backstory)
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

func calculate_reward_for_contract(weight: float, karma: float) -> float:
	var weight_percentage = (weight - LOWER_WEIGHT_BOUND) / (UPPER_WEIGHT_BOUND - LOWER_WEIGHT_BOUND)
	var reward = MIN_REWARD + (MAX_REWARD-MIN_REWARD) * weight_percentage
	reward = (1-karma)*reward
	return reward
