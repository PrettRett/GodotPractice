extends HittedObj

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const DMG_MODIFIER = 0.1
const HIT_VALUE = 10

const MIN_move = 0.7
const MAX_move = 5

enum RedEnSt {
	RED_ENE_INVISIBLE,
	RED_ENE_IDLE,
	RED_ENE_RUNNIN,
	RED_ENE_JUMPING,
	RED_ENE_ATTACKING,
	RED_ENE_RECV_DMG,
	RED_ENE_DYING,
}

onready var enemyState = RedEnSt.RED_ENE_IDLE
onready var visNotifier = $VisibilityNotifier2D
onready var myImg = $AnimatedSprite
onready var enemyHealth = 1000.0

var minHealthCmp = 50.0
var maxHealthCmp = 200.0

var hitNum = 0
var LastDmg = 0.0
var hitDir = Vector2(0,0)

var move = Vector2(0,0)
var ready = false


# Called when the node enters the scene tree for the first time.
func _ready():
	ready = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if ready and GlobalInfo.global_player != null:
		#get player vector
		var movDir = self.position.direction_to(GlobalInfo.global_player.position)
		match(enemyState):
			RedEnSt.RED_ENE_INVISIBLE:
				if visNotifier.is_on_screen():
					enemyState = RedEnSt.RED_ENE_IDLE
			RedEnSt.RED_ENE_IDLE:
				var disToDetect = 170.0
				var goodAngle = false
				myImg.animation = "Idle"
				myImg.playing = true
				if !myImg.flip_h:
					goodAngle = (movDir.angle() < PI/4) and (movDir.angle() > -PI/4)
				else:
					goodAngle = (movDir.angle() > 3*PI/4) and (movDir.angle() < -3*PI/4)
				
				if !goodAngle:
					disToDetect = 50.0
				if position.distance_to(GlobalInfo.global_player.position) < disToDetect:
					enemyState = RedEnSt.RED_ENE_RUNNIN
				pass
			RedEnSt.RED_ENE_RUNNIN:
				myImg.animation = "Run"
				myImg.playing = true
				var Dir = 1.0
				myImg.flip_h = false
				if movDir.x < 0.0:
					myImg.flip_h = true
					Dir = -1.0
				move.x = move.x+(GlobalInfo.ACCERELATION*0.7*Dir)
				move.x = min(move.x,(GlobalInfo.MAX_SPEED*0.7))
				move.x = max(move.x,(GlobalInfo.MAX_SPEED*-0.7))
				pass
			RedEnSt.RED_ENE_JUMPING:
				pass
			RedEnSt.RED_ENE_ATTACKING:
				pass
			RedEnSt.RED_ENE_RECV_DMG:
				var Dir = 1.0
				if move.x < 0.0:
					Dir = -1.0
				if LastDmg < minHealthCmp:
					move.x = (GlobalInfo.MAX_SPEED*MIN_move*Dir)
				elif LastDmg > maxHealthCmp:
					move.x = (GlobalInfo.MAX_SPEED*MAX_move*Dir)
				else:
					var xCalc = ((LastDmg - minHealthCmp)/(maxHealthCmp-minHealthCmp))*(MAX_move - MIN_move) + MIN_move
					move.x = (GlobalInfo.MAX_SPEED*xCalc*Dir)
				pass
			RedEnSt.RED_ENE_DYING:
				($CollisionShape2D as CollisionShape2D).disabled = true
				($CollisionShape2D2 as CollisionShape2D).disabled = true
				self.z_index = 5
				pass
			_:
				enemyState = RedEnSt.RED_ENE_IDLE
		if (enemyState == RedEnSt.RED_ENE_INVISIBLE):
			self.visible = false
		else:
			self.visible = true
			#Apply gravity
			move.y += GlobalInfo.gravity
			if !visNotifier.is_on_screen():
				enemyState = RedEnSt.RED_ENE_INVISIBLE
		move.x = lerp(move.x,0,0.1)
		move_and_slide(move)
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			if collision.get_collider().has_method("damaged"):
				collision.get_collider().damaged(HIT_VALUE,self,collision)

func hitted(dmg_val,src,collision):
	if enemyState != RedEnSt.RED_ENE_RECV_DMG:
		hitDir = position.direction_to(GlobalInfo.global_player.position)
		var Dir = -1.0
		if hitDir.x < 0.0:
			Dir = 1.0
		move.x = (GlobalInfo.MAX_SPEED*0.7*Dir)
		move.y = (GlobalInfo.JUMP_H/4)
		enemyState = RedEnSt.RED_ENE_RECV_DMG
		LastDmg = dmg_val.length()*DMG_MODIFIER
		enemyHealth -= LastDmg
		hitNum += 1
		if enemyHealth <= 0.0:
			enemyHealth = 0.0
			enemyState = RedEnSt.RED_ENE_DYING
			myImg.animation = "Dead"
			myImg.playing = true
			($DamageTimer as Timer).wait_time = 2.0
			GlobalInfo.global_score += 300.0/hitNum
		($DamageTimer as Timer).start()
	pass


func _on_Timer_timeout():
	if enemyState == RedEnSt.RED_ENE_RECV_DMG:
		enemyState = RedEnSt.RED_ENE_RUNNIN
	if enemyState == RedEnSt.RED_ENE_DYING:
		queue_free()
