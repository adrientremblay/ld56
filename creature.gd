class_name Creature extends CharacterBody2D

enum Species {SNAIL, CRAB, FISH}

func set_species(species: Species):
	match species:
		Species.SNAIL:
			$Sprite2D.texture = load("res://assets/art/assassin_snail.png")
		Species.CRAB:
			$Sprite2D.texture = load("res://assets/art/crab.png")
