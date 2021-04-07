extends Control

var PowerUpCount = 0
var PowerUpLimit = 1

export (float) var LifePercent = 0.02
var InstLife = preload("res://Scenes/Powerup/Life.tscn")
var lost = load("res://Sprites/UserInterface/LifeLose.png") # png della vita persa

export (float) var AddScorePercent = 0.02
var InstAddScore = preload("res://Scenes/Powerup/AddScore.tscn")

export (float) var x2ScorePercent = 0.001
var Instx2Score = preload("res://Scenes/Powerup/x2Score.tscn")

export (int) var CoinLimit = 5
export (float) var CoinPercent = 0.01
var InstCoin = preload("res://Scenes/Powerup/Coin.tscn")
var CoinCount = 0

func _ready():
	$LifeTimer.start()
	$AddScoreTimer.start()
	$x2ScoreTimer.start()
	$CoinTimer.start()
	randomize()

func _process(delta):
	# sprite della terza vita
	var lastLife = $"..".get_parent().get_node("ScoreCounter/Control/MarginContainer/VBoxContainer/HBoxContainer2/LifeSection/MarginContainer/VBoxContainer/HBoxContainer/Life3").texture
	
	# lastLife == lost (lo sprite della terza vita corrisponde allo sprite della vita persa)
	# Il timer serve a far spawnare, se possibile, una vita ogni 30 secondi
	if randf() < (LifePercent) and PowerUpCount <= PowerUpLimit and lastLife == lost and $LifeTimer.time_left == 0: 
		$LifeTimer.start() # fa ripartire il timer
		Life_setting() 
	if randf() < (AddScorePercent + LifePercent) and PowerUpCount <= PowerUpLimit and $AddScoreTimer.time_left == 0: 
		$AddScoreTimer.start() # fa ripartire il timer
		AddScore_Setting() 
	if randf() < (x2ScorePercent + AddScorePercent + LifePercent) and PowerUpCount <= PowerUpLimit and $x2ScoreTimer.time_left == 0: 
		$x2ScoreTimer.start() # fa ripartire il timer
		x2Score_Setting() 
	if randf() < (CoinPercent + x2ScorePercent + AddScorePercent + LifePercent) and CoinCount <= CoinLimit and $CoinTimer.time_left == 0: 
		$CoinTimer.start() # fa ripartire il timer
		Coin_Setting() 

func Coin_Setting():
	if get_parent().get_node("PauseTimer").time_left == 0: # si esegue solo se il PauseTimer è finito
		var C = InstCoin.instance() 
		var CoinPos = Vector2()
		CoinCount += 1 
	
		CoinPos.x = randi() % 1025
		CoinPos.y = -10 
		C.set_global_position(CoinPos)
		
		var CoinName = "AddScore" + str(CoinCount)
		C.name = CoinName
		
		C.connect("tree_exiting", get_parent().get_node("PowerUpSpawner"), "_on_Coin_death")
		C.connect("crush", get_parent().get_node("Spaceship"), "_take_Coin")
		call_deferred("add_child", C)

func x2Score_Setting():
	if get_parent().get_node("PauseTimer").time_left == 0: # si esegue solo se il PauseTimer è finito
		var x2S = Instx2Score.instance() 
		var x2ScorePos = Vector2()
		PowerUpCount += 1 
	
		x2ScorePos.x = randi() % 601 + 200
		x2ScorePos.y = -10 
		x2S.set_global_position(x2ScorePos)
		
		var x2ScoreName = "AddScore" + str(PowerUpCount)
		x2S.name = x2ScoreName
		
		x2S.connect("tree_exiting", get_parent().get_node("PowerUpSpawner"), "_on_Powerup_death")
		x2S.connect("crush", get_parent().get_node("Spaceship"), "_take_x2Score")
		call_deferred("add_child", x2S)

func AddScore_Setting():
	if get_parent().get_node("PauseTimer").time_left == 0: # si esegue solo se il PauseTimer è finito
		var AS = InstAddScore.instance() 
		var AddScorePos = Vector2()
		PowerUpCount += 1 
	
		AddScorePos.x = randi() % 601 + 200
		AddScorePos.y = -10 
		AS.set_global_position(AddScorePos)
		
		var AddScoreName = "AddScore" + str(PowerUpCount)
		AS.name = AddScoreName
		
		AS.connect("tree_exiting", get_parent().get_node("PowerUpSpawner"), "_on_Powerup_death")
		AS.connect("crush", get_parent().get_node("Spaceship"), "_take_AddScore")
		call_deferred("add_child", AS)

func Life_setting():
	if get_parent().get_node("PauseTimer").time_left == 0: # si esegue solo se il PauseTimer è finito
		var L = InstLife.instance() 
		var LifePos = Vector2()
		PowerUpCount += 1 
	
		LifePos.x = randi() % 601 + 200
		LifePos.y = -10 
		L.set_global_position(LifePos)
		
		# setta il nome del powerup in modo da renderlo riconoscibile a spaceship
		var LifeName = "life" + str(PowerUpCount)
		L.name = LifeName
			
		# connette il segnale tree_exiting (quando il powerup viene rimosso dalla scena) al nodo PowerUpSpawner, e al metodo _on_life_death
		L.connect("tree_exiting", get_parent().get_node("PowerUpSpawner"), "_on_Powerup_death")
			
		# connette il segnale crush (dichiarato in Life) al nodo spaceship, e al metodo _take_life
		L.connect("crush", get_parent().get_node("Spaceship"), "_take_life")
			
		# aggiunge il nemico come child del nodo PowerUpSpawner
		call_deferred("add_child", L)

# quando il powerup viene rimosso dalla scena
func _on_Powerup_death():
	PowerUpCount -= 1 # diminuisce di 1 il numero di vite presenti a schermo

func _on_Coin_death():
	CoinCount -= 1

# quando il livello è stato completato
func _on_Spaceship_level_passed():
	for child in get_children(): # per ogni figlio nell'array dei figli (ottenuto con get_children)
		if !("Timer" in child.name):
			remove_child(child) # rimuove il figlio
