extends Node

var playerTemp = load("res://Connections/PlayerBase.tscn")
var labelTemp = load("res://Connections/labelToCopy.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var players_connected = 1
onready var baseLabel = $MarginContainer/ColorRect/MarginContainer/VBoxContainer
onready var myLabel = $MarginContainer/ColorRect/MarginContainer/VBoxContainer/Player
onready var startButt = $MarginContainer/ColorRect/Button

var update_names = false

var tagMap = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	
	if get_tree().network_peer != null:
		players_connected = 0
		instance_player(get_tree().get_network_unique_id())
		
		myLabel.text = ConnServer.ip_address
		
		for player in CommonPool.get_children():
			if player.is_in_group("Player"):
				players_connected += 1
	else:
		ConnServer.join_server()
		startButt.hide()
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if get_tree().network_peer != null:
		if get_tree().get_network_connected_peers().size() >= 1 and get_tree().is_network_server():
			startButt.show()
		else:
			startButt.hide()
	if update_names:
		var allUpdated = true
		for tag in tagMap:
			var ply = tagMap[tag][0]
			var lbl = tagMap[tag][1]
			
			if (ply.proxyUsername != "") and (ply.proxyUsername != null):
				lbl.text = ply.proxyUsername
			else:
				var proxyTemp = ply.proxy_username_get()
				allUpdated = false
		
		if allUpdated:
			update_names = false

func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")
	
	instance_player(id)

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")
	
	if CommonPool.has_node(str(id)):
		CommonPool.get_node(str(id)).queue_free()

func _on_Create_server_pressed():
	ConnServer.create_server()

	instance_player(get_tree().get_network_unique_id())

func _on_Join_server_pressed():
	pass

func _connected_to_server() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	instance_player(get_tree().get_network_unique_id())

func instance_player(id) -> void:
	var player_instance = GlobalAction.instance_node(playerTemp, CommonPool)
	
	var newLabel = GlobalAction.instance_node(labelTemp, baseLabel)
	
	players_connected += 1
	player_instance.name = str(id)
	player_instance.set_network_master(id)
	player_instance.username = GlobalAction.localUsername
	update_names = true
	tagMap[id] = [player_instance,newLabel]
	

func _on_Start_game_pressed():
	rpc("switch_to_game")

sync func switch_to_game() -> void:
	for child in CommonPool.get_children():
		if child.is_in_group("Player"):
			#prepare to start
			pass
	
	#start game

