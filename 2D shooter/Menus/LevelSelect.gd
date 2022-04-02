extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func onFieldClicked(auxMux):
	if auxMux == 0:
		print("label1")
		get_tree().change_scene("res://Niveles/Nivel_Tutorial_Test_1.tscn")
		pass # option play level
	if auxMux == 1:
		print("label2")
		pass # option settings
	if auxMux == 2:
		get_tree().quit()
		pass # option quit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CenterContainer_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		onFieldClicked(0)
	pass # Replace with function body.


func _on_CenterContainer2_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		onFieldClicked(0)
	pass # Replace with function body.
