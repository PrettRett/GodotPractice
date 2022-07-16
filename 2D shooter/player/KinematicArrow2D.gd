extends KinematicBody2D

const GRAVITY = 40.0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var anim = $AnimationPlayer
onready var imShot = false
onready var defaultSpeed = 400.0
onready var shotDir = Vector2(1,0)
onready var speed = Vector2(1,0)
onready var collided = false

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("normal")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if imShot:
		speed.y += GRAVITY
		rotation = speed.angle() + (PI/2)
		var collision = move_and_collide(speed*delta)
		if collision:
			if (abs(collision.get_normal().angle_to(speed))< (PI/4)) or (abs(collision.get_normal().angle_to(speed))> (3*PI/4)) or speed.length() < 500.0:
				imShot = false
				($CollisionPolygon2D as CollisionPolygon2D).disabled = true
				anim.play("fade")
				if !collided:
					collided = true
					if collision.get_collider().has_method("hitted"):
						collision.get_collider().hitted(speed.abs(),self,collision)
			else:
				speed = speed.bounce(collision.get_normal())*0.7
		
