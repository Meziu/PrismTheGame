extends KinematicBody2D

export (PackedScene) var bullet # variabile di tipo PackedScene (scena), settata a Proiettile.tscn

var choice

onready var spaceship = get_parent().get_parent().get_node("Spaceship")

var movement = Vector2() # vettore spostamento del nemico
var speed = 100 # velocità del nemico
var lives = 3

signal death()
signal crush() # segnale che il nemico emette quando colpisce Spaceship

var spawnX = [256, 768]

func _ready():
	randomize() # randomizza il seme per le funzioni random
	global_position = Vector2(spawnX[randi() % 2], -28)
	
func _process(delta): 
	
	var relative = spaceship.global_position.x - self.global_position.x
	
	if global_position.y < 28:
		global_position.y += speed*delta
	
	if global_position.x > 950:
		global_position.x += -(speed*delta)
	elif global_position.x < 74:
		global_position.x += speed*delta
	
	if $Movement.time_left == 0:
		movement.x = -sign(relative)
		$Movement.start()
	
	var bodies = $Area2D.get_overlapping_bodies() # ottengo una lista con tutti i corpi che overlappano il nemico
	for body in bodies: # li controllo tutti
		if body.name == "Spaceship": # se trovo Spaceship
			lives -= 1
			_life_checker()
			emit_signal("crush") # emetto il segnale che sta collidendo

	var initPos = global_position
	
	if move_and_collide(movement*speed*delta): # sposto il nemico nella direzione "get_random_direction", con velocità speed, in un tempo delta
		global_position = initPos


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

func _life_checker():
	if lives >= 3:
		$enemy.play("3Lives")
	elif lives == 2: # se lives = 2
		$enemy.play("2Lives")
	elif lives == 1: # se lives = 1
		$enemy.play("1Life")
	elif lives <= 0: # se lives = 0
		emit_signal("death", self)
	
	$AudioStreamPlayer2D.play()
