extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var charBase = preload("res://multPlayer/platShoot/platPlayer.tscn")

onready var position_1 = $Position_topLeft
onready var position_2 = $Position_bottomRight

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
