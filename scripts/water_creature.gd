extends Creature

var WATER_TOP_LEFT_POS :Vector2 = Vector2(81, 106)
var AQUARIUM_Y_VECTOR : Vector2 = Vector2(81, 471)
var AQUARIUM_X_VECTOR : Vector2 = Vector2(1119, 106)

var movement_speed: float = 150.0

var target_position: Vector2
var target_corpse: Corpse

func _ready() -> void:
	change_idle_position()
	self.position = target_position

func _physics_process(delta):
	if target_position == null:
		return
	if target_position.distance_to(self.position) < 5:
		return

	velocity = self.position.direction_to(target_position) * movement_speed
	move_and_slide()

func change_idle_position() -> void:
	if target_corpse != null && target_corpse.eaten != true:
		return
	
	set_movement_target(WATER_TOP_LEFT_POS + (randf()*AQUARIUM_Y_VECTOR) + (randf()*AQUARIUM_X_VECTOR))

func _on_idle_position_timer_timeout() -> void:
	change_idle_position()

func set_target(corpse):
	self.target_corpse = corpse
	set_movement_target(corpse.global_position)
	
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
