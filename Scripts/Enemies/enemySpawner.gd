extends Node

var percents = {"normal": 0.08, "shooter": 0.03, "kamikaze": 0.005}

var counters = {"normal": 0, "shooter": 0, "kamikaze": 0, "upgrade": 0}

var instances = {"normal": preload("res://Scenes/Enemies/enemy.tscn"),
				 "shooter": preload("res://Scenes/Enemies/enemyShooter.tscn"), 
				 "kamikaze": preload("res://Scenes/Enemies/enemyKamikaze.tscn"),
				 "upgrade": preload("res://Scenes/Enemies/meteorite.tscn"),
				 "explosion":preload("res://Scenes/Enemies/explosion.tscn")}

var spawn_position = {"x":{"normal":[-35, 1059], 
							"shooter":[-28, 1048]}, 
					  "rail":{"normal":[204, 264, 324], 
							"shooter":[84, 144]}}

var limits = globals.arcade_current_limits

var rail_data = {"counter":[0,0,0,0,0],
				 "limits":[
						limits["shooter"]/2,
						limits["shooter"]/2,
						limits["normal"]/3,
						limits["normal"]/3,
						limits["normal"]/3]}

onready var spaceshipDefeated = false # variabile che indica se la navicella sia stata sconfitta
onready var spaceshipWon = false # variabile che indica se la naviccella abbia vinto

func _ready():
	randomize() # genera un seme randomico per le funzioni random
	
	difficulty_update()
	
	var normal_module = limits["normal"]%3
	var shooter_module = limits["shooter"]%2
	
	for i in range(normal_module):
		rail_data["limits"][i+2] += 1
	for i in range(shooter_module):
		rail_data["limits"][i] += 1

func _process(delta):
	var rand = randf()
	
	if globals.arcade_current_level % 5 == 0 and counters["upgrade"] < 1 and !spaceshipDefeated and !spaceshipWon:
		settings(instances["upgrade"])
	
	if rand < percents["kamikaze"] and counters["kamikaze"] < limits["kamikaze"] and !spaceshipDefeated and !spaceshipWon and $kamikazeTimer.time_left == 0:
		settings(instances["kamikaze"])
		$kamikazeTimer.start()
	elif rand < percents["shooter"] and counters["shooter"] < limits["shooter"] and !spaceshipDefeated and !spaceshipWon and $shooterTimer.time_left == 0: # controlla se il numero è minore di 0.05 (5%) e se il numero massimo di nemici non è stato raggiunto
		settings(instances["shooter"])
		$shooterTimer.start()
	elif rand < percents["normal"] and counters["normal"] < limits["normal"] and !spaceshipDefeated and !spaceshipWon and $normalTimer.time_left == 0: # controlla se il numero è minore di 0.05 (5%) e se il numero massimo di nemici non è stato raggiunto
		settings(instances["normal"])
		$normalTimer.start()
		
	if spaceshipDefeated or spaceshipWon:
		for child in get_children():
			if "enemy" in child.name and not "Timer" in child.name:
				_explode(child)
			elif "Proiettile" in child.name:
				child.queue_free()

func settings(enemy_scene):
	var index = index_get(enemy_scene)[0]
	var sygnal = index_get(enemy_scene)[1]
	if $"..".get_node("PauseTimer").time_left == 0:
		var E = enemy_scene.instance()
		
		counters[index] += 1
		
		E.name = "enemy" + index + str(counters[index])
		
		E.connect("death", $"..".get_node("enemySpawner"), sygnal)
		
		if index == "upgrade":
			E.connect("death", get_tree().get_root().get_node("Control/UpgradesGGs"), "_release_upgrade")
		
		E.connect("crush", $"..".get_node("Spaceship"), "_on_enemy_crush")
		
		call_deferred("add_child", E)
		
func set_enemy_rail(enemy_type, instance):
	if enemy_type != "kamikaze" and enemy_type != "upgrade":
		instance.global_position.x = spawn_position["x"][enemy_type][randi() % spawn_position["x"][enemy_type].size()]
		instance.global_position.y = rail_limits_checker(enemy_type)
		instance.choice = instance.global_position.y
		change_rail_counter(instance.global_position.y, true)

func index_get(enemy_scene):
	var index
	var sygnal
	if enemy_scene == instances["normal"]:
		index = "normal"
		sygnal = "_on_enemy_death"
	elif enemy_scene == instances["shooter"]:
		index = "shooter"
		sygnal = "_on_enemy_shooter_death"
	elif enemy_scene == instances["kamikaze"]:
		index = "kamikaze"
		sygnal = "_on_enemy_kamikaze_death"
	elif enemy_scene == instances["upgrade"]:
		index = "upgrade"
		sygnal = "_on_enemy_upgrade_death"
	return [index, sygnal]

# quando il nemico viene rimosso dalla scena
func _on_enemy_death(Enemy):
	counters["normal"] -= 1 # diminuisce di 1 il numero di nemici
	change_rail_counter(Enemy.global_position.y, false)
	_explode(Enemy)
func _on_enemy_shooter_death(Enemy):
	counters["shooter"] -= 1 # diminuisce di 1 il numero di nemici
	change_rail_counter(Enemy.global_position.y, false)
	_explode(Enemy)
func _on_enemy_kamikaze_death(Enemy):
	counters["kamikaze"] -= 1
	_explode(Enemy)
func _on_enemy_upgrade_death(Enemy):
	_explode(Enemy)

func _explode(Enemy):
	explosion_instancer(Enemy.global_position, 0)
	Enemy.queue_free()

# quando il livello viene completato
func _on_Spaceship_level_passed(): 
	spaceshipWon = true
func _on_Spaceship_defeat():
	spaceshipDefeated = true

func change_rail_counter(choice, b:bool):
	var choice_i = choice_checker(choice)
	
	if !spaceshipDefeated or !spaceshipWon:
		if b:
			rail_data["counter"][choice_i] += 1
		else:
			rail_data["counter"][choice_i] -= 1
	else:
		rail_data["counter"] = [0,0,0,0,0]

func choice_checker(choice):
	var abs_array = []
	var rail_array = []
	choice = round(choice)
	
	for i in spawn_position["rail"]["normal"]:
		abs_array.append(abs(choice-i))
		rail_array.append(i)
	for i in spawn_position["rail"]["shooter"]:
		abs_array.append(abs(choice-i))
		rail_array.append(i)
	
	var index = abs_array.min()
	var rail_index = 0
	for i in abs_array:
		if i == index:
			return rail_index
		rail_index += 1

func rail_limits_checker(index):
	var available_rails = spawn_position["rail"][index]
	var actual_choice = available_rails[randi() % available_rails.size()]
	
	if rail_data["counter"][choice_checker(actual_choice)] >= rail_data["limits"][choice_checker(actual_choice)]:
		for rail in available_rails:
			if rail_data["counter"][choice_checker(rail)] < rail_data["limits"][choice_checker(rail)]:
				actual_choice = rail
	
	return actual_choice

func difficulty_update():
	var level = globals.arcade_current_level
	
	$normalTimer.wait_time = 1
	$shooterTimer.wait_time = 1.5
	$kamikazeTimer.wait_time = 2
	for i in range(level):
		if i != 0:
			if i % 2 == 0:
				globals.arcade_current_limits["normal"] += 1
				$normalTimer.wait_time = max($normalTimer.wait_time-0.04, 0.2)
			if i % 3 == 0:
				globals.arcade_current_limits["shooter"] += 1
				$shooterTimer.wait_time = max($shooterTimer.wait_time-0.05, 0.3)
			if i % 5 == 0:
				globals.arcade_current_limits["kamikaze"] += 1
				$kamikazeTimer.wait_time = max($kamikazeTimer.wait_time-0.1, 0.4)
	
	globals._set_difficulty()

func explosion_instancer(enemy_position, enemy_rotation):
	var explosion = instances["explosion"].instance()
	explosion.global_position = enemy_position
	explosion.global_rotation = enemy_rotation
	add_child(explosion)
