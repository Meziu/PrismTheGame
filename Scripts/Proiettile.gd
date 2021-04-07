extends KinematicBody2D

export (int) var bullettSpeed = 400 # velocità del proiettile

var target
var score = 0
var kills = 0
var mov = Vector2() # vettore spostamento del proiettile

var redSprite = load("res://Sprites/Bullet/bullet_E2.png")

signal take_damage

func _ready():
	bullettSpeed *= -1 # si cambia la direzione del proiettile dal "basso" verso "l'alto"
	if $Sprite.texture == redSprite:
		connect("take_damage", get_parent().get_parent().get_node("Spaceship"), "_take_damage") # collega il segnale take_damage alla funzione _take damage della Spaceship
	
func _process(delta):
	score = globals.arcade_current_score
	kills = globals.arcade_current_kills
	
	var bodies = $Area2D.get_overlapping_bodies() # ottiene la lista di tutti i corpi che overlappano il proiettile
	for body in bodies: # controlla questi corpi
		if target in body.name: # se i corpi overlappati hanno "enemy" nel nome
			if target == "enemy":
				score += 50
				if "normal" in body.name:
					_explode(body)
				elif "shooter" in body.name:
					_explode(body)
					score += 50 # aggiungo 100 al punteggio
				elif "kamikaze" in body.name:
					_explode(body)
					score += 100
				elif "upgrade" in body.name:
					body.lives -= 1
					body._life_checker()
				globals.arcade_current_score = score # rinnovo del punteggio mostrato
				kills += 1
				globals.arcade_current_kills = kills
			elif target == "Spaceship": 
				emit_signal("take_damage")
			
			queue_free() # elimina il proiettile dalla scena
	
	if global_position.y < 0 or global_position.y > 600: # elimina il proiettile se arriva allo schermo superiore o inferiore
		queue_free()

func _physics_process(delta):
	mov.y = bullettSpeed # movimento sull'asse y è uguale alla velocità con il segno cambiato (-y corrisponde al movimento verso l'alto)
	move_and_collide(mov*delta) # gestisce il movimento del proiettile nel tempo delta

func _explode(Enemy):
	Enemy.emit_signal("death", Enemy)
