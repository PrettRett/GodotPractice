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
	for player in playersSorted:
		if index < 4:
			var resShower = GlobalAction.instance_node(rowResults,Sorter)
			resShower.setName(player.get_parent().proxy_username_get())
			resShower.setScore(player.get_score())
			if player.is_player_dead():
				resShower.setState("Dead")
			else:
				resShower.setState("Alive")
		index += 1
	pass # Replace with function body.

func isFirstPlayerGreater(player1,player2):
	if player1.is_player_dead() == player2.is_player_dead():
		if player1.get_score() > player2.get_score():
			return true
		else:
			return false
	elif not player1.is_player_dead() and player2.is_player_dead():
		return true
	else:
		return false

func get_sorted_players() -> Array:
	var midArr = []
	var result = []
	
	for child in CommonPool.get_children():
		for player in child.get_children():
			if player.has_method("is_player_dead"):
				midArr.append(player)
	
	result.append(midArr[0])
	for i in range(midArr.size()-1):
		var indexMid = 0
		while((indexMid < result.size()) and not (isFirstPlayerGreater(midArr[i+1],result[indexMid]))):
			indexMid += 1
		result.insert(indexMid,midArr[i+1])
	
	return result
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_ChangeToMain_timeout():
	var playersSorted = get_sorted_players()
	for player in playersSorted:
		player.queue_free()
	if get_parent().has_method("returnToMenu"):
		get_parent().returnToMenu()
	queue_free()
	pass # Replace with function body.
