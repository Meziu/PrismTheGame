extends KinematicBody2D

var movement = Vector2() 
var speed = 50 
signal crush()

func _ready():
	pass

func _process(delta): 
	
	if $Timer.time_left == 0:
		$Timer.start() # il conteggio riparte
		movement = Vector2(0, 1) # il corpo si muove solo verso il basso
	
	var bodies = $Area2D.get_overlapping_bodies() # ottengo una lista con tutti i corpi che overlappano il nemico
	
	for body in bodies: # li controllo tutti
		if body.name == "Spaceship": # se trovo Spaceship
			emit_signal("crush") # emetto il segnale che sta collidendo
			queue_free() 
	
	move_and_collide(movement*speed*delta) # sposto il nemico nella direzione di movement, con velocità speed, in un tempo delta
	
	if global_position.y > 610:
		queue_free()
