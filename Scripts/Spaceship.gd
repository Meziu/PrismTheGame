extends KinematicBody2D

export (PackedScene) var bullet # variabile di tipo PackedScene (scena), settata a Proiettile.tscn
export (int) var max_lives = 3 # numero di lives del player
export (int) var enemies2kill = 5 # numero di nemici da uccidere per passare di livello

var movement = Vector2() # vettore velocità
var invFrames = false
var life_lose_sprite = preload("res://Sprites/UserInterface/LifeLose.png")
var life_normal_sprite = preload("res://Sprites/UserInterface/life.png")
var is_waited = false

var sounds = {"hit":preload("res://Sound/Player/hit.ogg"),"shoot":preload("res://Sound/Player/shoot_spaceship.ogg"),"heal":preload("res://Sound/Player/healing.ogg"),"coin":preload("res://Sound/Player/coin.ogg")}

var walk_speed
onready var PauseTimer = $"..".get_node("PauseTimer")
onready var life_sprite = [$"..".get_parent().get_node("ScoreCounter/Control/MarginContainer/VBoxContainer/HBoxContainer2/LifeSection/MarginContainer/VBoxContainer/HBoxContainer/Life1"), $"..".get_parent().get_node("ScoreCounter/Control/MarginContainer/VBoxContainer/HBoxContainer2/LifeSection/MarginContainer/VBoxContainer/HBoxContainer/Life2"), $"..".get_parent().get_node("ScoreCounter/Control/MarginContainer/VBoxContainer/HBoxContainer2/LifeSection/MarginContainer/VBoxContainer/HBoxContainer/Life3")]
onready var ScoreCounter = $"..".get_parent().get_node("ScoreCounter/Control/MarginContainer/VBoxContainer/HBoxContainer2/ScoreSection/MarginContainer/VBoxContainer/Label")
onready var CoinCounter = $"..".get_parent().get_node("ScoreCounter/Control/MarginContainer/VBoxContainer/HBoxContainer/CoinSection/MarginContainer/VBoxContainer/HBoxContainer/Label")
onready var powerupScript = $"..".get_node("PowerUpSpawner")

signal level_passed() # segnale che verrà inviato al termine del livello
signal defeat() # segnale che verrà inviato alla sconfitta della navicella

func _ready():
	_chosen_skin_checker()

	# aggiorna il counter di vite
	_life_calc()
	
	_upgrades_checker()
	
	# aggiorno il numero di nemici per il livello corrente
	enemies2kill += 3*globals.arcade_current_level
	
	globals.arcade_current_level += 1 # aumento il livello
	
	# setta la posizione iniziale della navicella a 512,548
	global_position.x = 512
	global_position.y = 548
	
	# scrive il numero del livello
	$"..".get_parent().get_node("ScoreCounter/Control/MarginContainer/VBoxContainer/HBoxContainer/LevelSection/MarginContainer/VBoxContainer/Level").text = "Level " + str(globals.arcade_current_level)
	
	globals.arcade_current_kills = 0 # le kill si resettano

# funzione che gestisce lo sparo
func shoot():
	if $ShootingTimer.time_left == 0: # se il timer ha raggiunto lo zero
		var b = bullet.instance() # istanzia la scena dichiarata prima
		b.set_global_position($Barrell.global_position) # setta la posizione iniziale alla posizione del cannone della navicella (Barrell)
		b.get_node("Sprite").texture = load("res://Sprites/Bullet/bullet.png") # il proiettile avrà la texture gialla
		b.target = "enemy"
		$"..".add_child(b) # aggiunge la scena istanziata come figlia di Spaceship
		
		_audio_player("shoot")
		
		$ShootingTimer.start() # starta il timer

func _physics_process(delta):
	walk_speed = globals.arcade_current_speed * delta
		
	var rel_position = get_global_mouse_position()-global_position
	
	if PauseTimer.time_left == 0:
		$"..".get_parent().get_node("ScoreCounter/Control").visible = true
		_is_level_passed()
	else:
		$"..".get_parent().get_node("ScoreCounter/Control").visible = false
		return
	
	_labels_updater()
	
	shoot()
	
	if not rel_position.length() < walk_speed:
		movement = rel_position.normalized() * globals.arcade_current_speed
	else:
		movement = Vector2()
	
	_speed_limits_checker()
	move_and_slide(movement) # gestisce il movimento della navicella
	_limits_checker()
	
	# se le kill sono 25 (lv 1), 50 (lv 2), 25 in più per ogni livello
	if globals.arcade_current_kills >= enemies2kill:
		emit_signal("level_passed") # emetto il segnale che il livello è stato superato
		PauseTimer.start()
		is_waited = true
	
	if $Sprite/SpriteAnimationTimers/HitTimer.time_left < 0.1 and $Sprite/SpriteAnimationTimers/HitTimer.time_left > 0:
		$Sprite.modulate = Color(1,1,1,1)
		invFrames = false
		
# riceve il segnale inviato da un nemico quando overlappa
func _on_enemy_crush():
	
	_take_damage()
	
	# il nemico viene ucciso, il punteggio si aggiorna
	globals.arcade_current_score += 100
	
	globals.arcade_current_kills += 1

func _take_Coin():
	globals.arcade_current_coins += 1
	_audio_player("coin")
func _take_AddScore():
	globals.arcade_current_score += 500
	_audio_player("heal")
func _take_x2Score():
	globals.arcade_current_score *= 2
	_audio_player("heal")

# la navicella collide con la vita
func _take_life():
	if globals.arcade_current_lives >= max_lives: # se il numero di lives è superiore al numero massimo di globals.arcade_current_lives (caso estremo)
		globals.arcade_current_lives = max_lives # riporta il numero dilives al massimo disponibile
	else: # se il numero di lives < 3
		globals.arcade_current_lives += 1 # aumenta di 1
	globals.arcade_current_score += 50
	
	$Healing.play("Healing")
	$Healing.visible = true
	_audio_player("heal")
	
	_life_calc()

# update del contatore delle lives
func _life_calc():
	if globals.arcade_current_lives >= 3:
		life_sprite[2].texture = life_normal_sprite
		life_sprite[1].texture = life_normal_sprite
	
	if globals.arcade_current_lives == 2: # se lives = 2
		# rende visibile lo sprite con il cuore vuoto e invisibile il cuore pieno
		life_sprite[2].texture = life_lose_sprite
		life_sprite[1].texture = life_normal_sprite
	
	if globals.arcade_current_lives == 1: # se lives = 1
		# rende visibile lo sprite con il cuore vuoto e invisibile il cuore pieno
		life_sprite[2].texture = life_lose_sprite
		life_sprite[1].texture = life_lose_sprite
	
	if globals.arcade_current_lives <= 0: # se lives = 0
		# rende visibile lo sprite con il cuore vuoto e invisibile il cuore pieno
		life_sprite[0].texture = life_lose_sprite
		get_tree().change_scene("res://Scenes/ChangeScene/LoseGame.tscn")

func _is_level_passed():
	if is_waited:
		if globals.arcade_current_kills >= enemies2kill:
			#if globals.arcade_current_level%ondateShop == 0:
			get_tree().change_scene("res://Scenes/ChangeScene/WinGame.tscn")

func _take_damage():
	if !invFrames:
		globals.arcade_current_lives -= 1
		
		$Sprite.modulate = Color(1,1,1,0.5)
		$Sprite/SpriteAnimationTimers/HitTimer.start()
		invFrames = true
		_audio_player("hit")

		_life_calc()

func _labels_updater():
	CoinCounter.text = str(globals.arcade_current_coins)
	ScoreCounter.text = str(globals.arcade_current_score)
	$"..".get_parent().get_node("ScoreCounter/Control/MarginContainer/VBoxContainer/HBoxContainer/LevelSection/MarginContainer/VBoxContainer/enemyKilledCount").text = "Remaining "+str(globals.arcade_current_kills)+"/"+str(enemies2kill)

func _limits_checker():
	if global_position.y > 570: # se la navicella si trova sul bordi in alto e in basso (420 e 570)
		global_position.y = 570 # resetta la posizione sulla y
	elif global_position.y < 350: # se la navicella si trova all'interno dei bordi
		global_position.y = 350

func _speed_limits_checker():
	if movement.x > 1000:
		movement.x = 1000
	elif movement.x < -1000:
		movement.x = -1000
	if movement.y > 300:
		movement.y = 300
	elif movement.y < -300:
		movement.y = -300

func _audio_player(audio_key):
	if audio_key == "shoot":
		$ShootingPlayer.stream = sounds[audio_key]
		$ShootingPlayer.play()
	elif audio_key in ["heal", "hit", "coin"]:
		$StatePlayer.stream = sounds[audio_key]
		$StatePlayer.play()

func _upgrades_checker():
	if globals.arcade_upgrades_picked["speed"] <= 30:
		globals.arcade_current_speed += 25*globals.arcade_upgrades_picked["speed"]
	
	if globals.arcade_upgrades_picked["reload"] <= 30:
		$ShootingTimer.wait_time -= 0.01*globals.arcade_upgrades_picked["reload"]
	
	if globals.arcade_upgrades_picked["powerups"] <= 30:
		powerupScript.LifePercent += 0.01*globals.arcade_upgrades_picked["powerups"]
		powerupScript.AddScorePercent += 0.01*globals.arcade_upgrades_picked["powerups"]
		powerupScript.x2ScorePercent += 0.001*globals.arcade_upgrades_picked["powerups"]

func _on_Healing_animation_finished():
	$Healing.visible = false

func _chosen_skin_checker():
	$Sprite.texture = load("res://Sprites/Spaceship/MainBody/"+SaveData.data["ChosenSkin"])
