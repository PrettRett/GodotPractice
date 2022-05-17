extends Node

const MAX_SPEED = 300
const ACCERELATION = 70
const JUMP_H = -900
const UP = Vector2(0,-1)
const gravity = 40
const jsonFileSave = "user://mySaveInfo.json"

# Declare member variables here. Examples:
var global_time = [0.0,0.0,0.0]
var global_score = 0
var global_player = null
# var b = "text"



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
