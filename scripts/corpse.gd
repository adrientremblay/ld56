class_name Corpse extends AnimatedSprite2D

var person_name
var original_weight
var weight
var reward

var eaten = false

@onready var feeding_area: Area2D = $FeedingArea
signal corpse_eaten

func construct(person_name, weight, reward):
	self.person_name = person_name
	self.weight = weight
	self.original_weight = weight
	self.reward = reward

func _process(delta: float) -> void:
	for creature in feeding_area.get_overlapping_bodies():
		weight -= 0.1
	
	if weight <= 0:
		self.eaten = true
		self.queue_free()
		corpse_eaten.emit()
	
	set_decomposition_frame()

func set_decomposition_frame():
	var decomposition_decimal = 1 - (weight / original_weight)
	var frame_float = 6.9999 * decomposition_decimal
	var frame_number = floor(frame_float)
	self.frame = frame_number
