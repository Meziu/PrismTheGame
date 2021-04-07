extends CanvasLayer

func _on_PauseButton_pressed():
	get_tree().paused = true
	get_parent().get_node("PauseMenu/Control").visible = true
