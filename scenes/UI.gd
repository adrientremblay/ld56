extends Control

@onready var creature_menu: PanelContainer = $CreatureMenu

func _ready() -> void:
	creature_menu.visible = false

func _on_creature_button_pressed() -> void:
	creature_menu.visible = !creature_menu.visible
