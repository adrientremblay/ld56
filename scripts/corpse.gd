class_name Corpse extends AnimatedSprite2D

var person_name
var weight
var reward

@onready var feeding_area: Area2D = $FeedingArea

func construct(person_name, weight, reward):
	self.person_name = person_name
	self.weight = weight
	self.reward = reward

func _process(delta: float) -> void:
	for creature in feeding_area.get_overlapping_bodies():
		weight -= 0.1
		print("SUBTRACTING WEIGHT: " + str(weight))
