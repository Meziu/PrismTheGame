extends CanvasLayer

onready var GGLabel = get_node("Control/MarginContainer/CenterContainer/GG")

func _release_upgrade(Enemy):
	var up = globals.arcade_upgrades_picked.keys()[randi() % (globals.arcade_upgrades_picked.size())]
	globals.arcade_upgrades_picked[up] += 1
	GGLabel.text = up.capitalize() + " got upgraded!"
	$Control.visible = true
	$Visibility.start()

func _on_Visibility_timeout():
	$Control.visible = false
