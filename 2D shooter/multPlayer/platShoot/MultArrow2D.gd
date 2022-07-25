extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var anim = $AnimationPlayer

const GRAVITY = 800.0

var pup_speed = Vector2(1,0)
puppet var pup_position = Vector2(1,0)
var imShot = false

var speed = Vector2(1,0) setget set_speed

var collided = false

var followObj = null

# Called when the node enters the scene tree for the first time.
func _ready():
	rpc_config("shoot",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	anim.play("normal")
	

func bind_postion(obj):
	followObj = obj

func master_shoot(speedValue,initPos):
	rpc("shoot",speedValue,initPos)

remotesync func shoot(speedValue,initPos):
	global_position = initPos
	speed = speedValue
	imShot = true
	pass

func set_speed(speed_value):
	speed = speed_value
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if imShot:
		speed.y += GRAVITY*delta
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
						collision.get_collider().hitted(speed,self,collision)
						get_parent().add_score(speed.length())
			else:
				speed = speed.bounce(collision.get_normal())*0.7
	else:
		if is_instance_valid(followObj):
			global_position = followObj.global_position

func destroyer():
	if is_network_master():
		rpc("destroy")

remotesync func destroy() -> void:
	queue_free()

func _on_selfDestroyer_timeout():
	anim.play("fade")
	imShot = false
	pass # Replace with function body.
