extends KinematicBody2D

enum arrowType {
	DEFAULT,
	LONG,
	EXPLOSIVE,
	MULTIPLE,
}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var anim = $AnimationPlayer
onready var myImg = $Sprite
onready var myTime = $selfDestroyer
onready var selfType = arrowType.DEFAULT
onready var selfLoad = load("res://multPlayer/platShoot/MultArrow2D.tscn")
onready var explodeArea = $Area2D
onready var blastSprite = $exploteSprite

var GRAVITY = 800.0

var pup_speed = Vector2(1,0)
puppet var pup_position = Vector2(1,0)
var imShot = false

var speed = Vector2(1,0) setget set_speed
var speedModifier = 1.0
var dmgModifier = 1.0

var blastDmg = 2500
var blastPushVal = 1500
var blastTime = 0.4

var possibleError = deg2rad(5)
const nOfAdditional = 4
var childArr = []
var avoidArr = []

var collided = false

var followObj = null

# Called when the node enters the scene tree for the first time.
func _ready():
	rpc_config("shoot",MultiplayerAPI.RPC_MODE_REMOTESYNC)
	anim.play("normal")
	blastSprite.visible = false

func masterSetArrowType(type):
	rpc("setArrowType",type)

remotesync func setArrowType(type):
	selfType = type
	if type == arrowType.DEFAULT:
		myImg.modulate = Color( 1, 0, 0, 1 )
		GRAVITY = 800.0
		speedModifier = 1.0
		dmgModifier = 1.0
		pass
	elif type == arrowType.LONG:
		myImg.modulate = Color( 0, 1, 0, 1 )
		GRAVITY = 500.0
		speedModifier = 1.3
		dmgModifier = 0.5
		pass
	elif type == arrowType.EXPLOSIVE:
		myImg.modulate = Color( 1, 0.5, 0, 1 )
		GRAVITY = 400.0
		speedModifier = 0.5
		dmgModifier = 3.0
		myTime.wait_time = 1
		#set flag for explote on impact
		pass
	elif type == arrowType.MULTIPLE:
		myImg.modulate = Color( 1, 0, 0, 1 )
		GRAVITY = 800.0
		speedModifier = 1.0
		dmgModifier = 1.0
		#prepare for multiple sync shot
		for i in range(nOfAdditional):
			var createdArrow = GlobalAction.instance_node_at_location(selfLoad,get_parent(),self.global_position)
			createdArrow.set_network_master(int(get_parent().name))
			createdArrow.bind_postion(followObj)
			createdArrow.avoid(self)
			createdArrow.avoid(avoidArr)
			createdArrow.avoid(childArr)
			childArr.append(createdArrow)
		print(childArr)
		pass
	pass

func avoid(obj):
	if typeof(obj) == TYPE_ARRAY:
		for element in obj:
			avoidArr.append(element)
			add_collision_exception_with(element)
	else:
		avoidArr.append(obj)
		add_collision_exception_with(obj)

func bind_postion(obj):
	followObj = obj

func master_shoot(speedValue,initPos):
	if is_network_master():
		rpc("shoot",speedValue,initPos)

remotesync func shoot(speedValue,initPos):
	if selfType == arrowType.MULTIPLE:
		#shoot all simultaneously
		for arr in childArr:
			var chSpeed = speedValue.rotated(rand_range(-possibleError,possibleError))
			arr.master_shoot(chSpeed,initPos)
	global_position = initPos
	speed = speedValue*speedModifier
	imShot = true
	#myTime.start()

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
				if !collided:
					collided = true
					if selfType != arrowType.EXPLOSIVE:
						print("fade")
						anim.play("fade")
						if collision.get_collider().has_method("hitted"):
							collision.get_collider().hitted(speed*dmgModifier,self,collision)
							get_parent().add_score(speed.length())
					else:
						print("explote")
						blastSprite.visible = true
						anim.play("Explosion")
						#get objects to attack
						var vecDmg = Vector2(blastDmg,0)
						for obj in explodeArea.get_overlapping_bodies():
							if obj.has_method("hitted"):
								obj.hitted(vecDmg,self,null)
								get_parent().add_score(blastDmg/5)
							if obj.has_method("push"):
								var pushVec = global_position.direction_to(obj.global_position)*blastPushVal
								obj.push(pushVec,blastTime)
						pass
			else:
				speed = speed.bounce(collision.get_normal())*0.7
	else:
		if is_instance_valid(followObj) and !collided:
			global_position = followObj.global_position

func destroyer():
	if is_network_master():
		rpc("destroy")

remotesync func destroy() -> void:
	queue_free()

func _on_selfDestroyer_timeout():
	imShot = false
	if selfType != arrowType.EXPLOSIVE and !collided:
		blastSprite.visible = true
		anim.play("Explosion")
		#explote it
	else:
		anim.play("fade")
		pass
