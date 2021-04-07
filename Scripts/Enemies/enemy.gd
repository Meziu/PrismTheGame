extends KinematicBody2D

var choice

onready var spaceship = get_parent().get_parent().get_node("Spaceship")
onready var spawner = get_parent()

var movement = Vector2() # vettore spostamento del nemico
var speed = 150 # velocità del nemico

var sounds = {"explosion":preload("res://Sound/Enemies/explosion.ogg")}

signal death()
signal crush() # segnale che il nemico emette quando colpisce Spaceship

func _ready():
	randomize() # randomizza il seme per le funzioni random
	
	spawner.set_enemy_rail("normal", self)
	
func _process(delta): 
	global_position.y = choice
	
	var spaceshipRelative = spaceship.global_position.x - self.global_position.x
	
	if $Movement.time_left == 0:
		movement.x = get_direction_shooter()
		$Movement.start()
	
	var bodies = $Area2D.get_overlapping_bodies() # ottengo una lista con tutti i corpi che overlappano il nemico
	for body in bodies: # li controllo tutti
		if body.name == "Spaceship": # se trovo Spaceship
			emit_signal("death", self)
			emit_signal("crush") # emetto il segnale che sta collidendo
			
	var initPos = global_position # conserva la posizione prima di muovere il corpo
	
	var moving_collider = move_and_collide(movement*speed*delta)
	if moving_collider: # sposto il nemico nella direzione "get_random_direction", con velocità speed, in un tempo delta
		movement.x = -movement.x
		move_and_collide(movement*speed*delta)
		
	if global_position.x > 996:
		global_position.x += -(speed*delta)
	elif global_position.x < 29:
		global_position.x += speed*delta
	
	if global_position.y > 640: # controlla se il nemico è fuori dal bordo in basso
		global_position.y = 28 # trasporta in alto

func get_random_direction():
	var direction
	var random = randf()
	if random < 0.5:
		direction = 0
	elif random < 0.75:
		direction = 1
	else:
		direction = -1
	return direction

func get_direction_shooter():
	
	var shooterArray = []
	var shooterPositions = []
	var shooterAbsPositions = []
	var closest
	var index
	
	for child in get_parent().get_children():
		if "enemyshooter" in child.name:
			shooterArray.append(child)
			shooterPositions.append(sign(child.global_position.x - global_position.x))			
			shooterAbsPositions.append(abs(child.global_position.x - global_position.x))
	
	if shooterArray == []:
		return get_random_direction()
	else:
		closest = shooterAbsPositions.min()
		
		for i in range(0, shooterAbsPositions.size()):
			if shooterAbsPositions[i] == closest:
				index = i
		
		return shooterPositions[index]
