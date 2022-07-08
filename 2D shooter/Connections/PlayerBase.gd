extends Node

var username setget username_set

puppet var puppet_username setget puppet_username_set
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func username_set(newName):
	username = newName
	
	if get_tree().has_network_peer():
		if is_network_master():
			rset("puppet_username", username)
			
puppet func puppet_username_set (newName):
	puppet_username = newName
	
	if get_tree().has_network_peer():
		if not is_network_master() and username != puppet_username:
			username = puppet_username
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
