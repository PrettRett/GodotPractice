extends TextureProgress

signal actual_strenght(act_value)
signal max_reached(max_value)
signal final_value(act_value)

var strenght_delta = 3
var increase_me = false
var signaled_max = false

const PERIODUPDATE = 3

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var counter = 0
var auxValue = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func reset():
	value = 0

func _process(delta):
	if increase_me and (value < max_value):
		signaled_max = false
		auxValue += strenght_delta*delta
		value += auxValue
		if counter >= PERIODUPDATE:
			emit_signal("actual_strenght",value)
			counter = 0
		counter += 1
	elif (value == max_value) and (!signaled_max):
		emit_signal("max_reached",max_value)
		counter = 0
		auxValue = 0.0
		signaled_max = true
	else:
		auxValue = 0.0
		counter = 0


func _on_KinematicBody2D_start_shooting():
	pass # Replace with function body.
	value = 0
	increase_me = true


func _on_KinematicBody2D_stop_shooting():
	pass # Replace with function body.
	increase_me = false
	emit_signal("final_value",value)
	value = 0
	
