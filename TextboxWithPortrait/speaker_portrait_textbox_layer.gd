@tool
extends DialogicLayoutLayer

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

## Handle mouse input
func _input(event: InputEvent) -> void:
	DialogicUtil.autoload().Inputs.handle_node_gui_input(event)
