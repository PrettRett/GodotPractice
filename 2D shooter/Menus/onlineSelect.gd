extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var ipLabel = $MarginContainer/ColorRect/LabelOnline2 as Label

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	ipLabel.text = ConnServer.ip_address
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _player_connected(new_player_id) -> void:
	print("New player is " + str(new_player_id))
	
	pass


func _player_disconnected(gone_player_id) -> void:
	print("Gone player is " + str(gone_player_id))
	pass


func _connected_to_server() -> void:
	print("successfully connected")
	pass

func _on_CreateButt_pressed():
	print("Create butt")
	pass # Replace with function body.


func _on_JoinButt_pressed():
	print("join butt")
	pass # Replace with function body.


func _on_JoinButt2_pressed():
	get_tree().change_scene("res://Menus/MainTitle.tscn")
	pass # Replace with function body.
