extends Node

onready var playStart = $MarginContainer/ColorRect/CenterContainer/VBoxContainer/CenterContainer2
onready var settings = $MarginContainer/ColorRect/CenterContainer/VBoxContainer/CenterContainer3
onready var exit = $MarginContainer/ColorRect/CenterContainer/VBoxContainer/CenterContainer4

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func onFieldClicked(auxMux):
	if auxMux == 0:
		print("label1")
		get_tree().change_scene("res://Menus/LevelSelect.tscn")
		pass # option play level
	if auxMux == 1:
		print("label2")
		pass # option settings
	if auxMux == 2:
		get_tree().quit()
		pass # option quit

func _on_CenterContainer2_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		onFieldClicked(0)
	pass # Replace with function body.

func _on_CenterContainer3_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		onFieldClicked(1)
	pass # Replace with function body.


func _on_CenterContainer4_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		onFieldClicked(2)
	pass # Replace with function body.
