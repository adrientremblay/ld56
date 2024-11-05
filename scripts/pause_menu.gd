extends Panel

var contract_menu_open = false

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") && Dialogic.current_timeline == null && !contract_menu_open:
		pause_game()

func _on_contract_menu_contract_menu_opened() -> void:
	contract_menu_open = true

func _on_contract_menu_contract_menu_closed() -> void:
	contract_menu_open = false

func pause_game():
	get_tree().paused = ! get_tree().paused
	if get_tree().paused && !contract_menu_open:
		self.visible = true
	else:
		self.visible = false
