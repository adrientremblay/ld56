extends Panel

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") && Dialogic.current_timeline == null:
		get_tree().paused = ! get_tree().paused
		if get_tree().paused:
			self.visible = true
		else:
			self.visible = false
