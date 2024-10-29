class_name Creature extends CharacterBody2D

enum Species {SNAIL, CRAB, KILLIFISH}

var snail_sprite_scene : PackedScene = load("res://scenes/snail_sprite.tscn")
var crab_sprite_scene : PackedScene = load("res://scenes/crab_sprite.tscn")
var killifish_sprite_scene : PackedScene = load("res://scenes/killifish_sprite.tscn")

var damage
var speed

func set_species(species: Species):
	var sprite
	match species:
		Species.SNAIL:
			sprite = snail_sprite_scene.instantiate()
			self.damage = 2
		Species.CRAB:
			sprite = crab_sprite_scene.instantiate()
			self.damage = 5
		Species.KILLIFISH:
			sprite = killifish_sprite_scene.instantiate()
			self.damage = 3
	add_child(sprite)
