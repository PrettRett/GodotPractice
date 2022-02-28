extends KinematicBody2D

signal start_shooting
signal stop_shooting

const maxXCamOffset = 150
const maxYCamOffset = 150

var maxCamZoom = 0

const ARROW_INITIAL_SPEED = 600
const M_CAM_ZOOM = 1.5

onready var sprite = $Sprite
onready var bSprite = $BowSprite
onready var bPos= $PositionBow
onready var animationPlayer = $AnimationPlayer
onready var myCam = $CameraPlayer
onready var invTimer = $InvTimer
onready var vidaBar = $CanvasLayer/VidaBar

var motion = Vector2()
var invincible = false

var xCamOffset = 0
var yCamOffset = 0
var camZoom = 1

var shooting = false

var health = 100.0
var healthMax = 100.0

#var arrow = preload("res://player/RigidArrow2D.tscn")
var arrow = preload("res://player/KinematicArrow2D.tscn")

var createdArrow

func _ready():
	GlobalInfo.global_player = self

func _exit_tree():
	GlobalInfo.global_player = null

func _physics_process(delta):
	pass
	motion.y += GlobalInfo.gravity
	var friction = false
	
	if health > 0.0:
		if Input.is_action_pressed("ui_right"):
			sprite.flip_h=true
			bSprite.flip_h=true
			animationPlayer.play("Walk")
			if (motion.x < GlobalInfo.MAX_SPEED):
				motion.x += (GlobalInfo.ACCERELATION)
		elif Input.is_action_pressed("ui_left"):
			sprite.flip_h=false
			bSprite.flip_h=false
			animationPlayer.play("Walk")
			if (motion.x > -GlobalInfo.MAX_SPEED):
				motion.x -= (GlobalInfo.ACCERELATION)
		else:
			animationPlayer.play("Stand")
			friction = true
			#if xCamOffset > 0:
			#	xCamOffset -= maxXCamOffset*delta
			#if xCamOffset < 0:
			#	xCamOffset += maxXCamOffset*delta
			#if abs(xCamOffset) < 1:
			#	xCamOffset = 0
		
		myCam.offset.x = xCamOffset
		myCam.offset.y = yCamOffset
		
		if Input.is_action_just_pressed("shoot"):
			if shooting == false:
				createdArrow = arrow.instance()
				get_parent().add_child(createdArrow)
				add_collision_exception_with(createdArrow)
				emit_signal("start_shooting")
				print("send start")
			shooting = true
			
		if false:
			if abs(get_local_mouse_position().angle()) < PI/2:
				if xCamOffset < maxXCamOffset:
					xCamOffset += maxXCamOffset*delta
			else:
				if xCamOffset > -1*maxXCamOffset:
					xCamOffset -= maxXCamOffset*delta
		
		var relMousePosition = (get_local_mouse_position().x + xCamOffset)/(get_viewport().size.x)*2
		var targetOffset = relMousePosition*maxXCamOffset
		
		xCamOffset = targetOffset
		
		relMousePosition = (get_local_mouse_position().y + yCamOffset)/(get_viewport().size.y)*2
		targetOffset = relMousePosition*maxYCamOffset
		
		yCamOffset = targetOffset
		
		if shooting:
			if camZoom < maxCamZoom:
				camZoom += maxCamZoom*delta
			var mousePos = get_local_mouse_position()
			var auxPos = (bPos.position)
			createdArrow.position =position + auxPos
			var velocityNormal = auxPos.direction_to(mousePos)
			createdArrow.rotation = velocityNormal.angle() + (PI/2)
			bSprite.rotation = velocityNormal.angle()
			bSprite.flip_h=false
			if Input.is_action_just_released("shoot"):
				emit_signal("stop_shooting")
				print("send shoot")
				bSprite.rotation = PI
				bSprite.flip_h = sprite.flip_h
				shooting = false
		else:
			if camZoom > M_CAM_ZOOM:
				camZoom -= maxCamZoom*delta/3
			else:
				camZoom = M_CAM_ZOOM
		
		myCam.zoom = Vector2(camZoom,camZoom)
		
		if is_on_floor():
			if Input.is_action_just_pressed("ui_up"):
				motion.y = GlobalInfo.JUMP_H
			if friction == true:
				motion.x = lerp(motion.x,0,0.07)
		else:
			if friction ==true:
				motion.x = lerp(motion.x,0,0.01)
		
	motion = move_and_slide(motion,GlobalInfo.UP)

func death():
	print("i Die")
	$CollisionShape2D.disabled = true
	myCam.current = false
	pass
	
func damaged(dmg_val,src,coll_info):
	if invincible == false:
		health -= dmg_val
		print("I've been hit")
		invTimer.start()
		var right_dir = (src.global_position.x - self.global_position.x) < 0
		var jDir = (Vector2.LEFT + Vector2.UP)
		if right_dir:
			jDir = (Vector2.RIGHT + Vector2.UP)
		motion = jDir * GlobalInfo.MAX_SPEED*3
		print(String(motion))
		if health <= 0:
			death()
		invincible = true
		var perVida = health/healthMax
		vidaBar.value = perVida*100.0
		
	

func _shoot(shoot_strenght):
	print("start shoot")
	pass
	#var nArrow = arrow.instance()
	var mousePos = get_local_mouse_position()
	
	var xDir = -1.0
	if sprite.flip_h:
		xDir = 1.0
	
	var auxPos = (bPos.position * Vector2(xDir,1))
	#nArrow.position =position + auxPos
	var velocityNormal = auxPos.direction_to(mousePos)
	#nArrow.linear_velocity = velocityNormal*ARROW_INITIAL_SPEED
	#print("my pos is: ", nArrow.position)
	#print("mouse pos is: ", mousePos)
	print(shoot_strenght)
	if shoot_strenght > 0:
		if shoot_strenght < 10:
			shoot_strenght = 0.1 # 10% shoot strenght
		elif shoot_strenght < 40:
			shoot_strenght = shoot_strenght/100
		elif shoot_strenght < 80:
			shoot_strenght = shoot_strenght/100 + 0.2
		else:
			shoot_strenght = shoot_strenght/100 + 1.0
	
	#get_parent().add_child(nArrow)
	#nArrow.speed = velocityNormal*1000.0
	#nArrow.imShot = true
	createdArrow.speed = (velocityNormal*(shoot_strenght*4 + 5.0)*200.0)
	createdArrow.imShot = true
	

func _on_TextureProgress_final_value(act_value):
	call_deferred("_shoot",act_value)
	pass # Replace with function body.


func _on_InvTimer_timeout():
	invincible = false
	pass # Replace with function body.
