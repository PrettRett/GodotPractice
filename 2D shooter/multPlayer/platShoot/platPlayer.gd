extends KinematicBody2D

signal start_shooting
signal stop_shooting
signal changeSym(type)
signal setArrowNum(number)

# Declare member variables here. Examples:
# var a = 2
# var b = "te

onready var block = $H_OneW_Block/TileMap/StaticBody2D/CollisionShape2D
onready var img = $Player
onready var tween = $Tween
onready var bSprite = ($Sprite)
onready var tweenLife = $TweenLife
onready var userNameLabel = $Container/Label
onready var healthBar = $Container/VidaBar
onready var myCamera = $Camera2D

var velocity = Vector2(0, 0)

var puppet_position = Vector2(0, 0)
var puppet_velocity = Vector2(0,0)
var puppet_flip_h = true

remotesync var health = 100.0 setget health_change

var dmg_modifier = 0.02
var speed_modifier = 1.0

var recoil = false
var shooting = false
var is_alive = true
var cameraToSet = true
var finalSpeed = Vector2(0,0)
var score = 0
puppet var puppet_score = 0

var pushed_val = Vector2(0,0)
var pushed_time = 0

var arrow = preload("res://multPlayer/platShoot/MultArrow2D.tscn")
var createdArrow = null
var arrowType = 0
var arrowNumber = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	block.disabled = true
	var nameToWrite = get_parent().proxy_username_get()
	if nameToWrite.length() > 10:
		nameToWrite.erase(10,nameToWrite.length()-10)
	userNameLabel.text = nameToWrite
	
	($CollisionShape2D as CollisionShape2D).disabled = true
	pass # Replace with function body.

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

func health_change(newHealth):
	tweenLife.interpolate_property(healthBar, "value", health, newHealth, 0.5)
	tweenLife.start()
	health = newHealth

func add_score(value):
	if get_tree().has_network_peer():
		if is_network_master():
			score += value
			rset("puppet_score",score)

func updateScore():
	if get_tree().has_network_peer():
		if is_network_master():
			rset("puppet_score",score)

func get_score():
	if get_tree().has_network_peer():
		if is_network_master():
			return score
		else:
			return puppet_score
	else:
		return 0

func _process(delta: float) -> void:
	#if username_text_instance != null:
	#	username_text_instance.name = "username" + name
	
	if get_tree().has_network_peer():
		if is_network_master():
			if cameraToSet:
				myCamera.current = true
				cameraToSet = false
			var x_input = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
			var y_input = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
			
			if (x_input != 0) or (y_input != 0):
				if x_input > 0:
					img.flip_h = true
				elif x_input < 0:
					img.flip_h = false
			velocity = Vector2(x_input, y_input).normalized()
			finalSpeed = velocity * GlobalAction.multPlayerBaseSpeed*speed_modifier
			if pushed_time > 0:
				pushed_time -= delta
				finalSpeed = pushed_val
			move_and_collide(finalSpeed*delta)
			
			if is_alive and Input.is_action_just_pressed("shoot") and recoil == false:
				if shooting == false:
					if arrowType != 0:
						if arrowNumber > 0:
							arrowNumber -= 1
						else:
							arrowType = 0
							emit_signal("changeSym",arrowType)
						emit_signal("setArrowNum",arrowNumber)
					rpc("createArrow", get_tree().get_network_unique_id(),arrowType,ConnServer.networked_object_name_index)
					ConnServer.networked_object_name_index += 1
					emit_signal("start_shooting")
				shooting = true
			
			if shooting and is_instance_valid(createdArrow):
				var mousePos = get_local_mouse_position()
				var auxPos = (($Sprite/Position2D as Position2D).position)
				var velocityNormal = auxPos.direction_to(mousePos)
				createdArrow.rotation = velocityNormal.angle() + (PI/2)
				bSprite.rotation = velocityNormal.angle()
				bSprite.flip_h=false
				if Input.is_action_just_released("shoot"):
					emit_signal("stop_shooting")
					shooting = false
					recoil = true
					$AttTimer.start()
			elif shooting and not is_instance_valid(createdArrow):
					rpc("createArrow", get_tree().get_network_unique_id(),arrowType,ConnServer.networked_object_name_index)
					ConnServer.networked_object_name_index += 1
					#createdArrow.master_shoot(velocityNormal.normalized()*600 + (finalSpeed),createdArrow.global_position)
			
		else:
			if puppet_flip_h:
				img.flip_h = true
			else:
				img.flip_h = false
			#rotation = lerp_angle(rotation, puppet_rotation, delta * 8)
			
			if not tween.is_active():
				move_and_collide(puppet_velocity * GlobalAction.multPlayerBaseSpeed*delta)
				var auxPos = (($Sprite/Position2D as Position2D).position)
	
	if health <= 0 and is_alive:
		#if username_text_instance != null:
		#	username_text_instance.visible = false
		
		if get_tree().has_network_peer():
			if is_network_master():
				rpc("destroy")

remotesync func destroy() -> void:
	print("i died: ", get_parent().name)
	speed_modifier = 3.0
	visible = false
	is_alive = false
	if is_instance_valid(createdArrow):
		createdArrow.destroyer()
	($CollisionShape2D as CollisionShape2D).disabled = true

func connectShoot(obj):
	if get_tree().has_network_peer():
		if is_network_master():
			obj.connect("final_value", self, "_on_Final_Value")

func masterSpawn(position):
	if get_tree().has_network_peer():
		if is_network_master():
			rpc("spawn",position)

remotesync func spawn(position):
	global_position = position
	speed_modifier = 1.0
	visible = true
	is_alive = true
	($CollisionShape2D as CollisionShape2D).disabled = false

func is_player_dead():
	return not is_alive

func recvArrowType(type):
	print("changed")
	arrowType = type
	if type == 1:
		arrowNumber = 4
	elif type == 3:
		arrowNumber = 2
	elif type == 2:
		arrowNumber = 3
	if get_tree().has_network_peer():
		if is_network_master():
			emit_signal("setArrowNum",arrowNumber)
			emit_signal("changeSym",type)

remotesync func createArrow(id,arrowKind, extraId):
	createdArrow = GlobalAction.instance_node_at_location(arrow,get_parent(),self.global_position)
	createdArrow.name = "Arrow" + name + str(extraId)
	if not is_network_master():
		ConnServer.networked_object_name_index += 1
	createdArrow.set_network_master(id)
	createdArrow.bind_postion(($Sprite/Position2D as Position2D))
	createdArrow.avoid(self)
	createdArrow.setArrowType(arrowKind)
		

func hitted(dmg_val,src,collision):
	if get_tree().has_network_peer():
		if is_network_master():
			health += -1* dmg_val.abs().length()*dmg_modifier
			rset("health",health)

func push(push_val,duration):
	if get_tree().has_network_peer():
		if is_network_master():
			pushed_val = push_val
			pushed_time = duration

puppet func updateMovement(pos,vel,flip):
	puppet_position = pos
	puppet_velocity = vel
	puppet_flip_h = flip
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

func _on_NetUpdate_timeout():
	if get_tree().has_network_peer():
		if is_network_master():
			if is_alive:
				rpc_unreliable("updateMovement",global_position,velocity,img.flip_h)
				#rset_unreliable("puppet_position", global_position)
				#rset_unreliable("puppet_velocity", velocity)
				#rset_unreliable("puppet_flip_h", img.flip_h)
		else:
			($NetUpdate as Timer).autostart = false
			($NetUpdate as Timer).stop()

func _on_Final_Value(value):
	if is_instance_valid(createdArrow):
		var mousePos = get_local_mouse_position()
		var velocityNormal = (($Sprite/Position2D as Position2D).position).direction_to(mousePos)
		var modifier = (value/100*0.75) + 0.75
		createdArrow.master_shoot((velocityNormal.normalized()*600 + (finalSpeed*0.7))*modifier,createdArrow.global_position)
		bSprite.rotation = PI
		bSprite.flip_h = img.flip_h
		createdArrow = null
		rpc("playBow")

remotesync func playBow():
	($BowSound as AudioStreamPlayer2D).play()
	pass

func _on_AttTimer_timeout():
	recoil = false
