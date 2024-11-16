extends Button

@export var plant_type: Plant.PlantType

signal spawn_plant(type: Plant.PlantType)

func _on_pressed() -> void:
	spawn_plant.emit(self.plant_type)
