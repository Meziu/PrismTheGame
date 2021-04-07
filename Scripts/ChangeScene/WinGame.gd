extends Control

func _ready():
	$VictoryTimer.start()
	
	# informa che ho finito l'N° livello
	get_node("MarginContainer/VBoxContainer/Label").text = "YOU'VE FINISHED LEVEL " + str(globals.arcade_current_level)
	# informa che sto per fare l'N+1° livello
	get_node("MarginContainer/VBoxContainer/Label2").text = "BE READY FOR LEVEL " + str(globals.arcade_current_level+1)
	
func _process(delta):
	if $VictoryTimer.time_left == 0:
		get_tree().change_scene("res://Scenes/ChangeScene/Game.tscn")
