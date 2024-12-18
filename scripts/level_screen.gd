extends Control

signal level_screen_closed() 

func _ready() -> void:
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func open(level_number: int, quota: int, bonus: int, penalty: int, timeout: int, money: int):
	self.visible = true
	$CurrentMoneyValue.text = str(money) + "$"
	$MoneyValue.text = str(100000 - money) + "$"
	$LevelLabel.text = "Day " + str(level_number)
	$ContractWaitTimeValue.text = str(timeout) + " seconds"
	$QuotaValue.text = str(quota) + (" corpses" if quota > 1 else " corpse")
	$BonusValue.text = str(bonus) + "$"
	$PenaltyValue.text = str(penalty) + "$"
	$LevelMusic.play()

func _on_continue_button_pressed() -> void:
	level_screen_closed.emit()
	self.visible = false
	$LevelMusic.stop()
