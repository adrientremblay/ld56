extends Node2D

@export var landCreatureScene: PackedScene

func _on_buy_snail_pressed() -> void:
	var creature = landCreatureScene.instantiate()
	self.add_child(creature)
