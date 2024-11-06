extends Control

func _ready() -> void:
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func open(corpses_disposed: int):
	self.visible = true
	$WinGameSound.play()
	
	$FinalScoreLabel.text = "Corpses Disposed: " + str(corpses_disposed)
