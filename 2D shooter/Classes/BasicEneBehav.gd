class_name normalEnemy
extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var MovBasicMult = 1.0

enum EnemySt {
	ENE_INVISIBLE,
	ENE_IDLE,
	ENE_RUNNIN,
	ENE_JUMPING,
	ENE_FLYING,
	ENE_ATTACKING,
	ENE_RECV_DMG,
	ENE_DYING,
}

func basicNonFunc(delta,iniMov,distToPlayer):
	return Vector2(0,0)

var noFunc = funcref(self, "basicNonFunc")

func basicRunning(delta,iniMov,distToPlayer):
	var Dir = 1.0
	if distToPlayer.x < 0:
		Dir = -1.0
	iniMov.x = iniMov.x+(GlobalInfo.ACCERELATION*Dir*MovBasicMult)
	return iniMov

var basicRunFunc = funcref(self, "basicRunning")

var dicOfFunc = {
	EnemySt.ENE_INVISIBLE : noFunc,
	EnemySt.ENE_IDLE : noFunc,
	EnemySt.ENE_RUNNIN : basicRunFunc,
	EnemySt.ENE_JUMPING : noFunc,
	EnemySt.ENE_FLYING : noFunc,
	EnemySt.ENE_ATTACKING : noFunc,
	EnemySt.ENE_RECV_DMG : noFunc,
	EnemySt.ENE_DYING : noFunc,
	}

onready var enemyState = EnemySt.ENE_IDLE

func process_basic_move(delta,iniMov,distToPlayer):
	var move = dicOfFunc[enemyState].call_func(delta,iniMov,distToPlayer)
	return move


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
