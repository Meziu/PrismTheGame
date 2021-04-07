extends HBoxContainer

var dir_path = "res://Sprites/Spaceship/MainBody/"
var current_skin_index

var skins_list = ["prisma_giallo.png", 
					  "prisma_verde.png", 
					  "prisma_azzurro.png", 
					  "prisma_viola.png", 
					  "prisma_thug.png", 
					  "prisma_dark.png", 
					  "prisma_rosa.png", 
					  "prisma_rosso.png", 
					  "prisma_arancio.png", 
					  "prisma_glitch.png", 
					  "prisma_prosciutto.png",
					  "prisma_classic.png",
					  "prisma_rainbow_diamond.png",
					  "prisma_f.png"]
var skins_prizes = [0,60,60,60,200,60,60,60,60,200,200,150,500,100]

func _ready():
	current_skin_index = _get_current_index()
	_texture_update()

func _get_current_index():
	var index = 0
	
	for i in skins_list:
		if i == SaveData.data["ChosenSkin"]:
			break
		index += 1
	
	return index

func _on_Button2_pressed():
	current_skin_index += 1
	_texture_update()
func _on_Button1_pressed():
	current_skin_index -= 1
	_texture_update()

func _texture_update():
	_safety_checker()
	_visual_availability_checker()
	$VBoxContainer/HBoxContainer/SkinWindow.texture = load(dir_path + skins_list[current_skin_index])
	get_parent().get_node("HBoxContainer/CoinCounter").text = "Coins: "+str(SaveData.data["Coins"])
	SaveData.save_game()

func _safety_checker():
	if current_skin_index < 0:
		current_skin_index = skins_list.size() - 1
	elif current_skin_index > skins_list.size() - 1:
		current_skin_index = 0

func _visual_availability_checker():
	if not SaveData.data["SkinsBought"][current_skin_index]:
		$VBoxContainer/Available.text = "Price: " + str(skins_prizes[current_skin_index])
	else:
		if SaveData.data["ChosenSkin"] != skins_list[current_skin_index]:
			$VBoxContainer/Available.text = "Wear it"
		else:
			$VBoxContainer/Available.text = "In use"

func _on_Available_pressed():
	if not SaveData.data["SkinsBought"][current_skin_index]:
		if SaveData.data["Coins"] >= skins_prizes[current_skin_index]:
			SaveData.data["Coins"] -= skins_prizes[current_skin_index]
			SaveData.data["SkinsBought"][current_skin_index] = true
			SaveData.data["ChosenSkin"] = skins_list[current_skin_index]
	else:
		SaveData.data["ChosenSkin"] = skins_list[current_skin_index]
	_texture_update()
