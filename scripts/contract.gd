class_name Contract extends PanelContainer

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

	$MarginContainer/HBoxContainer/VBoxContainer/NameLabel.text = "Name: " + person_name
	$MarginContainer/HBoxContainer/VBoxContainer/WeightLabel.text = "Name: " + str(weight) + "lbs"
	$MarginContainer/HBoxContainer/VBoxContainer/RewardLabel.text = "Reward: " + str(reward) + "$"

func _on_button_pressed() -> void:
	contract_accepted.emit(self.person_name, self.weight, self.reward)
	self.queue_free()
