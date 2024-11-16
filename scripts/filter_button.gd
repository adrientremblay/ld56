extends Button

@export var filter_type: Filter.FilterType

signal spawn_filter(filter: Filter.FilterType)

func _on_pressed() -> void:
	spawn_filter.emit(self.filter_type)
