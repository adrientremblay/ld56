extends Node2D

@export var landCreatureScene: PackedScene
@onready var contract_menu = $UI/ContractMenu

func _ready() -> void:
	contract_menu.visible = false

func _on_buy_snail_pressed() -> void:
	var creature = landCreatureScene.instantiate()
	self.add_child(creature)


func _on_contract_menu_should_spawn_corpse(person_name: Variant, weight: Variant, reward: Variant) -> void:
	print("Spawn corpse!")
