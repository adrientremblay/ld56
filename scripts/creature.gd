class_name Creature extends CharacterBody2D

static var snail_sprite_scene : PackedScene = load("res://scenes/snail_sprite.tscn")
static var crab_sprite_scene : PackedScene = load("res://scenes/crab_sprite.tscn")
static var killifish_sprite_scene : PackedScene = load("res://scenes/killifish_sprite.tscn")
static var piranha_sprite_scene : PackedScene = load("res://scenes/piranha_sprite.tscn")
static var anglerfish_sprite_scene : PackedScene = load("res://scenes/anglerfish_sprite.tscn")
static var dragonfish_sprite_scene : PackedScene = load("res://scenes/dragonfish_sprite.tscn")
static var goblinshark_sprite_scene : PackedScene = load("res://scenes/goblinshark_sprite.tscn")
static var lobster_sprite_scene : PackedScene = load("res://scenes/lobster_sprite.tscn")
static var octopus_sprite_scene : PackedScene = load("res://scenes/octopus_sprite.tscn")
static var turtle_sprite_scene : PackedScene = load("res://scenes/turtle_sprite.tscn")

enum Species {SNAIL, CRAB, KILLIFISH, PIRANHA, ANGLERFISH, DRAGONFISH, GOBLINSHARK, LOBSTER, OCTOPUS, TURTLE}

enum NitrogenTolerance {LOW, MODERATE, HIGH}

# The value per dollar (VPD) of a creature it it's (damange * speed) / price
static var species_stats = {
	Species.SNAIL: { #vpd=2.5
		"sprite_scene": snail_sprite_scene,
		"price": 100,
		"damage": 2.5,
		"speed": 1,
		"bioload": 0.001,
		"nitrogen_tolerance": NitrogenTolerance.LOW
	},
	Species.CRAB: { #vpd=20
		"sprite_scene": crab_sprite_scene,
		"price": 500,
		"damage": 8,
		"speed": 2.5,
		"bioload": 0.005,
		"nitrogen_tolerance": NitrogenTolerance.MODERATE
	},
	Species.LOBSTER: { #vpd=50
		"sprite_scene": lobster_sprite_scene,
		"price": 1000,
		"damage": 25,
		"speed": 2,
		"bioload": 0.01,
		"nitrogen_tolerance": NitrogenTolerance.HIGH
	},
	Species.OCTOPUS: { #vpd=1.75
		"sprite_scene": octopus_sprite_scene,
		"price": 5000,
		"damage": 150,
		"speed": 3.5,
		"bioload": 0.06,
		"nitrogen_tolerance": NitrogenTolerance.LOW
	},
	Species.TURTLE: { #vpd=2.8
		"sprite_scene": turtle_sprite_scene,
		"price": 10000,
		"damage": 700,
		"speed": 2,
		"bioload": 0.12,
		"nitrogen_tolerance": NitrogenTolerance.HIGH
	},
	Species.KILLIFISH: { # vpd=0.025
		"sprite_scene": killifish_sprite_scene,
		"price": 100,
		"damage": 1,
		"speed": 2.5,
		"bioload": 0.001,
		"nitrogen_tolerance": NitrogenTolerance.HIGH
	},
	Species.PIRANHA: { #vpd=0.04
		"sprite_scene": piranha_sprite_scene,
		"price": 500,
		"damage": 4,
		"speed": 5,
		"bioload": 0.005,
		"nitrogen_tolerance": NitrogenTolerance.MODERATE
	},
	Species.ANGLERFISH: { #vpd=0.05
		"sprite_scene": anglerfish_sprite_scene,
		"price": 1000,
		"damage": 12.5,
		"speed": 4,
		"bioload": 0.01,
		"nitrogen_tolerance": NitrogenTolerance.HIGH
	},
	Species.DRAGONFISH: { #vpd=0.105
		"sprite_scene": dragonfish_sprite_scene,
		"price": 5000,
		"damage": 75,
		"speed": 7,
		"bioload": 0.06,
		"nitrogen_tolerance": NitrogenTolerance.LOW
	},
	Species.GOBLINSHARK: { #vpd=0.14
		"sprite_scene": goblinshark_sprite_scene,
		"price": 10000,
		"damage": 350,
		"speed": 4,
		"bioload": 0.12,
		"nitrogen_tolerance": NitrogenTolerance.LOW
	}
}

static var CREATURE_HEALING_RATE = 5.0 # per second

var species
var price
var damage
var speed
var bioload
var sprite
var nitrogen_coefficient 
var health = 100.0

func set_species(species: Species):
	self.species = species
	self.price = species_stats[species].price
	self.damage = species_stats[species].damage
	self.speed = species_stats[species].speed
	self.bioload = species_stats[species].bioload
	
	match species_stats[species].nitrogen_tolerance:
		NitrogenTolerance.LOW:
			self.nitrogen_coefficient = 1.0
		NitrogenTolerance.MODERATE:
			self.nitrogen_coefficient = 0.7
		NitrogenTolerance.HIGH:
			self.nitrogen_coefficient = 0.5
			
	self.sprite = species_stats[species].sprite_scene.instantiate()
	add_child(self.sprite)

func update_health_bar() -> void:
	var healthbar: ProgressBar = $AnimatedSprite2D/HealthBar
	healthbar.value = health

static func is_species_land_based(species: Creature.Species) -> bool:
	if species == Creature.Species.SNAIL || species == Creature.Species.CRAB || species == Creature.Species.LOBSTER || species == Creature.Species.OCTOPUS || species == Creature.Species.TURTLE:
			return true
	return false
