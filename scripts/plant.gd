class_name Plant extends AnimatedSprite2D

static var sponge_filter_sprite_scene : PackedScene = load("res://scenes/sponge_filter.tscn")
static var hang_on_back_filter_sprite_scene : PackedScene = load("res://scenes/hang_on_back_filter.tscn")
static var canister_filter_sprite_scene : PackedScene = load("res://scenes/canister_filter.tscn")
static var sump_filter_sprite_scene : PackedScene = load("res://scenes/sump_filter.tscn")
static var industrial_filter_sprite_scene : PackedScene = load("res://scenes/industrial_filter.tscn")

enum FilterType {SPONGE_FILTER, HANG_ON_BACK_FILTER, CANISTER_FILTER, SUMP_FILTER, INDUSTRIAL_FILTER}

static var PERFORMANCE_GROWTH_PER_SECOND = 0.1

static var filter_stats = {
	FilterType.SPONGE_FILTER: {
		"sprite_scene": sponge_filter_sprite_scene,
		"max_performance": 0.1,
		"price": 15,
	},
	FilterType.HANG_ON_BACK_FILTER: {
		"sprite_scene": hang_on_back_filter_sprite_scene,
		"max_performance": 1,
		"price": 40,
	},
	FilterType.CANISTER_FILTER: {
		"sprite_scene": canister_filter_sprite_scene,
		"max_performance": 2,
		"price": 100,
	},
	FilterType.SUMP_FILTER: {
		"sprite_scene": sump_filter_sprite_scene,
		"max_performance": 5,
		"price": 200,
	},
	FilterType.INDUSTRIAL_FILTER: {
		"sprite_scene": industrial_filter_sprite_scene,
		"max_performance": 10,
		"price": 500,
	},
}

var current_performance = 0
var max_performance
var filter_type

func set_type(type: FilterType):
	self.filter_type = type
	self.max_performance = filter_stats[type].max_performance
