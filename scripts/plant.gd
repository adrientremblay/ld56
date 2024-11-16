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
	PlantType.SWORD_PLANT: {
		"sprite_scene": sword_plant_sprite_scene,
		"performance": 0.01,
		"price": 15,
		"floating": false,
	},
	PlantType.STEM_PLANT: {
		"sprite_scene": stem_plant_sprite_scene,
		"performance": 0.01,
		"price": 25,
		"floating": false,
	},
	PlantType.EELGRASS: {
		"sprite_scene": eelgrass_sprite_scene,
		"performance": 0.01,
		"price": 40,
		"floating": false,
	},
	PlantType.WATER_LETTUCE: {
		"sprite_scene": water_lettuce_scene,
		"performance": 0.01,
		"price": 60,
		"floating": true,
	},
	PlantType.GIANT_ANUBIAS: {
		"sprite_scene": giant_anubias_scene,
		"performance": 0.01,
		"price": 80,
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
