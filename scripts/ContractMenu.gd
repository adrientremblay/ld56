extends Panel

var WEIGHT_DATA = {
	Contract.Appearance.LIGHT:
		{
			"lower_bound": 75.0,
			"upper_bound": 124.9,
			"reward_per_pound": 2.0,
			"base_contracts": 2
		},
	Contract.Appearance.MEDIUM:
		{
			"lower_bound": 125.0,
			"upper_bound": 174.9,
			"reward_per_pound": 2.5,
			"base_contracts": 0
		},
	Contract.Appearance.HEAVY:
		{
			"lower_bound": 175.0,
			"upper_bound": 224.9,
			"reward_per_pound": 3.5,
			"base_contracts": 0
		},
	Contract.Appearance.OBESE:
		{
			"lower_bound": 225.0,
			"upper_bound": 400.9,
			"reward_per_pound": 5.0,
			"base_contracts": 0
		}
}

var MALE_FIRST_NAMES = ["Michael", "Bill", "Steve", "Randal", "Windhelm", "Adrien", "William", "Guillaume", "Cedric", "Tim", "David", "Philip", "Darsh", "Joshua"]
var FEMALE_FIRST_NAMES = ["Mary", "Angela", "Jennifer", "Sarah", "Lydia", "Adrienne", "Joan", "Lucy", "Mei", "Fatima", "Sofia", "Amara", "Olga", "Hannah"]
var LAST_NAMES = ["Smith", "Tremblay", "Deforges", "Williams", "Sanderson", "Wells", "Biens", "Martens", "Freiman", "Huculak", "Voinea", "Glazer", "Dubois", "Laplante", "Lee", "Nygen", "Singh", "Garcia"]

# The format is [NAME] + backstory
var POTENTIAL_BACKSTORIES = [
	" was a guidance councelor at a local high school. They abused their power and abused children. They were reported to a local vigilante group and executed.",
	" bumped into the wrong person at a club. That person used their criminal connections to contact us.",
	" was a whistleblower for a large pharmacutical company. They were killed by hitmen hired by the company.",
	" lived on the streets for 14 years before they were kidnapped by a secretive bio-engineering company for human experiments.",
	" was in the advanced stages of MS before he resorted to illegal experimental treatement. Their body needs to be disposed of so as to not arouse suspicion.",
	" was a former mob accountant who tried to embezzle money from the organization. They were caught and made an example of.",
	" was an undercover cop who got too close to uncovering the organization's operations. Their cover was blown, and they had to be eliminated.",
	" was a journalist investigating a high-profile politician's ties to corporate corruption. They were getting too close to publishing what they had and were killed.",
	" was a hacker who breached into a server ran by a human trafficking ring. A darkweb assassin was promply sent to hunt him down.",
	" was a rival gang member caught encroaching on a cartel's drug peddling territory. Their death sends a clear message.",
	" was a high-profile escort who overheard a conversation they shouldn’t have during a private event for the rich and powerful.",
	" was a disgruntled former employee of a weapons manufacturer who tried to sell corporate secrets on the black market.",
	" was an activist organizing protests against a corrupt corporation. The company used its underworld connections to silence them.",
	" was a reckless driver who caused a fatal accident. The victims father hired an assassin to retaliate.",
	" was the CEO of an insurance company. A disgruntled client who had their medical claim denied gunned them down in the street.",
]

@onready var contract_vbox: VBoxContainer = $VBoxContainer/CorpsePanelContainer/MarginContainer/ScrollContainer/ContractVBox
@export var contract_scene: PackedScene

var rng = RandomNumberGenerator.new()

# we dont want to start the timer if the player has not bought a single contract.
var accepted_a_contract = false
var should_refresh_contracts = true

signal should_spawn_corpse(person_name, weight, reward, apperance)
signal contract_menu_opened
signal contract_menu_closed 

func _ready() -> void:
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	$NewContractTimer.process_mode = Node.PROCESS_MODE_PAUSABLE

func open_contract_menu(level: int):
	if self.visible == true:
		return
	
	if should_refresh_contracts:
		# empty contract list
		for child in contract_vbox.get_children():
			child.queue_free()
		
		# determine how many of each type of contract we should add depending on the level
		var light_corpses: int = min(2 + level, 5)
		var medium_corpses: int = min(max(level, 0), 5) if level >= 2 else 0
		var heavy_corpses: int = min(max(level-1, 0), 5) if level >= 3 else 0
		var obese_corpses: int = max(level-2, 0) if level >= 4 else 0
		
		# generate the corpses per size type
		for i in range(light_corpses):
			generateNewContract(Contract.Appearance.LIGHT)
		for i in range(medium_corpses):
			generateNewContract(Contract.Appearance.MEDIUM)
		for i in range(heavy_corpses):
			generateNewContract(Contract.Appearance.HEAVY)
		for i in range(obese_corpses):
			generateNewContract(Contract.Appearance.OBESE)

	# make the menu visible
	self.visible = true		
	$NewContractTimer.stop()
	$X.visible = false
	contract_menu_opened.emit()
	$ContractMusic.play()
	get_tree().paused = true
	self.accepted_a_contract = false
	self.should_refresh_contracts = false

func generateNewContract(corpse_weight: Contract.Appearance):
	var weight_lower_bound = WEIGHT_DATA[corpse_weight].lower_bound
	var weight_upper_bound = WEIGHT_DATA[corpse_weight].upper_bound
	var weight = snapped(rng.randf_range(weight_lower_bound, weight_upper_bound), 0.1)
	
	var female = randf() > 0.5
	var first_names
	if female:
		first_names = FEMALE_FIRST_NAMES
	else:
		first_names = MALE_FIRST_NAMES
	var first_name = first_names[rng.randi_range(0, first_names.size()-1)]
	var last_name = LAST_NAMES[rng.randi_range(0, LAST_NAMES.size()-1)]
	
	# Calculating reward + randomness
	var reward = snappedf(weight * WEIGHT_DATA[corpse_weight].reward_per_pound, 0.01)
	reward = reward * randf_range(0.8, 1.2)
	
	var description = first_name + POTENTIAL_BACKSTORIES[rng.randf_range(0, POTENTIAL_BACKSTORIES.size() - 1)]
	
	var new_contract: Contract = contract_scene.instantiate()
	new_contract.construct(first_name + " " + last_name, weight, reward, female, corpse_weight, description)
	new_contract.connect("contract_accepted", self.contract_accepted)
	contract_vbox.add_child(new_contract)
	
func contract_accepted(person_name, weight, reward, appearance, female):
	should_spawn_corpse.emit(person_name, weight, reward, appearance, female)
	contract_menu_opened.emit()
	self.accepted_a_contract = true
	
func no_contracts_available():
	$X.visible = true

func _on_close_contract_menu_pressed() -> void:
	if self.accepted_a_contract:
		self.should_refresh_contracts = true
	self.visible = false
	get_tree().paused = false
	contract_menu_closed.emit()
	$ContractMusic.stop()
