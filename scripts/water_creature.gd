extends Creature

var AQUARIUM_TOP_LEFT_POS : Vector2 = Vector2(101, 124)
var AQUARIUM_WIDTH : float = 1080
var AQUARIUM_HEIGHT : float = 433
var SPAWN_LEFT_VECTOR: Vector2 = Vector2(112.0, 128.0);
var SPAWN_RIGHT_VECTOR: Vector2 = Vector2(1152.0, 128.0);

var target_position: Vector2
var target_corpse: Corpse

func _ready() -> void:
	change_idle_position()
	#self.position = target_position
	self.position = ((SPAWN_RIGHT_VECTOR-SPAWN_LEFT_VECTOR) * randf()) + SPAWN_LEFT_VECTOR

func _physics_process(delta):
	if target_position == null:
		return
	if target_position.distance_to(self.position) < 5:
		if target_corpse == null || target_corpse.eaten:
			$AnimatedSprite2D.play("idle")
		return

	velocity = self.position.direction_to(target_position) * self.speed * 15.0
	move_and_slide()

func change_idle_position() -> void:
	if target_corpse != null && target_corpse.eaten != true:
		return
	
	var random_point = AQUARIUM_TOP_LEFT_POS + Vector2(randf() * AQUARIUM_WIDTH, randf() * AQUARIUM_HEIGHT)

	# Set the movement target to the random point
	set_movement_target(random_point)

func _on_idle_position_timer_timeout() -> void:
	change_idle_position()

func set_target(corpse):
	if self.target_corpse == corpse:
		return # do nothing if the target is already targetted
	
	self.target_corpse = corpse
	
	#finding random spot on the body
	var corpse_body_position = corpse.global_position 
	corpse_body_position.x += (randf() * 2 - 1) * 56
	corpse_body_position.y += (randf() * 2 - 1) * 120
	
	set_movement_target(corpse_body_position)
	
func set_movement_target(target_pos: Vector2):
	self.target_position = target_pos
	var dir = target_position - self.position
	if (dir.x > 0):
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	$AnimatedSprite2D.play("moving")
		
func toggle_bite_sound_timer():
	if $BiteSoundTimer.is_stopped():
		$BiteSoundTimer.start()
	else:
		$BiteSoundTimer.stop()

func _on_bite_sound_timer_timeout() -> void:
	$BiteSound.play()

func _on_nearby_corpse_area_area_entered(area: Area2D) -> void:
	$AnimatedSprite2D.play("eating")

func _on_nearby_corpse_area_area_exited(area: Area2D) -> void:
	$AnimatedSprite2D.play("moving")

func teleport_to_idle_position():
	change_idle_position()
	position = self.target_position
	change_idle_position()
