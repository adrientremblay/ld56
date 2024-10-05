class_name Corpse extends AnimatedSprite2D

var person_name
var weight
var reward

func construct(person_name, weight, reward):
	self.person_name = person_name
	self.weight = weight
	self.reward = reward
