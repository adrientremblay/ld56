extends Control

@onready var contract_menu: Panel = $ContractMenu
@onready var creature_menu: Panel = $CreatureMenu
@onready var plant_menu: Panel = $PlantMenu
@onready var filter_menu: Panel = $FilterMenu
@onready var item_menu: Panel = $ItemMenu
@onready var assistant: Panel = $Assistant
@onready var contract_button: Button = $ContractMenuButton
@onready var contract_label: Label = $NextContractLabel
@onready var contract_timer: Timer = $ContractMenu/NewContractTimer

signal contract_menu_opened

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	close_all_windows()
	contract_button.visible = false

func _on_contract_menu_contract_menu_opened() -> void:
	# close all other UI
	close_all_windows()
	contract_menu.visible = true
	contract_menu_opened.emit()

func _process(delta: float) -> void:
	var time_left = floor($ContractMenu/NewContractTimer.time_left)
	$NextContractLabel.text = "New Contracts: " + str(time_left)

func _on_close_creature_menu_pressed() -> void:
	creature_menu.visible = false

func _on_close_plant_menu_pressed() -> void:
	plant_menu.visible = false

func _on_close_filter_menu_pressed() -> void:
	filter_menu.visible = false

func _on_creature_button_pressed() -> void:
	if contract_menu.visible:
		return
	
	if creature_menu.visible:
		creature_menu.visible = false
	else:
		close_all_windows()
		creature_menu.visible = !creature_menu.visible

func _on_plants_button_pressed() -> void:
	if contract_menu.visible:
		return
	
	if plant_menu.visible:
		plant_menu.visible = false
	else:
		close_all_windows()
		plant_menu.visible = true

func _on_filters_button_pressed() -> void:
	if contract_menu.visible:
		return
	
	if filter_menu.visible:
		filter_menu.visible = false
	else:
		close_all_windows()
		filter_menu.visible = !filter_menu.visible

func close_all_windows():
	creature_menu.visible = false
	plant_menu.visible = false
	contract_menu.visible = false
	filter_menu.visible = false
	item_menu.visible = false
	assistant.visible = false

func _on_mouse_entered() -> void:
	print("UI mouse")

func _on_new_contract_timer_timeout() -> void:
	contract_label.visible = false
	contract_button.visible = true
	contract_timer.paused = true
	$NewContractsAvailable.play()

func _on_contract_menu_contract_menu_closed() -> void:
	contract_label.visible = true
	contract_button.visible = false
	contract_timer.paused = false

func _on_items_button_pressed() -> void:
	if contract_menu.visible:
		return
	
	if item_menu.visible:
		item_menu.visible = false
	else:
		close_all_windows()
		item_menu.visible = true

func _on_close_item_menu_pressed() -> void:
	item_menu.visible = false
