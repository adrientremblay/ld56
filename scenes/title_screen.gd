extends Control

func _ready() -> void:
	self.visible = true

func open():
	self.visible = true
	$TitleMusic.play()

func close():
	self.visible = false
	$TitleMusic.stop()
