extends Node

var arcade_current_score = 0
var arcade_current_coins = 0
var arcade_current_kills = 0
var arcade_current_lives = 3
var arcade_current_level = 0
var arcade_current_speed = 300

var arcade_current_difficulty = "normie"
var arcade_current_limits = {}
var difficulty_sets = {"ez":{"normal": 3, "shooter": 1, "kamikaze": 0},
					   "normie":{"normal": 4, "shooter": 2, "kamikaze": 0},
					   "pro":{"normal": 5, "shooter": 2, "kamikaze": 1}}

var with_touch = !OS.has_touchscreen_ui_hint()

func _set_difficulty():
	arcade_current_limits = difficulty_sets[arcade_current_difficulty]

var arcade_upgrades_picked = {"speed":0, "reload":0, "powerups":0}

func _globals_reset():
	arcade_current_lives = 3
	arcade_current_score = 0
	arcade_current_coins = 0
	arcade_current_kills = 0
	arcade_current_speed = 250
	arcade_current_level = 0
	arcade_current_limits = {}
	arcade_upgrades_picked = {"speed":0, "reload":0, "powerups":0}

func _arcade_score_saver():
		SaveData.data["HighScore"] = max(SaveData.data["HighScore"], globals.arcade_current_score)
		SaveData.data["Coins"] += globals.arcade_current_coins
		SaveData.save_game()
