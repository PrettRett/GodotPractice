extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var charBase = preload("res://multPlayer/platShoot/platPlayer.tscn")

onready var position_1 = $Position_topLeft
onready var position_2 = $Position_bottomRight

var only_one_player = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in CommonPool.get_children():
		instance_character(int(child.name), child)
		#Create player
		pass
	

func instance_character(id, parent):
	var character_instance = GlobalAction.instance_node_at_location(charBase, parent, position_2.position)
	character_instance.set_network_master(id)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_CheckEnd_timeout():
	var nAlive = 0
	for child in CommonPool.get_children():
		for player in child:
			if player.has_method("is_player_dead"):
				if not player.is_player_dead():
					nAlive += 1
	if nAlive <= 1:
		only_one_player = true
		print("game has ended, for all")
		($CheckEnd as Timer).autostart = false
		($CheckEnd as Timer).stop()
	pass # Replace with function body.
