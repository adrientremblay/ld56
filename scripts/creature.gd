class_name Creature extends CharacterBody2D

enum Species {SNAIL, CRAB, KILLIFISH, PIRANHA, ANGLERFISH, DRAGONFISH, GOBLINSHARK}

var snail_sprite_scene : PackedScene = load("res://scenes/snail_sprite.tscn")
var crab_sprite_scene : PackedScene = load("res://scenes/crab_sprite.tscn")
var killifish_sprite_scene : PackedScene = load("res://scenes/killifish_sprite.tscn")
var piranha_sprite_scene : PackedScene = load("res://scenes/piranha_sprite.tscn")
var anglerfish_sprite_scene : PackedScene = load("res://scenes/anglerfish_sprite.tscn")
var dragonfish_sprite_scene : PackedScene = load("res://scenes/dragonfish_sprite.tscn")
var goblinshark_sprite_scene : PackedScene = load("res://scenes/goblinshark_sprite.tscn")

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
		Species.PIRANHA:
			sprite = piranha_sprite_scene.instantiate()
			self.damage = 5
		Species.ANGLERFISH:
			sprite = anglerfish_sprite_scene.instantiate()
			self.damage = 5
		Species.DRAGONFISH:
			sprite = dragonfish_sprite_scene.instantiate()
			self.damage = 5
		Species.GOBLINSHARK:
			sprite = goblinshark_sprite_scene.instantiate()
			self.damage = 20
	add_child(sprite)
