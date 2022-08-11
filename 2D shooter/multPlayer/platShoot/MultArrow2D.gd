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

onready var hitSound = $HitArrow
onready var blastSound = $ExploteArrow

onready var updateTime = $UpTime

var GRAVITY = 800.0

puppet var pup_speed = Vector2(1,0) setget pup_speUpdate
puppet var pup_position = Vector2(1,0) setget pup_posUpdate
var imShot = false
var timesSent = 0

var speed = Vector2(1,0)
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
	anim.play("normal")
	blastSprite.visible = false

func masterSetArrowType(type):
	if is_network_master():
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
		speedModifier = 0.7
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
			createdArrow.masterSetArrowType(arrowType.DEFAULT)
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
		
		updateTime.start()

remotesync func shoot(speedValue,initPos):
	if selfType == arrowType.MULTIPLE:
		#shoot all simultaneously
		for arr in childArr:
			var chSpeed = speedValue.rotated(rand_range(-possibleError,possibleError))
			arr.master_shoot(chSpeed,initPos)
	global_position = initPos
	speed = speedValue*speedModifier
	#rset_unreliable("pup_position",global_position)
	#rset_unreliable("pup_speed",speed)
	yield(get_tree(),"idle_frame")
	imShot = true
	#myTime.start()
	

puppet func updateMov(pos,vel):
	pup_position = pos
	pup_speed = speed

remotesync func collision(colideObj, pos):
	imShot = false
	collided = true
	global_position = pos
	if selfType != arrowType.EXPLOSIVE:
		anim.play("fade")
		if colideObj.has_method("hitted"):
			colideObj.hitted(speed*dmgModifier,self,colideObj)
			get_parent().add_score(speed.length())
	else:
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
					if get_tree().is_network_server():
						rpc("collision",collision.get_collider(),global_position)
			else:
				speed = speed.bounce(collision.get_normal())*0.7
	else:
		if is_instance_valid(followObj) and !collided:
			global_position = followObj.global_position

func destroyer():
	if get_tree().is_network_server():
		rpc("destroy")

remotesync func destroy() -> void:
	queue_free()

func playMySound():
	if selfType != arrowType.EXPLOSIVE:
		hitSound.play()
	else:
		blastSound.play()

func _on_selfDestroyer_timeout():
	imShot = false
	if selfType != arrowType.EXPLOSIVE and !collided:
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
		#explote it
	else:
		anim.play("fade")
		pass

puppet func pup_speUpdate(newSpeed):
	pup_speed = newSpeed
	if not is_network_master():
		speed = pup_speed

puppet func pup_posUpdate(newPos):
	pup_position = newPos
	if not is_network_master():
		global_position = pup_position

func _on_UpTime_timeout():
	if is_network_master():
		rpc_unreliable("updateMov",global_position,speed)
		#rset_unreliable("pup_position",global_position)
		#rset_unreliable("pup_speed",speed)
		timesSent += 1
		if timesSent > 1:
			updateTime.stop()
		else:
			updateTime.start()
	pass # Replace with function body.
