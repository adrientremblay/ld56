class_name Contract extends PanelContainer

enum Appearance {THIN, MEDIUM, OBESE}

var appearance: Appearance

var person_name
var weight
var reward
var female

var organizations = [
	{
		"name" : "PureGenus",
		"description1" : "They believe that the average human genetic composition has become inferior",
		"description2" : "Kidnap people they believe have inferior genes and forcefully sterilise them. There are often fatalities in the struggle",
		"description3" : "There is a heavy racial bias in determining if an individual is 'inferior' or not",
		"karma" : -0.3
	},
	{
		"name" : "Blackstone Pharmaceuticals",
		"description1" : "Performs human experiments on people",
		"description2" : "Sells drugs at exorbitant markups",
		"description3" : "Markets unnecessary drugs to vulnerable groups of people",
		"karma" : -0.2
	},
	{
		"name" : "The Reclamation Network",
		"description1" : "Anonymously donate organs to hospitals around the globe ultimately saving lives",
		"description2" : "Secretly sources their organs from proven rapists and pedophiles both in and out of prison",
		"description3" : "Comprised primarily by ex law enforcement",
		"karma" : 0.2
	},
	{
		"name" : "Project Horizon",
		"description1" : "Performs experimental treatments on willing volunteers who are infected with fatal diseases",
		"description2" : "Their activity is illegal",
		"description3" : "Wish to dispose of bodies to avoid detection and public scrutiny",
		"karma" : 0.3
	},
]

@onready var name_label : Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameLabel
@onready var weight_label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/WeightLabel
@onready var reward_label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/RewardLabel

signal contract_accepted(person_name, weight, reward, appearance, female)

func construct(person_name, weight, reward, female):
	self.person_name = person_name
	self.weight = weight
	self.reward = reward
	self.female = female
	
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
