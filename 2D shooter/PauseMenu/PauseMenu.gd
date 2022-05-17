extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var pasVisible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_pause"):
		if pasVisible:
			pasVisible = false
			visible = false
			get_tree().paused = false
		else:
			pasVisible = true
			visible = true
			get_tree().paused = true
	
	pass

func onFieldClicked(auxMux):
	if auxMux == 0:
		print("label1")
		pasVisible = false
		visible = false
		get_tree().paused = false
		pass # option play level
	if auxMux == 1:
		print("label2")
		pass # option settings
	if auxMux == 2:
		get_tree().paused = false
		get_tree().change_scene("res://Menus/MainTitle.tscn")
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
