extends Control

onready var coins = SaveData.data["Coins"]

func _ready():
	$MarginContainer/VBoxContainer/HBoxContainer/CoinCounter.text = "Coins: " + str(SaveData.data["Coins"])

func _on_BackButton_pressed():
	SaveData.save_game()
	get_tree().change_scene("res://Main/MainMenu.tscn")
