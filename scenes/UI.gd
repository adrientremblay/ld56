extends Control

@onready var creature_menu: PanelContainer = $CreatureMenu

signal contract_menu_opened

func _ready() -> void:
	creature_menu.visible = false

func _on_creature_button_pressed() -> void:
	creature_menu.visible = !creature_menu.visible

func _on_contract_menu_contract_menu_opened() -> void:
	# close all other UI
	creature_menu.visible = false
	contract_menu_opened.emit()

func _process(delta: float) -> void:
	var time_left = floor($ContractMenu/NewContractTimer.time_left)

	$NextContractLabel.text = "Next Contract: " + str(time_left)
