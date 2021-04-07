extends KinematicBody2D

var speed = 175 # velocità del nemico
var movement = Vector2() # vettore spostamento del nemico

var attacking = false
var spaceship = null
var spaceshipPos = null

signal death()
signal crush() # segnale che il nemico emette quando colpisce Spaceship

func _ready():
	global_position = Vector2(512, -28)
	randomize() # randomizza il seme per le funzioni random
	$attackTimer.start()
	spaceship = get_parent().get_parent().get_node("Spaceship") # variabile della navicella
	
# l'opzione One-Shot del movementTimer lo resetta in automatico quando il tempo finisce
func _process(delta):
	
	# il nemico spawna sopra lo schermo, quindi lo muoviamo verso il basso
	if global_position.y < 56:
		global_position.y += speed*delta
		
	var bodies = $Area2D.get_overlapping_bodies() # ottengo una lista con tutti i corpi che overlappano il nemico
	for body in bodies: # li controllo tutti
		if body.name == "Spaceship": # se trovo Spaceship
			emit_signal("death", self)
			emit_signal("crush") # emetto il segnale che sta collidendo
	
	if !attacking and $movementTimer.time_left == 0:
		$movementTimer.start()
		if randf() < 0.5:
			movement = Vector2()
		else:
			movement = get_random_direction()
	
	if $attackTimer.time_left < 0.1 and $attackTimer.time_left > 0:
		$homingTimer.start()
		$enemy.play("Chasing")
		attacking = true
	
	if attacking:
		if $homingTimer.time_left == 0:
			emit_signal("death", self)
		else:
			spaceshipPos = spaceship.global_position
			look_at(spaceshipPos)
			movement = _attack()
	
	if !attacking:
		move_and_collide(movement*speed*delta) # sposto il nemico nella direzione "get_random_direction", con velocità speed, in un tempo delta
	else:
		move_and_collide(2*movement*speed*delta)
	
	if global_position.x > 1040: # se il nemico si trova oltre il bordo destro
		global_position.x = -20 # lo riporta a sinistra
	if global_position.x < -20: # viceversa
		global_position.x = 1040
	
	if global_position.y < 28: # controlla se il nemico è fuori dal bordo in alto
		global_position.y = 28 # resetta la posizione iniziale
	if global_position.y > 300 and !attacking: # controlla se il nemico è fuori dal bordo in basso
		global_position.y = 300 # blocca al limite
		
# funzione per generare il movimento casuale del nemico
func get_random_direction():
	var random_direction = Vector2() # vettore che prenderà la direzione randomica
	var random_float = randf() # genero un numero casuale con randf
	
	if random_float < 0.25:
		random_direction.x = -1 # movimento a sinistra
	# basta scrivere < 0.5, perchè è già > 0.25 in quanto la consizione precedente non è stata verificata
	elif random_float < 0.5:
		random_direction.x = 1 # movimento verso destra
	# basta scrivere < 0.75, perchè è già > 0.5 in quanto le condizioni precedenti non sono verificate
	elif random_float < 0.75:
		random_direction.y = -1 #movimento verso l'alto
	# se la variabile è > 0.75
	else:
		random_direction.y = 1 #movimento verso il basso

	return random_direction # valore di ritorno della funzione

func _attack():
	var attackPath = spaceshipPos - global_position
	var L = attackPath.length()
	return attackPath / L
