extends Node2D

var direction = Vector2(0,-1)
var distance = 50
var step = 5
var moved = false
var initialPos = Vector2(0,0)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func move_me():
	if not moved:
		moved = true
		var tween = get_node("Tween")
		print("end pos", initialPos + distance*direction)
		if not tween.interpolate_property($BlockBody,"position",initialPos,initialPos + distance*direction,Tween.TRANS_ELASTIC,Tween.EASE_IN_OUT):
			print("mal")
		tween.start()
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	initialPos = $BlockBody.position
	print("my pos is", initialPos)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not moved:
		var fat = get_parent()
		if "times_hitted" in fat:
			if fat.times_hitted > 0:
				print("moving")
				move_me()
		else:
			print("cant move")
			moved = true
	pass


func _on_Timer_timeout():
	$BlockBody.position = $BlockBody.position + (step*direction)
	if ($BlockBody.position - initialPos).length() >= distance:
		moved = true
		$Timer.stop()
	pass # Replace with function body.
