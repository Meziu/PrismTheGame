extends VBoxContainer

func _ready():
	get_node("VBoxContainer/Label").text = "HighScore: " + str(SaveData.data["HighScore"])
	if SaveData.data["Coins"] >= 10000:
		get_node("VBoxContainer2/CoinCelebration").text = "WOAH, you've gotten 10000 coins, take this imaginary prize"

func _on_Arcade_pressed():
	get_tree().change_scene("res://Scenes/ChangeScene/Game.tscn") # cambia scena in Game
func _on_Options_pressed():
	get_tree().change_scene("res://Scenes/ChangeScene/Opzioni.tscn") # cambia scena in Opzioni
func _on_Rules_pressed():
	get_tree().change_scene("res://Scenes/ChangeScene/Rules.tscn")
func _on_ShopButton_pressed():
	get_tree().change_scene("res://Scenes/ChangeScene/ShopSerio.tscn") # cambia scena in Opzioni
func _on_CreditsButton2_pressed():
	get_tree().change_scene("res://Scenes/ChangeScene/Credits.tscn")
