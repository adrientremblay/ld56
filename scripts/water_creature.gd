extends CharacterBody2D

var WATER_TOP_LEFT_POS :Vector2 = Vector2(81, 106)
var AQUARIUM_Y_VECTOR : Vector2 = Vector2(81, 471)
var AQUARIUM_X_VECTOR : Vector2 = Vector2(1119, 106)

var movement_speed: float = 50.0

var target_position: Vector2

func _ready() -> void:
	change_idle_position()

func _physics_process(delta):
	if target_position == null:
		return

	velocity = self.position.direction_to(target_position) * movement_speed
	move_and_slide()

func change_idle_position() -> void:
	target_position = WATER_TOP_LEFT_POS + (randf()*AQUARIUM_Y_VECTOR) + (randf()*AQUARIUM_X_VECTOR)
