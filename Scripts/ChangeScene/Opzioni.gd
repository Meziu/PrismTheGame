extends Control

func _ready():
	white_out(null)
	load_colors()

func _on_Indietro_pressed():
	get_tree().change_scene("res://Main/MainMenu.tscn")


func _on_EZ_pressed():
	var self_tag = "ez"
	
	globals.arcade_current_difficulty = "ez"
	SaveData.data["Difficulty"] = "ez"
	
	SaveData.save_game()
	white_out(self_tag)
	load_colors()

func _on_NORMIE_pressed():
	var self_tag = "normie"
	
	globals.arcade_current_difficulty = "normie"
	SaveData.data["Difficulty"] = "normie"
	
	SaveData.save_game()
	white_out(self_tag)
	load_colors()

func _on_PRO_pressed():
	var self_tag = "pro"
	
	globals.arcade_current_difficulty = self_tag
	SaveData.data["Difficulty"] = self_tag
	
	SaveData.save_game()
	white_out(self_tag)
	load_colors()
	
func white_out(caller):
	for button in $MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer/HBoxContainer2.get_children():
		if button.name != caller or not caller:
			button.set("custom_colors/font_color",Color("ffffff"))
			button.set("custom_colors/font_color_hover",Color("ffffff"))
			button.set("custom_colors/font_color_pressed",Color("ef4040"))

func load_colors():
	var current = SaveData.data["Difficulty"]
	
	for button in $MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer/HBoxContainer2.get_children():
		if button.name == current:
			button.set("custom_colors/font_color",Color("ff0000"))
			button.set("custom_colors/font_color_hover",Color("ff0000"))
			button.set("custom_colors/font_color_pressed",Color("ff0000"))
