extends Node

const path = "user://SaveData.json"
var default_data = {
  "HighScore": 0,
  "Coins":0,
  "ChosenSkin": "prisma_giallo.png",
  "Difficulty":"normie",
  "SkinsBought": [true,false,false,false,false,false,false,false,false,false,false,false,false,false]
}

var data = { }

func _ready():
	load_game()

func load_game():
	var file = File.new()
	
	if not file.file_exists(path):
		reset_data()
		return
	
	file.open(path, file.READ)
	
	var text = file.get_as_text()
	
	data = parse_json(text)
	
	file.close()

func save_game():
	var file
	
	file = File.new()
	
	file.open(path, File.WRITE)
	
	file.store_line(to_json(data))
	
	file.close()

func reset_data():
	# Reset to defaults
	data = default_data.duplicate(true)
