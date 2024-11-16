extends Area2D

static var REGULAR_COLOR = Color(1, 1, 1, 1)
static var MODULATE_COLOR = Color(1, 0.5, 1, 1)

var filter: Filter

func _on_mouse_entered() -> void:
	filter.modulate = MODULATE_COLOR

func _on_mouse_exited() -> void:
	filter.modulate = REGULAR_COLOR

func add_filter(filter: Filter):
	self.filter = filter
	add_child(filter)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		print("AnimatedSprite2D clicked!")
