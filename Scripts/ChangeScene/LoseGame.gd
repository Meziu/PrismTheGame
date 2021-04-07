extends VBoxContainer

var RigiocaFreccia = false # la freccia accanto a Giocatore Singolo è inivisibile
var MenuFreccia = false # la freccia accanto a Opzioni è invisibile
onready var arrows = [$ButtonsBox/RigiocaBox/Sprite1,
						$ButtonsBox/RigiocaBox/Sprite2,
						$ButtonsBox/MenuBox/Sprite3,
						$ButtonsBox/MenuBox/Sprite4 ]

func _ready():
	for arrow in arrows:
		arrow.visible = false
	get_node("StatsBox/Score").text = "Score: " + str(globals.arcade_current_score)
	
	if globals.arcade_current_score > SaveData.data["HighScore"]:
		get_node("StatsBox/Score").text = get_node("StatsBox/Score").text + "\nNew HighScore!!!"
	
	globals._arcade_score_saver()
	globals._globals_reset()
	
func _on_RigiocaButton_pressed():
	if !RigiocaFreccia: # se la freccia accanto a Rigioca non è presente
		arrows[0].visible = true
		arrows[1].visible = true
		arrows[2].visible = false
		arrows[3].visible = false
		
		RigiocaFreccia = true
		MenuFreccia = false
	else: # se la freccia accanto a Rigioca è già presente
		globals._set_difficulty()
		get_tree().change_scene("res://Scenes/ChangeScene/Game.tscn") # cambia scena in Game

func _on_MenuButton_pressed():
	if !MenuFreccia:
		arrows[0].visible = false
		arrows[1].visible = false
		arrows[2].visible = true
		arrows[3].visible = true
		
		RigiocaFreccia = false
		MenuFreccia = true
	else:
		get_tree().change_scene("res://Main/MainMenu.tscn") # cambia scena nel menu principale

