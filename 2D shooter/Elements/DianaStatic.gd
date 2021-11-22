extends KinematicBody2D

var times_hitted = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var xPosTop
var xPosMidTop
var xPosGoalTop
var xPosGoalBot
var xPosMidBot
var xPosBottom

# Called when the node enters the scene tree for the first time.
func _ready():
	xPosTop = ($PosTop as Position2D).global_position.x + position.x
	xPosMidTop = ($PosMidTop as Position2D).global_position.x + position.x
	xPosGoalTop = ($PosGoalTop as Position2D).global_position.x + position.x
	xPosGoalBot = ($PosGoalBot as Position2D).global_position.x + position.x
	xPosMidBot = ($PosMidBot as Position2D).global_position.x + position.x
	xPosBottom = ($PosBottom as Position2D).global_position.x + position.x
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func check_in_between(main, val1,val2) -> bool:
	var result = ((main > val1) and (main < val2)) or ((main < val1) and (main > val2))
	return result

func hitted(dmg_val,src,collision):
	pass
	var collPos = collision.position.x
	print(xPosTop)
	print(xPosBottom)
	print(collPos)
	if times_hitted == 0:
		GlobalInfo.global_score += 1
		if check_in_between(collPos,xPosTop,xPosMidTop) or check_in_between(collPos,xPosBottom,xPosMidBot):
			GlobalInfo.global_score += 10
		if check_in_between(collPos,xPosGoalTop,xPosMidTop) or check_in_between(collPos,xPosGoalBot,xPosMidBot):
			GlobalInfo.global_score += 20
		if check_in_between(collPos,xPosGoalTop,xPosGoalBot):
			GlobalInfo.global_score += 50
	times_hitted += 1
