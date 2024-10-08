extends Control

@onready var creature_menu: Panel = $CreatureMenu

signal contract_menu_opened

func _ready() -> void:
	creature_menu.visible = false

func _on_creature_button_pressed() -> void:
	creature_menu.visible = !creature_menu.visible

func _on_contract_menu_contract_menu_opened() -> void:
	# close all other UI
	creature_menu.visible = false
	$PlantMenu.visible = false
	contract_menu_opened.emit()

func _process(delta: float) -> void:
	var time_left = floor($ContractMenu/NewContractTimer.time_left)

	$NextContractLabel.text = "New Contracts: " + str(time_left)

func _on_close_creature_menu_pressed() -> void:
	creature_menu.visible = false

func _on_close_plant_menu_pressed() -> void:
	$PlantMenu.visible = false

func _on_plants_button_pressed() -> void:
	$PlantMenu.visible = ! $PlantMenu.visible

func close_all_windows():
	$CreatureMenu.visible = false
	$PlantMenu.visible = false
	$ContractMenu.visible = false
