extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var disabled = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	($Timer as Timer).start()

func disable():
	if disabled:
		return

	($AnimationPlayer as AnimationPlayer).play("irse")
	disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
	if linear_velocity.length() > 10.0:
		rotation = linear_velocity.angle() + (PI/2)
	else:
		gravity_scale = 0
		sleeping = true


func _on_Timer_timeout():
	queue_free()
