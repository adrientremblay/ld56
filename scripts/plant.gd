class_name Plant extends AnimatedSprite2D

static var sword_plant_sprite_scene : PackedScene = load("res://scenes/sword_plant.tscn")
static var stem_plant_sprite_scene : PackedScene = load("res://scenes/stem_plant.tscn")
static var eelgrass_sprite_scene : PackedScene = load("res://scenes/eelgrass.tscn")
static var water_lettuce_scene : PackedScene = load("res://scenes/waterlettuce.tscn")
static var giant_anubias_scene : PackedScene = load("res://scenes/giant_anubias.tscn")

enum PlantType {SWORD_PLANT, STEM_PLANT, EELGRASS, WATER_LETTUCE, GIANT_ANUBIAS}

static var SURFACE_POSITION_LEFT = Vector2i(160, 102)
static var BOTTOM_POSITION_LEFT = Vector2i(160, 615)
static var AQUARIUM_WIDTH = 960

static var plant_stats = {
	PlantType.SWORD_PLANT: { # 0.00003
		"sprite_scene": sword_plant_sprite_scene,
		"performance": 0.0025,
		"price": 10,
		"floating": false,
	},
	PlantType.STEM_PLANT: { # 0.00005
		"sprite_scene": stem_plant_sprite_scene,
		"performance": 0.005,
		"price": 20,
		"floating": false,
	},
	PlantType.EELGRASS: { # 0.00008
		"sprite_scene": eelgrass_sprite_scene,
		"performance": 0.01,
		"price": 50,
		"floating": false,
	},
	PlantType.WATER_LETTUCE: { # 0.000125
		"sprite_scene": water_lettuce_scene,
		"performance": 0.02,
		"price": 100,
		"floating": true,
	},
	PlantType.GIANT_ANUBIAS: { # 0.00016
		"sprite_scene": giant_anubias_scene,
		"performance": 0.05,
		"price": 200,
		"floating": false,
	},
}

var performance
var type: PlantType
var floating: bool

func set_type(type: PlantType):
	self.type = type
	self.performance = plant_stats[type].performance
	self.floating = plant_stats[type].floating

func random_position():
	var left_position: Vector2i
	if self.floating:
		left_position = SURFACE_POSITION_LEFT
	else:
		left_position = BOTTOM_POSITION_LEFT
	
	self.global_position = left_position + Vector2i(randf() * AQUARIUM_WIDTH, 0)
