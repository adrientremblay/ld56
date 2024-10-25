extends Control

func _ready() -> void:
	self.visible = false

func open(level_number: String, tagline: String, quota: String, bonus: String):
	$LevelLabel.text = "Level " + level_number
	$TaglineLabel.text = tagline
	$QuotaLabel.text = "Quota: " + quota + " bodies"
	if bonus != "":
		$BonusLabel.text = "You received a bonus of " + bonus + "$ for closing early."
	else:
		$BonusLabel.text = "You did not receive a bonus."
	
