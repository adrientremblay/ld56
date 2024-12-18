extends Creature

var IDLE_LAND_LEFT_VECTOR: Vector2 = Vector2(112.0, 608.0);
var IDLE_LAND_RIGHT_VECTOR: Vector2 = Vector2(1152.0, 608.0);
var TARGET_POSITION_VECTOR = IDLE_LAND_RIGHT_VECTOR - IDLE_LAND_LEFT_VECTOR;

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var target_corpse: Corpse

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	actor_setup.call_deferred()
	
	var r = randf()
	var target_pos = (TARGET_POSITION_VECTOR * r) + IDLE_LAND_LEFT_VECTOR
	self.position = target_pos

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	change_idle_position()

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target
	#going to do the changing of the sprite rotation and flipping here bcuz the floor is flat
	var dir = movement_target - self.position
	if (dir.x > 0):
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * self.speed * 15.0
	move_and_slide()

func _on_idle_position_timer_timeout() -> void:
	change_idle_position()

func change_idle_position() -> void:
	if target_corpse != null && target_corpse.eaten != true:
		return
	
	var r = randf()
	var target_pos = (TARGET_POSITION_VECTOR * r) + IDLE_LAND_LEFT_VECTOR
	
	set_movement_target(target_pos)
	
	sprite.play("moving")

func set_target(corpse):
	if (self.target_corpse == corpse):
		return # do nothing if the target is already targetted
	
	self.target_corpse = corpse
	
	#finding random spot on the body
	var corpse_body_position = corpse.global_position 
	corpse_body_position.x += (randf() * 2 - 1) * 56
	corpse_body_position.y += (randf() * 2 - 1) * 120
	
	set_movement_target(corpse_body_position)
	
	sprite.play("moving")
	
func toggle_bite_sound_timer():
	if $BiteSoundTimer.is_stopped():
		$BiteSoundTimer.start()
	else:
		$BiteSoundTimer.stop()

func _on_bite_sound_timer_timeout() -> void:
	$BiteSound.play()

func _on_nearby_corpse_area_area_entered(area: Area2D) -> void:
	sprite.play("eating")

func _on_nearby_corpse_area_area_exited(area: Area2D) -> void:
	sprite.play("moving")

func _on_navigation_agent_2d_navigation_finished() -> void:
	if target_corpse == null || target_corpse.eaten:
		sprite.play("idle")

func teleport_to_idle_position():
	change_idle_position()
	position = navigation_agent.target_position
	change_idle_position()
