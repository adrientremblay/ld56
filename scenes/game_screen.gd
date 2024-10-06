extends Node2D

@export var landCreatureScene: PackedScene
@export var corpse_scene: PackedScene

@onready var contract_menu = $UI/ContractMenu
@onready var corpse_spawn1 = $Aquarium/CorpseSpawn1
@onready var corpse_spawn2 = $Aquarium/CorpseSpawn2
@onready var corpse_spawn3 = $Aquarium/CorpseSpawn3
@onready var corpse_spawn4 = $Aquarium/CorpseSpawn4

var money = 15

func _ready() -> void:
	contract_menu.visible = false
	set_money_label()

func _on_buy_snail_pressed() -> void:
	if money < 5:
		return
	money -= 5
	set_money_label()
	
	var creature = landCreatureScene.instantiate()
	$Aquarium/Creatures.add_child(creature)
	creatures_find_corpses()

func _on_contract_menu_should_spawn_corpse(person_name: Variant, weight: Variant, reward: Variant) -> void:
	# find available spawn
	var spawn_point = null
	if (corpse_spawn1.get_child_count() == 0):
		spawn_point = corpse_spawn1
	elif (corpse_spawn2.get_child_count() == 0):
		spawn_point = corpse_spawn2
	elif (corpse_spawn3.get_child_count() == 0):
		spawn_point = corpse_spawn3
	elif (corpse_spawn4.get_child_count() == 0):
		spawn_point = corpse_spawn4
	if (spawn_point == null):
		return
	
	# spawn corpse
	var new_corpse = corpse_scene.instantiate()
	new_corpse.construct(person_name, weight, reward)
	new_corpse.connect("corpse_eaten", self.corpse_was_eaten)
	spawn_point.add_child(new_corpse)
	
	# make creatures search for target
	creatures_find_corpses()

func corpse_was_eaten(reward):
	money += reward
	set_money_label()
	
	creatures_find_corpses()

func compile_corpse_list():
	var corpse_list = []
	if (corpse_spawn1.get_child_count() != 0):
		corpse_list.push_back(corpse_spawn1.get_child(0))
	elif (corpse_spawn2.get_child_count() != 0):
		corpse_list.push_back(corpse_spawn2.get_child(0))
	elif (corpse_spawn3.get_child_count() != 0):
		corpse_list.push_back(corpse_spawn3.get_child(0))
	elif (corpse_spawn4.get_child_count() != 0):
		corpse_list.push_back(corpse_spawn4.get_child(0))
	return corpse_list
	
func creatures_find_corpses():
	var corpse_list = compile_corpse_list()
	
	for creature in $Aquarium/Creatures.get_children():
		#find closet corpse
		var closet_corpse = null
		for corpse in corpse_list:
			if corpse.eaten:
				continue
			if closet_corpse == null || closet_corpse.position.distance_to(creature.position) > corpse.position.distance_to(creature.position):
				closet_corpse = corpse
		
		if closet_corpse != null:
			creature.set_target(closet_corpse)
		else:
			creature.change_idle_position()

func set_money_label():
	$UI/MoneyLabel.text = "Money: " + str(snappedf(money, 0.01)) + "$"
