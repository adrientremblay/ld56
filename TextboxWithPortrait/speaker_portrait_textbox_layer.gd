@tool
extends DialogicLayoutLayer

## Handle mouse input
func _input(event: InputEvent) -> void:
	DialogicUtil.autoload().Inputs.handle_node_gui_input(event)
