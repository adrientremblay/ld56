class_name Contract extends PanelContainer

enum Appearance {THIN, MEDIUM, OBESE}
var appearance: Appearance

var person_name
var weight
var reward

@onready var name_label : Label = $MarginContainer/HBoxContainer/VBoxContainer/NameLabel
@onready var weight_label = $MarginContainer/HBoxContainer/VBoxContainer/WeightLabel
@onready var reward_label = $MarginContainer/HBoxContainer/VBoxContainer/RewardLabel

signal contract_accepted(person_name, weight, reward)

func construct(person_name, weight, reward):
	self.person_name = person_name
	self.weight = weight
	self.reward = reward
	
	if (weight < 140):
		self.appearance = Appearance.THIN
	elif (weight < 180):
		self.appearance = Appearance.MEDIUM
	else:
		self.appearance = Appearance.OBESE
	set_icon_according_to_appearance()
	
	$MarginContainer/HBoxContainer/VBoxContainer/NameLabel.text = "Name: " + person_name
	$MarginContainer/HBoxContainer/VBoxContainer/WeightLabel.text = "Weight: " + str(weight) + "lbs"
	$MarginContainer/HBoxContainer/VBoxContainer/RewardLabel.text = "Reward: " + str(reward) + "$"

func _on_button_pressed() -> void:
	contract_accepted.emit(self.person_name, self.weight, self.reward)
	self.queue_free()

func set_icon_according_to_appearance():
	match self.appearance:
		Appearance.THIN:
			$MarginContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/male_corpse_thin_icon.png")
		Appearance.MEDIUM:
			$MarginContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/male_corpse_medium_icon.png")
		Appearance.MEDIUM:
			$MarginContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/male_corpse_medium_icon.png")
