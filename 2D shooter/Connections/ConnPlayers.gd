extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var players_connected = 1
onready var baseLabel = $MarginContainer/ColorRect/MarginContainer/VBoxContainer
onready var myLabel = $MarginContainer/ColorRect/MarginContainer/VBoxContainer/Player
onready var startButt = $MarginContainer/ColorRect/Button

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	
	if get_tree().network_peer != null:
		players_connected = 1
		
		myLabel.text = ConnServer.ip_address
		
		for player in CommonPool.get_children():
			if player.is_in_group("Player"):
				players_connected += 1
	else:
		startButt.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
