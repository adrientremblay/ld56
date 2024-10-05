extends Node2D

@export var landCreatureScene: PackedScene
@onready var contract_menu = $UI/ContractMenu

func _ready() -> void:
	contract_menu.visible = false

func _on_buy_snail_pressed() -> void:
	var creature = landCreatureScene.instantiate()
	self.add_child(creature)
