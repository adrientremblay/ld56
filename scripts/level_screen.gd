extends Control

signal level_screen_closed() 

func _ready() -> void:
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func open(level_number: int, tagline: String, quota: int, bonus: int, penalty: int):
	self.visible = true
	$LevelLabel.text = "Level " + str(level_number)
	$TaglineLabel.text = tagline
	$QuotaLabel.text = "Quota: " + str(quota) + " bodies"
	if bonus != 0:
		$BonusLabel.text = "You received a bonus of " + str(bonus) + "$ for closing early."
	else:
		$BonusLabel.text = "You did not receive a bonus."
	
	if penalty != 0:
		$PenaltyLabel.text = "You were penalized " + str(penalty) + "$ for failing to dispose of all bodies."
	else:
		$PenaltyLabel.text = "You were not penalized."

func _on_continue_button_pressed() -> void:
	level_screen_closed.emit()
	self.visible = false