extends DialogicPortrait
func _update_portrait(passed_character:DialogicCharacter, passed_portrait:String) -> void:
	print (passed_portrait)
	if (passed_portrait == "Frowning"):
		$Sprite.play("frowning")
	elif (passed_portrait == "Smiling"):
		$Sprite.play("smiling")
	else:
		$Sprite.play("deadfaced")

func _on_animated_sprite_2d_animation_finished() -> void:
	#$Sprite.play()
	pass

func _get_covered_rect() -> Rect2:
	return Rect2($Sprite.position, $Sprite.sprite_frames.get_frame_texture($Sprite.animation, 0).get_size()*$Sprite.scale)
