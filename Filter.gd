class_name Filter extends AnimatedSprite2D

static var sponge_filter_sprite_scene : PackedScene = load("res://scenes/sponge_filter.tscn")
static var hang_on_back_filter_sprite_scene : PackedScene = load("res://scenes/hang_on_back_filter.tscn")
static var canister_filter_sprite_scene : PackedScene = load("res://scenes/canister_filter.tscn")
static var sump_filter_sprite_scene : PackedScene = load("res://scenes/sump_filter.tscn")
static var industrial_filter_sprite_scene : PackedScene = load("res://scenes/industrial_filter.tscn")

enum FilterType {SPONGE_FILTER, HANG_ON_BACK_FILTER, CANISTER_FILTER, SUMP_FILTER, INDUSTRIAL_FILTER}

static var PERFORMANCE_GROWTH_PER_SECOND = 0.001

static var filter_stats = {
	FilterType.SPONGE_FILTER: { # 0.001
		"sprite_scene": sponge_filter_sprite_scene,
		"max_performance": 0.01,
		"price": 100,
	},
	FilterType.HANG_ON_BACK_FILTER: { # 0.0005
		"sprite_scene": hang_on_back_filter_sprite_scene,
		"max_performance": 0.05,
		"price": 1000,
	},
	FilterType.CANISTER_FILTER: { # 0.000025
		"sprite_scene": canister_filter_sprite_scene,
		"max_performance": 0.125,
		"price": 5000,
	},
	FilterType.SUMP_FILTER: { # 0.000025
		"sprite_scene": sump_filter_sprite_scene,
		"max_performance": 0.25,
		"price": 10000,
	},
	FilterType.INDUSTRIAL_FILTER: { # 0.000025
		"sprite_scene": industrial_filter_sprite_scene,
		"max_performance": 0.5,
		"price": 20000,
	},
}

var current_performance = 0
var price
var max_performance
var filter_type

func set_type(type: FilterType):
	self.filter_type = type
	self.max_performance = filter_stats[type].max_performance
	self.price = filter_stats[type].price
