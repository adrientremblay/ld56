class_name Creature extends CharacterBody2D

enum Species {SNAIL, CRAB, KILLIFISH, PIRANHA, ANGLERFISH, DRAGONFISH, GOBLINSHARK, LOBSTER, OCTOPUS, TURTLE}

var snail_sprite_scene : PackedScene = load("res://scenes/snail_sprite.tscn")
var crab_sprite_scene : PackedScene = load("res://scenes/crab_sprite.tscn")
var killifish_sprite_scene : PackedScene = load("res://scenes/killifish_sprite.tscn")
var piranha_sprite_scene : PackedScene = load("res://scenes/piranha_sprite.tscn")
var anglerfish_sprite_scene : PackedScene = load("res://scenes/anglerfish_sprite.tscn")
var dragonfish_sprite_scene : PackedScene = load("res://scenes/dragonfish_sprite.tscn")
var goblinshark_sprite_scene : PackedScene = load("res://scenes/goblinshark_sprite.tscn")
var lobster_sprite_scene : PackedScene = load("res://scenes/lobster_sprite.tscn")
var octopus_sprite_scene : PackedScene = load("res://scenes/octopus_sprite.tscn")
var turtle_sprite_scene : PackedScene = load("res://scenes/turtle_sprite.tscn")

var price
var damage
var speed

# The value per dollar (VPD) of a creature it it's (damange * speed) / price
func set_species(species: Species):
	var sprite
	match species:
		Species.SNAIL: # vpd = 0.5
			sprite = snail_sprite_scene.instantiate()
			self.price = 5
			self.damage = 2.5
			self.speed = 1
		Species.CRAB: #vpd = 0.8
			sprite = crab_sprite_scene.instantiate()
			self.price = 25
			self.damage = 8
			self.speed = 2.5
		Species.LOBSTER: # vpd = 1.0
			sprite = lobster_sprite_scene.instantiate()
			self.price = 50
			self.damage = 25
			self.speed = 2
		Species.OCTOPUS: # vpd = 1.75
			sprite = octopus_sprite_scene.instantiate()
			self.price = 300
			self.damage = 150
			self.speed = 3.5
		Species.TURTLE: #vpd = 2.8
			sprite = turtle_sprite_scene.instantiate()
			self.price = 500
			self.damage = 700
			self.speed = 2
		Species.KILLIFISH: # vpd = 0.5
			sprite = killifish_sprite_scene.instantiate()
			self.price = 5
			self.damage = 1
			self.speed = 2.5
		Species.PIRANHA: # vpd = 0.8
			sprite = piranha_sprite_scene.instantiate()
			self.price = 25
			self.damage = 4
			self.speed = 5
		Species.ANGLERFISH: # vpd = 1.0
			sprite = anglerfish_sprite_scene.instantiate()
			self.price = 50
			self.damage = 12.5
			self.speed = 4
		Species.DRAGONFISH: # vpd = 1.75
			sprite = dragonfish_sprite_scene.instantiate()
			self.price = 300
			self.damage = 75
			self.speed = 7
		Species.GOBLINSHARK: # vpd = 2.8
			sprite = goblinshark_sprite_scene.instantiate()
			self.price = 500
			self.damage = 350
			self.speed = 4
	add_child(sprite)
