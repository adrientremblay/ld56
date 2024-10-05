extends Node2D

@export var landCreatureScene: PackedScene
@export var corpse_scene: PackedScene

@onready var contract_menu = $UI/ContractMenu
@onready var corpse_spawn1 = $Aquarium/CorpseSpawn1
@onready var corpse_spawn2 = $Aquarium/CorpseSpawn2
@onready var corpse_spawn3 = $Aquarium/CorpseSpawn3
@onready var corpse_spawn4 = $Aquarium/CorpseSpawn4

var corpse_list = []
var creatures_list = []

func _ready() -> void:
	contract_menu.visible = false

func _on_buy_snail_pressed() -> void:
	var creature = landCreatureScene.instantiate()
	self.add_child(creature)
	creatures_list.push_back(creature)

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
	spawn_point.add_child(new_corpse)
	corpse_list.push_back(new_corpse)
	
	# make creatures search for target
	creatures_find_corpses()
	
func creatures_find_corpses():
	for creature in creatures_list:
		#find closet corpse
		var closet_corpse = null
		for corpse in corpse_list:
			if closet_corpse == null || closet_corpse.position.distance_to(creature.position) > corpse.position.distance_to(creature.position):
				closet_corpse = corpse
		
		if closet_corpse != null:
			creature.set_target(closet_corpse)
