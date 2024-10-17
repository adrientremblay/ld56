class_name Creature extends CharacterBody2D

enum Species {SNAIL, CRAB, FISH}

var damage
var speed

func set_species(species: Species):
	match species:
		Species.SNAIL:
			$Sprite2D.texture = load("res://assets/art/assassin_snail.png")
			self.damage = 2
		Species.CRAB:
			$Sprite2D.texture = load("res://assets/art/crab.png")
			self.damage = 5
