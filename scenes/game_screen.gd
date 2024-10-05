extends Node2D

@export var landCreatureScene: PackedScene
@onready var contract_menu = $UI/ContractMenu
@onready var corpse_spawn1 = $Aquarium/CorpseSpawn1
@onready var corpse_spawn2 = $Aquarium/CorpseSpawn2
@onready var corpse_spawn3 = $Aquarium/CorpseSpawn3
@onready var corpse_spawn4 = $Aquarium/CorpseSpawn4

func _ready() -> void:
	contract_menu.visible = false

func _on_buy_snail_pressed() -> void:
	var creature = landCreatureScene.instantiate()
	self.add_child(creature)

func _on_contract_menu_should_spawn_corpse(person_name: Variant, weight: Variant, reward: Variant) -> void:
	#find available spawn
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
	
	#asdf
