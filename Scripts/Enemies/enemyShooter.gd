extends KinematicBody2D

export (PackedScene) var bullet # variabile di tipo PackedScene (scena), settata a Proiettile.tscn

var choice

onready var spaceship = get_parent().get_parent().get_node("Spaceship")
onready var spawner = get_parent()

var movement = Vector2() # vettore spostamento del nemico
var speed = 100 # velocità del nemico

var sounds = {"shoot":preload("res://Sound/Enemies/shoot_shooterenemy.ogg"),"explosion":preload("res://Sound/Enemies/explosion.ogg")}

signal death()
signal crush() # segnale che il nemico emette quando colpisce Spaceship

func _ready():
	randomize() # randomizza il seme per le funzioni random
	
	spawner.set_enemy_rail("shooter", self)
	
func _process(delta):
	global_position.y = choice
	
	var relative = spaceship.global_position.x - self.global_position.x
	
	if randf() < 0.02 && $Shooting.time_left == 0:
		$Animation.start()
		$enemy.play("Shooting")
	if $Animation.time_left > 0 and $Animation.time_left < 0.02:
		shoot()
	
	if global_position.x > 988:
		global_position.x += -(speed*delta)
	elif global_position.x < 36:
		global_position.x += speed*delta
	
	if $Movement.time_left == 0:
		movement.x = sign(relative)
		$Movement.start()
	
	var bodies = $Area2D.get_overlapping_bodies() # ottengo una lista con tutti i corpi che overlappano il nemico
	for body in bodies: # li controllo tutti
		if body.name == "Spaceship": # se trovo Spaceship
			emit_signal("death", self)
			emit_signal("crush") # emetto il segnale che sta collidendo

	var initPos = global_position
	
	var moving_collider = move_and_collide(movement*speed*delta)
	if moving_collider:
		movement.x = -movement.x
		move_and_collide(movement*speed*delta)

# funzione che gestisce lo sparo
func shoot():
	var b = bullet.instance() # istanzia la scena dichiarata prima
	b.set_global_position($Barrell.global_position) # setta la posizione iniziale alla posizione del cannone della navicella (Barrell)
	b.get_node("Sprite").texture = load("res://Sprites/Bullet/bullet_E2.png") # il proiettile avrà la texture rossa
	b.bullettSpeed *= -1
	b.target = "Spaceship"
	b.get_node("Sprite").scale = Vector2(4,4)
	b.get_node("Area2D/CollisionShape2D").scale = Vector2(0.34, 0.34)
	get_parent().add_child(b) # aggiunge la scena istanziata come figlia di enemyShooter
	
	_audio_player("shoot")
	$Shooting.start()
	$enemy.play("Normal")

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

func _audio_player(audio_key):
	$AudioStreamPlayer2D.stream = sounds[audio_key]
	$AudioStreamPlayer2D.play()
