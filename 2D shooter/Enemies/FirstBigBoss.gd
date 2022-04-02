extends normalEnemy

onready var myImg = $AnimatedSprite
onready var myVis = $VisibilityNotifier2D
onready var enemyHealth = 1000.0

enum FirstBossStates {
	BASIC_STATE,
	CHARGE_STATE
}

var bossFightState = FirstBossStates.BASIC_STATE

var minHealthCmp = 50.0
var maxHealthCmp = 200.0

const DMG_MODIFIER = 0.05
const HIT_VALUE = 10

const MIN_move = 0.5
const MAX_move = 3

const MIN_time = 0.1
const MAX_time = 1.0

const times_to_die = 3

var hitNum = 0
var LastDmg = 0.0
var hitDir = Vector2(0,0)
var times_dead = 0
var lastDistLock = Vector2(0,0)

var enemDmg = Array()

var move = Vector2(0,0)
var ready = false

func endLevel():
	get_tree().change_scene("res://Menus/LevelSelect.tscn")
	pass

func invisible(delta,iniMov,distToPlay):
	if myVis.is_on_screen():
		enemyState = EnemySt.ENE_IDLE
	return iniMov

func idleMov_phase1(delta,iniMov,distToPlay):
	var disToDetect = 1000.0
	var goodAngle = false
	myImg.animation = "Idle"
	myImg.playing = true
	if !myImg.flip_h:
		goodAngle = (distToPlay.angle() < PI/4) and (distToPlay.angle() > -PI/4)
	else:
		goodAngle = (distToPlay.angle() > 3*PI/4) and (distToPlay.angle() < -3*PI/4)
	
	if !goodAngle:
		disToDetect = 1000.0
	if distToPlay.length() < disToDetect:
		myImg.animation = "Run"
		enemyState = EnemySt.ENE_RUNNIN
	return iniMov

func runMov_phase1(delta,iniMov,distToPlay):
	if distToPlay.x < 0.0:
		myImg.flip_h = true
	else:
		myImg.flip_h = false
	myImg.animation = "Run"
	iniMov = basicRunning(delta,iniMov,distToPlay)
	MovBasicMult = 0.8
	return iniMov

func recvDmg_phase1(delta,iniMov,distToPlay):
	var Dir = 1.0
	if hitDir.x > 0.0:
		Dir = -1.0
	iniMov.x = (GlobalInfo.MAX_SPEED*MIN_move*Dir)
	return iniMov

func iDie_phase1(delta,iniMov,distToPlay):
	iniMov.y += GlobalInfo.gravity
	return iniMov

func attack_phase2(delta,iniMov,distToPlay):
	myImg.animation = "Charge"
	iniMov.x = 0.0
	if distToPlay.x < 0.0:
		myImg.flip_h = true
	else:
		myImg.flip_h = false
	lastDistLock = distToPlay
	return iniMov

func runMov_phase2(delta,iniMov,distToPlay):
	if lastDistLock.x < 0.0:
		myImg.flip_h = true
	else:
		myImg.flip_h = false
	
	myImg.animation = "Run_fast"
	iniMov = basicRunning(delta,iniMov,lastDistLock)
	MovBasicMult = 1.1
	return iniMov

func updateBossState():
	if bossFightState == FirstBossStates.BASIC_STATE:
		dicOfFunc[EnemySt.ENE_INVISIBLE] = funcref(self, "invisible")
		dicOfFunc[EnemySt.ENE_IDLE] = funcref(self, "idleMov_phase1")
		dicOfFunc[EnemySt.ENE_RUNNIN] = funcref(self, "runMov_phase1")
		dicOfFunc[EnemySt.ENE_RECV_DMG] = funcref(self, "recvDmg_phase1")
	elif bossFightState == FirstBossStates.CHARGE_STATE:
		dicOfFunc[EnemySt.ENE_ATTACKING] = funcref(self, "attack_phase2")
		dicOfFunc[EnemySt.ENE_RUNNIN] = funcref(self, "runMov_phase2")
		dicOfFunc[EnemySt.ENE_RECV_DMG] = funcref(self, "runMov_phase2")
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	dicOfFunc[EnemySt.ENE_INVISIBLE] = funcref(self, "invisible")
	dicOfFunc[EnemySt.ENE_IDLE] = funcref(self, "idleMov_phase1")
	dicOfFunc[EnemySt.ENE_RUNNIN] = funcref(self, "runMov_phase1")
	dicOfFunc[EnemySt.ENE_RECV_DMG] = funcref(self, "recvDmg_phase1")
	dicOfFunc[EnemySt.ENE_DYING] = funcref(self, "iDie_phase1")
	MovBasicMult = 0.8
	ready = true
	pass # Replace with function body.

func _physics_process(delta):
	var distPlay = Vector2(0,0)
	if GlobalInfo.global_player != null:
		distPlay = - self.global_position + GlobalInfo.global_player.global_position
	
	move.y = move.y + GlobalInfo.gravity
	if ready:
		move = process_basic_move(delta,move,distPlay)
	
	move.x = min(move.x,(GlobalInfo.MAX_SPEED*MovBasicMult))
	move.x = max(move.x,-(GlobalInfo.MAX_SPEED*MovBasicMult))
	if is_on_floor() and move.y > 0.0 and enemyState != EnemySt.ENE_DYING:
		move.y = 0
	move_and_slide(move,GlobalInfo.UP)

func hitted(dmg_val,src,collision):
	if enemyState != EnemySt.ENE_RECV_DMG and bossFightState != FirstBossStates.CHARGE_STATE:
		hitDir = self.global_position.direction_to(collision.position)
		var Dir = -1.0
		if hitDir.x < 0.0:
			Dir = 1.0
		move.x = (GlobalInfo.MAX_SPEED*Dir)
		MovBasicMult = 0.8
		move.y = (GlobalInfo.JUMP_H)
		enemyState = EnemySt.ENE_RECV_DMG
		LastDmg = dmg_val.length()*DMG_MODIFIER
		enemyHealth -= LastDmg
		hitNum += 1
		var xCalc = ((LastDmg - minHealthCmp)/(maxHealthCmp-minHealthCmp))*(MAX_time - MIN_time) + MIN_time
		if enemyHealth <= 0:
			times_dead += 1
			if times_dead > times_to_die:
				($CollisionMove as CollisionShape2D).disabled = true
				($Area2D/CollisionAttack as CollisionShape2D).disabled = true
				GlobalInfo.global_score += 300.0/hitNum
				enemyState = EnemySt.ENE_DYING
				xCalc = 2.0
		($DamageTimer as Timer).wait_time = xCalc
		($DamageTimer as Timer).start()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.has_method("damaged"):
		body.damaged(HIT_VALUE,self,null)
		enemDmg.append(body)
		($RepeatAttack as Timer).start()
	pass # Replace with function body.


func _on_DamageTimer_timeout():
	enemyState = EnemySt.ENE_RUNNIN
	if enemyHealth <= 0.0:
		if times_dead > times_to_die:
			endLevel()
			queue_free()
		else:
			print("died once more", times_dead)
			enemyHealth = 1000.0
			bossFightState = FirstBossStates.CHARGE_STATE
			updateBossState()
			enemyState = EnemySt.ENE_ATTACKING
			($AttTimer as Timer).start()
	pass # Replace with function body.


func _on_AttTimer_timeout():
	if enemyState == EnemySt.ENE_ATTACKING:
		enemyState = EnemySt.ENE_RUNNIN
		($AttTimer as Timer).start()
	elif enemyState == EnemySt.ENE_RUNNIN:
		bossFightState = FirstBossStates.BASIC_STATE
		enemyHealth = 1000.0
		updateBossState()
		enemyState = EnemySt.ENE_RUNNIN
	pass # Replace with function body.


func _on_RepeatAttack_timeout():
	for ene in enemDmg:
		ene.damaged(HIT_VALUE,self,null)
	pass # Replace with function body.


func _on_Area2D_body_exited(body):
	if body in enemDmg:
		enemDmg.erase(body)
	pass # Replace with function body.
