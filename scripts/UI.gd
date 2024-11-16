extends Control

@onready var contract_menu: Panel = $ContractMenu
@onready var creature_menu: Panel = $CreatureMenu
@onready var plant_menu: Panel = $PlantMenu
@onready var filter_menu: Panel = $FilterMenu

signal contract_menu_opened

func _ready() -> void:
	creature_menu.visible = false
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	close_all_windows()

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


func _on_mouse_entered() -> void:
	print("UI mouse")
