extends CanvasLayer

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		var new_pause_state = not get_tree().paused
		get_tree().paused = new_pause_state
		get_node("Control").visible = new_pause_state

func _on_Resume_pressed():
	get_tree().paused = false
	get_node("Control").visible = false

func _on_QuitToMenu_pressed():
	get_tree().paused = false
	
	globals._arcade_score_saver()
	globals._globals_reset()
	
	get_tree().change_scene("res://Main/MainMenu.tscn")
