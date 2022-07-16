extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var anim = $AnimationPlayer


puppet var pup_speed = Vector2(1,0)
puppet var pup_position = Vector2(1,0)
puppet var imShot = false

var speed = Vector2(1,0) setget set_speed

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("normal")

func set_speed(speed_value):
	speed = speed_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if imShot:
		# do shooting stuff
		pass
