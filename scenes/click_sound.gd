extends AudioStreamPlayer

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dialogic_default_action"):
		self.play()
