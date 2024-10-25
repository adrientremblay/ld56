extends Control

func _ready() -> void:
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func open(corpses_disposed: int):
	self.visible = true
	$EndGameSound.play()
	
	#$Spokesman.play()
	#if (corpses_disposed < 5):
		#$Label.text = "You have dissapointed us greatly. Your aquarium is ruined and we have many more bodies to dispose of. It will be a pain to dispose of yours."
		#$SpokesmanSpeechNo.play()
	#elif (corpses_disposed < 10):
		#$Label.text = "You have done satisfactory. Set up another tank and we will be in contact."
		#$SpokesmanSpeechNormal.play()
	#else:
		#$Label.text = "You have not let us down. No one on earth besides us know where these people are. We look forward to working with you again."
		#$SpokesmanSpeechNormal.play()
	
	$FinalScoreLabel.text = "Corpses Disposed: " + str(corpses_disposed)
