extends Panel

var LOWER_WEIGHT_BOUND = 100.0
var UPPER_WEIGHT_BOUND = 250.0
var GOLIATH_LOWER_WEIGHT_BOUND = 250.0
var GOLIATH_UPPER_WEIGHT_BOUND = 500.0
var MALE_FIRST_NAMES = ["Michael", "Bill", "Steve", "Randal"]
var FEMALE_FIRST_NAMES = ["Mary", "Angela", "Jennifer", "Sarah"]
var LAST_NAMES = ["Smith", "Tremblay", "Deforges", "Williams"]
var MIN_REWARD = 500.0
var MAX_REWARD = 2200.0
var GOLIATH_MIN_REWARD = 2750.0
var GOLIATH_MAX_REWARD = 5000.0
# The format is [NAME] + backstory
var POTENTIAL_BACKSTORIES = [
		" was a guidance councelor at a local high school. They abused their power and abused children. They were reported to a local vigilante group and executed.",
		" bumped into the wrong person at a club. That person used their criminal connections to contact us.",
		" was a whistleblower for a large pharmacutical company. They were killed by hitmen hired by the company.",
		" lived on the streets for 14 years before they were kidnapped by a secretive bio-engineering company for human experiments.",
		" was in the advanced stages of MS before he resorted to illegal experimental treatement. His body needs to be disposed of so as to not arouse suspicion.",
		" was a former mob accountant who tried to embezzle money from the organization. They were caught and made an example of.",
		" was an undercover cop who got too close to uncovering the organization's operations. Their cover was blown, and they had to be eliminated.",
		" was a journalist investigating a high-profile politician's ties to corporate corruption. They were getting too close to publishing what they had and were killed.",
		" was a hacker who breached into a server ran by a human trafficking ring. A darkweb assassin was promply sent to hunt him down.",
		" was a rival gang member caught encroaching on a cartel's drug peddling territory. Their death sends a clear message.",
		" was a high-profile escort who overheard a conversation they shouldn’t have during a private event for the rich and powerful.",
		" was a disgruntled former employee of a weapons manufacturer who tried to sell corporate secrets on the black market.",
		" was an activist organizing protests against a corrupt corporation. The company used its underworld connections to silence them.",
		" was a reckless driver who caused a fatal accident. The victims father hired an assassin to retaliate."
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

func open_contract_menu():
	if self.visible == true:
		return
	
	# empty contract list
	for child in contract_vbox.get_children():
		child.queue_free()
	# add 7 new contracts to the list
	for i in range(12):
		generateNewContract()
	# make the menu visible
	self.visible = true
	
	$NewContractTimer.stop()
	
	$X.visible = false
	
	contract_menu_opened.emit()
	
	get_tree().paused = true
func generateNewContract():
	var upgrade_weight_to_goliath_class = randf() < 0.25
	var weight
	if (upgrade_weight_to_goliath_class):
		weight = snapped(rng.randf_range(GOLIATH_LOWER_WEIGHT_BOUND, GOLIATH_UPPER_WEIGHT_BOUND), 0.01)
	else:
		weight = snapped(rng.randf_range(LOWER_WEIGHT_BOUND, UPPER_WEIGHT_BOUND), 0.01)
	
	var female = randf() > 0.5
	var first_names
	if female:
		first_names = FEMALE_FIRST_NAMES
	else:
		first_names = MALE_FIRST_NAMES
	var first_name = first_names[rng.randi_range(0, first_names.size()-1)]
	var last_name = LAST_NAMES[rng.randi_range(0, LAST_NAMES.size()-1)]
	
	var reward = calculate_reward_for_contract(weight)
	
	var bonus = "None."
	if upgrade_weight_to_goliath_class:
		bonus = "Yes, due to it's massive size."
	
	var description = first_name + POTENTIAL_BACKSTORIES[rng.randf_range(0, POTENTIAL_BACKSTORIES.size() - 1)]
	
	var new_contract: Contract = contract_scene.instantiate()
	new_contract.construct(first_name + " " + last_name, weight, reward, female, bonus, description)
	new_contract.connect("contract_accepted", self.contract_accepted)
	contract_vbox.add_child(new_contract)
	
func contract_accepted(person_name, weight, reward, appearance, female):
	should_spawn_corpse.emit(person_name, weight, reward, appearance, female)
	contract_menu_opened.emit()
	
func no_contracts_available():
	$X.visible = true

func _on_close_contract_menu_pressed() -> void:
	self.visible = false
	get_tree().paused = false
	contract_menu_closed.emit()

func calculate_reward_for_contract(weight: float) -> float:
	if weight < GOLIATH_LOWER_WEIGHT_BOUND:
		var weight_percentage = (weight - LOWER_WEIGHT_BOUND) / (UPPER_WEIGHT_BOUND - LOWER_WEIGHT_BOUND)
		var reward = MIN_REWARD + (MAX_REWARD-MIN_REWARD) * weight_percentage
		#reward = (1-karma)*reward
		return snappedf(reward, 0.01)
	else:
		var weight_percentage = (weight - GOLIATH_LOWER_WEIGHT_BOUND) / (GOLIATH_UPPER_WEIGHT_BOUND - LOWER_WEIGHT_BOUND)
		var reward = GOLIATH_MIN_REWARD + (GOLIATH_MAX_REWARD-GOLIATH_MIN_REWARD) * weight_percentage
		#reward = (1-karma)*reward
		return snappedf(reward, 0.01)
