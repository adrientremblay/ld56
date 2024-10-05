extends CharacterBody2D

var movement_speed: float = 50.0
var movement_target_position: Vector2 = Vector2(60.0,180.0)

var IDLE_LAND_LEFT_VECTOR: Vector2 = Vector2(68.0, 638.0);
var IDLE_LAND_RIGHT_VECTOR: Vector2 = Vector2(1206.0, 638.0);
var TARGET_POSITION_VECTOR = IDLE_LAND_RIGHT_VECTOR - IDLE_LAND_LEFT_VECTOR;

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	actor_setup.call_deferred()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()

func _on_idle_position_timer_timeout() -> void:
	var r = randf()
	var target_pos = (TARGET_POSITION_VECTOR * r) + IDLE_LAND_LEFT_VECTOR
	set_movement_target(target_pos)