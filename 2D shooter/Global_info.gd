extends Node

const MAX_SPEED = 300
const ACCERELATION = 70
const JUMP_H = -900
const UP = Vector2(0,-1)
const gravity = 40
const jsonFileSave = "user://mySaveInfo.json"
const default_screen_size = Vector2(1024,600)

# Declare member variables here. Examples:
var global_time = [0.0,0.0,0.0]
var global_score = 0
var global_player = null
	
