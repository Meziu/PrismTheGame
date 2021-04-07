extends Control

# è più comodo
var splash = [ 
"Ready to storm Area 51 >:(", 
"It is dangerous to go alone. Go to space instead", 
"In a galaxy ruled by labelSpaziatori...", 
"Marciello! This is not how to use a Limone!", 
"Don't bother the holy Barrell", 
"Win and Loss are closer than you might think", 
"Fun fact: win and loss are actually very far from eachother now",
"Totally not like Minecraft. Play it though", 
"Will the Prism be with you!", 
"Stupid who reads", 
"This is an amazingly low-budget game!",
"Aliens have failed the Vibe-Check",
"Now with 100% more bugs!!!",
"Too many hours spent working on this, but worth it",
"Completely peanut butter free!",
"Stonks and Baby Yoda weren't Memes of the Decade",
"Shhh... Sleep now...",
"Frick it, I don't wanna die young",
"Rich, like a label",
"Mathematically centered",
"Watch out for file matryoshkas!",
"Splashscreens weren't necessary, now that I think about it...",
"What if... haha jk... unless...",
"More viral than Corona",
"Magikarp, use SplashScreen! Oh, no, it's useless...",
"Not means no",
"Autoload is different from AutoLoad, don't make_dir()",
"Optimization at its finest!",
"They just need to touch",
"Kick 'em in da butt",
"There's no choice",
"Nothing to see here, just aliens flickerin' around",
"Arrays don't start from 0",
"It's going to die lol",
"We got to do it in C#",
"I'm the globals man, my globals are delicious",
"WOOOOHOOOOO, COLORS",
"& Knuckles!",
"Gotta check 'em all",
"Going to discover something that doesn't exist",
"Deep down we all know there is a platypus controlling us",
"Bouncin' bouncin', aw such a good time"
]

var giri = 0
onready var splashScreen = get_node("VBoxContainer/TitleBox/SplashScreen")
onready var timer = splashScreen.get_node("Magikarp")

var shooterPercent = 0.000001
var checkerPercent = 0.0001

func _ready():
	randomize()
	var rand = randf()
	
	if rand < shooterPercent:
		get_node("VBoxContainer/TitleBox/Title").text += "_SHOOTER"
	elif rand < checkerPercent:
		get_node("VBoxContainer/TitleBox/Title").text += "_CHECKER"
		
	splashScreen.text = splash[randi() % splash.size()]
	splashScreen.rect_pivot_offset.x = rect_size.x / 2
	
	globals.arcade_current_difficulty = SaveData.data["Difficulty"]
	globals._set_difficulty()
	
func _process(delta):
	if timer.time_left == 0:
		giri += 1
		timer.start()
	
	var frame = giri % 13 - 6
	var df = sign(frame) * 0.01
	var f0 = 0.95
	
	splashScreen.rect_scale = Vector2(f0 + frame * df, f0 + frame * df)
