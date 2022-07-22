extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var Sorter = $MarginContainer/ColorRect/VBoxContainer
onready var rowResults = load("res://tools/ScoreBase.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var playersSorted = get_sorted_players()
	var index = 0
	print(playersSorted)
	for player in playersSorted:
		if index < 4:
			var resShower = GlobalAction.instance_node(rowResults,Sorter)
			resShower.setName(player.get_parent().proxy_username_get())
			resShower.setScore(50)
			if player.is_player_dead():
				resShower.setState("Dead")
			else:
				resShower.setState("Alive")
		index += 1
	pass # Replace with function body.

func get_sorted_players() -> Array:
	var result = []
	
	for child in CommonPool.get_children():
		for player in child.get_children():
			if player.has_method("is_player_dead"):
				result.append(player)
	
	return result
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_ChangeToMain_timeout():
	var playersSorted = get_sorted_players()
	for player in playersSorted:
		player.queue_free()
	get_tree().change_scene("res://Connections/ConnPlayers.tscn")
	pass # Replace with function body.
