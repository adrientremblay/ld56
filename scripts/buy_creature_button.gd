extends Button

@export var species: Creature.Species

signal spawn_species(species: Creature.Species)

func _on_pressed() -> void:
	spawn_species.emit(self.species)
