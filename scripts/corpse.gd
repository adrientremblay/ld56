class_name Corpse extends AnimatedSprite2D

var person_name
var original_weight
var weight
var reward
var female

var eaten = false
var appearance: Contract.Appearance

@onready var feeding_area: Area2D = $FeedingArea
signal corpse_eaten(reward)

func construct(person_name, weight, reward, appearance: Contract.Appearance, female: bool):
	self.person_name = person_name
	self.weight = weight
	self.original_weight = weight
	self.reward = reward
	self.appearance = appearance
	self.female = female
	
	match self.appearance:
		Contract.Appearance.LIGHT:
			if self.female:
				self.animation = "female thin"
			else:
				self.animation = "male thin"
		Contract.Appearance.MEDIUM:
			if self.female:
				self.animation = "female medium"
			else:
				self.animation = "male medium"
		Contract.Appearance.HEAVY || Contract.Appearance.OBESE:
			if self.female:
				self.animation = "female obese"
			else:
				self.animation = "male obese"

func _process(delta: float) -> void:
	if weight <= 0:
		self.eaten = true
		self.queue_free()
		corpse_eaten.emit(reward)
	
	set_decomposition_frame()

func set_decomposition_frame():
	var decomposition_decimal = 1 - (weight / original_weight)
	var frame_float = 9.9999 * decomposition_decimal
	var frame_number = floor(frame_float)
	self.frame = frame_number
	
	$DecompositionBar.value = (weight / original_weight) * 100.0

func _on_feeding_area_body_entered(body: Node2D) -> void:
	body.toggle_bite_sound_timer()

func _on_feeding_area_body_exited(body: Node2D) -> void:
	body.toggle_bite_sound_timer()
	
