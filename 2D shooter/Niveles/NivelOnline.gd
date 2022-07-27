extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var charBase = preload("res://multPlayer/platShoot/platPlayer.tscn")
onready var endScreen = preload("res://multPlayer/platShoot/onlineEnd.tscn")

onready var position_1 = $Positions/Position_1
onready var position_2 = $Positions/Position_2

var nPosQ = 5

var only_one_player = false
var player_alive = null

remotesync var xPosArray = []
remotesync var yPosArray = []

remotesync var boolForSync = false
# Called when the node enters the scene tree for the first time.
func _ready():
	($CheckEnd as Timer).autostart = false
	($CheckEnd as Timer).stop()
	erase_all_characters()
	
	
	var posDelta = (position_2.global_position - position_1.global_position)/nPosQ
	print(posDelta)
	
	var TotalPos = CommonPool.get_children().size()
	
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			for i in range(TotalPos):
				var hVal = int(rand_range(0,nPosQ+1))
				while xPosArray.count(hVal) != 0:
					hVal = int(rand_range(0,nPosQ+1))
				xPosArray.append(float(hVal))
				var vVal = int(rand_range(0,nPosQ+1))
				while xPosArray.count(vVal) != 0:
					vVal = int(rand_range(0,nPosQ+1))
				yPosArray.append(float(vVal))
			rset("yPosArray",yPosArray)
			rset("xPosArray",xPosArray)
			rset("boolForSync",true)
			print(yPosArray)
			print(xPosArray)
		else:
			while boolForSync == false:
				yield(get_tree().create_timer(0.05), "timeout")
		
	var auxIndex = 0
	
	for child in CommonPool.get_children():
		var startPosition = Vector2(xPosArray[auxIndex]*posDelta.x,yPosArray[auxIndex]*posDelta.y)
		auxIndex += 1
		instance_character(int(child.name), child,startPosition)
		#Create player
		pass
	($CheckEnd as Timer).autostart = true
	($CheckEnd as Timer).start()
	

func erase_all_characters():
	for child in CommonPool.get_children():
		for element in child.get_children():
			element.queue_free()
	

func instance_character(id, parent, position):
	var character_instance = GlobalAction.instance_node(charBase, parent)
	character_instance.set_network_master(id)
	character_instance.masterSpawn(position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if only_one_player:
		only_one_player = false
		#load game end scene
		GlobalAction.instance_node(endScreen,self)
		pass
	pass

func returnToMenu():
	if get_parent().has_method("returnToMenu"):
		get_parent().returnToMenu()
	queue_free()

func _on_CheckEnd_timeout():
	var nAlive = 0
	for child in CommonPool.get_children():
		for player in child.get_children():
			if player.has_method("is_player_dead"):
				if not player.is_player_dead():
					player_alive = player
					nAlive += 1
	if nAlive <= 1:
		for child in CommonPool.get_children():
			for player in child.get_children():
				if player.has_method("is_player_dead"):
					player.updateScore()
		yield(get_tree().create_timer(0.3), "timeout")
		only_one_player = true
		print("game has ended, for all")
		($CheckEnd as Timer).autostart = false
		($CheckEnd as Timer).stop()
	pass # Replace with function body.
