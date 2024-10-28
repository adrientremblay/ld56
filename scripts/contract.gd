class_name Contract extends PanelContainer

enum Appearance {THIN, MEDIUM, OBESE}

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

func construct(person_name, weight, reward, female, source, description):
	self.person_name = person_name
	self.weight = weight
	self.reward = reward
	self.female = female
	self.source = source
	self.description = description
	
	if (weight < 140):
		self.appearance = Appearance.THIN
	elif (weight < 180):
		self.appearance = Appearance.MEDIUM
	else:
		self.appearance = Appearance.OBESE
	set_icon_according_to_appearance()
	
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameLabel.text = "Name: " + person_name
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/WeightLabel.text = "Weight: " + str(weight) + "lbs"
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/RewardLabel.text = "Reward: " + str(reward) + "$"
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SourceLabel.text = "Source: " + source
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/DescriptionLabel.text = description

func _on_button_pressed() -> void:
	contract_accepted.emit(self.person_name, self.weight, self.reward, self.appearance, self.female)
	self.queue_free()

func set_icon_according_to_appearance():
	match self.appearance:
		Appearance.THIN:
			if female:
				$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/female_corpse_thin_icon.png")
			else:
				$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/male_corpse_thin_icon.png")
		Appearance.MEDIUM:
			if female:
				$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/female_corpse_medium_icon.png")
			else:
				$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/male_corpse_medium_icon.png")
		Appearance.OBESE:
			if female:
				$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/female_corpse_obese_icon.png")
			else:
				$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = load("res://assets/art/male_corpse_obese_icon.png")
