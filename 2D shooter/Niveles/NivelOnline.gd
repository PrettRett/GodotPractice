extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var charBase = preload("res://multPlayer/platShoot/platPlayer.tscn")
onready var endScreen = preload("res://multPlayer/platShoot/onlineEnd.tscn")

onready var position_1 = $Positions/Position_1
onready var position_2 = $Positions/Position_1

var nPosQ = 3

var only_one_player = false
var player_alive = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var posDelta = (position_2.global_position - position_1.global_position)/nPosQ
	
	var TotalPos = CommonPool.get_children().size()
	
	var xPosArray = []
	var yPosArray = []
	
	for i in range(TotalPos):
		var hVal = int(rand_range(0,nPosQ+1))
		while xPosArray.count(hVal) != 0:
			hVal = int(rand_range(0,nPosQ+1))
		xPosArray.append(hVal)
		var vVal = int(rand_range(0,nPosQ+1))
		while xPosArray.count(vVal) != 0:
			vVal = int(rand_range(0,nPosQ+1))
		yPosArray.append(vVal)
	var auxIndex = 0
	for child in CommonPool.get_children():
		instance_character(int(child.name), child,Vector2(xPosArray[auxIndex],yPosArray[auxIndex]))
		#Create player
		pass
	

func instance_character(id, parent, position):
	var character_instance = GlobalAction.instance_node_at_location(charBase, parent, position)
	character_instance.set_network_master(id)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if only_one_player:
		only_one_player = false
		#load game end scene
		GlobalAction.instance_node(endScreen,self)
		get_viewport()
		pass
	pass


func _on_CheckEnd_timeout():
	var nAlive = 0
	for child in CommonPool.get_children():
		for player in child.get_children():
			if player.has_method("is_player_dead"):
				if not player.is_player_dead():
					player_alive = player
					nAlive += 1
	if nAlive <= 1:
		only_one_player = true
		print("game has ended, for all")
		($CheckEnd as Timer).autostart = false
		($CheckEnd as Timer).stop()
	pass # Replace with function body.
