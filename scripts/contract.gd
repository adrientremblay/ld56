class_name Contract extends PanelContainer

enum Appearance {LIGHT, MEDIUM, HEAVY, OBESE}

var appearance: Appearance

var person_name
var weight
var reward
var female
var source
var description

@onready var name_label : Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameLabel
@onready var weight_label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/WeightLabel
@onready var reward_label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/RewardLabel

signal contract_accepted(person_name, weight, reward, appearance, female, description)

func construct(person_name, weight, reward, female, weight_type: Appearance, description):
	self.person_name = person_name
	self.weight = weight
	self.reward = reward
	self.female = female
	self.description = description
	
	self.appearance = appearance
	set_icon_according_to_appearance()
	
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameLabel.text = "Name: " + person_name
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/WeightLabel.text = "Weight: " + str(weight) + "lbs"
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/RewardLabel.text = "Reward: " + ("%.2f" % reward) + "$"
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SizeLabel.text = "Size: " + str(Appearance.keys()[weight_type])
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/DescriptionLabel.text = "Description: " + description

func _on_button_pressed() -> void:
	contract_accepted.emit(self.person_name, self.weight, self.reward, self.appearance, self.female)
	self.queue_free()

func set_icon_according_to_appearance():
	match self.appearance:
		Appearance.LIGHT:
			if female:
				$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/female_corpse_thin_icon.png")
			else:
				$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/male_corpse_thin_icon.png")
		Appearance.MEDIUM:
			if female:
				$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/female_corpse_medium_icon.png")
			else:
				$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/male_corpse_medium_icon.png")
		Appearance.HEAVY || Appearance.OBESE:
			if female:
				$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/female_corpse_obese_icon.png")
			else:
				$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/male_corpse_obese_icon.png")
