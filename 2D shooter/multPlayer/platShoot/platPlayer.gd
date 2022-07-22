extends KinematicBody2D


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

puppet var puppet_position = Vector2(0, 0) setget puppet_position_set
puppet var puppet_velocity = Vector2(0,0)
puppet var puppet_flip_h = true

remotesync var health = 100.0 setget health_change

var dmg_modifier = 0.1
var speed_modifier = 1.0

var recoil = false
var shooting = false
var is_alive = true
var cameraToSet = true
var createdArrow = null
var finalSpeed = Vector2(0,0)
var score = 0
	
var arrow = preload("res://multPlayer/platShoot/MultArrow2D.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	block.disabled = true
	var nameToWrite = get_parent().proxy_username_get()
	if nameToWrite.length() > 10:
		nameToWrite.erase(10,nameToWrite.length()-10)
	userNameLabel.text = nameToWrite
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
	score += value

func get_score():
	return score

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
			finalSpeed = velocity * GlobalAction.multPlayerBaseSpeed*delta*speed_modifier
			move_and_collide(finalSpeed)
			
			if false:#Input.is_action_pressed("click") and can_shoot and not is_reloading:
				rpc("instance_bullet", get_tree().get_network_unique_id())
				
			if is_alive and Input.is_action_just_pressed("shoot") and recoil == false:
				if shooting == false:
					rpc("createArrow", get_tree().get_network_unique_id())
					#emit_signal("start_shooting")
				shooting = true
			
			if shooting and createdArrow != null:
				var mousePos = get_local_mouse_position()
				var auxPos = (($Sprite/Position2D as Position2D).position)
				createdArrow.global_position = global_position + auxPos
				var velocityNormal = auxPos.direction_to(mousePos)
				createdArrow.rotation = velocityNormal.angle() + (PI/2)
				bSprite.rotation = velocityNormal.angle()
				bSprite.flip_h=false
				if Input.is_action_just_released("shoot"):
					#emit_signal("stop_shooting")
					createdArrow.master_shoot(velocityNormal.normalized()*600 + (finalSpeed/delta))
					bSprite.rotation = PI
					bSprite.flip_h = img.flip_h
					shooting = false
					recoil = true
					$AttTimer.start()
					createdArrow = null
			
		else:
			if puppet_flip_h:
				img.flip_h = true
			else:
				img.flip_h = false
			#rotation = lerp_angle(rotation, puppet_rotation, delta * 8)
			
			if not tween.is_active():
				move_and_collide(puppet_velocity * GlobalAction.multPlayerBaseSpeed*delta)
	
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

func is_player_dead():
	return not is_alive

sync func createArrow(id):
	createdArrow = GlobalAction.instance_node_at_location(arrow,get_parent(),self.global_position)
	createdArrow.set_network_master(id)
	add_collision_exception_with(createdArrow)

func hitted(dmg_val,src,collision):
	if get_tree().has_network_peer():
		if is_network_master():
			health += -1* dmg_val.abs().length()*dmg_modifier
			rset("health",health)

func _on_NetUpdate_timeout():
	if get_tree().has_network_peer():
		if is_network_master():
			rset_unreliable("puppet_position", global_position)
			rset_unreliable("puppet_velocity", velocity)
			rset_unreliable("puppet_flip_h", img.flip_h)
		else:
			($NetUpdate as Timer).autostart = false
			($NetUpdate as Timer).stop()


func _on_AttTimer_timeout():
	recoil = false
