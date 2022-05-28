extends Node

onready var timeLabel = $MarginContainer/ColorRect/VBoxContainer/HBoxContainer/VBoxContainer/Label2 as Label
onready var scoreLabel = $MarginContainer/ColorRect/VBoxContainer/HBoxContainer/VBoxContainer/Label3 as Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func onFieldClicked(auxMux):
	if auxMux == 0:
		print("label1")
		GlobalInfo.global_score = 0
		GlobalInfo.global_time = 0
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
	var myFile = File.new()
	if (myFile.file_exists(GlobalInfo.jsonFileSave)):
		print(myFile.open(GlobalInfo.jsonFileSave,File.READ))
		var DataJson = JSON.parse(myFile.get_as_text())
		myFile.close()
		var myDict = DataJson.result
		if typeof(myDict) != TYPE_NIL:
			if "FirstTime" in myDict:
				timeLabel.text = (String(myDict["FirstTime"]))
			if "FirstPoints" in myDict:
				scoreLabel.text = ("Clear Points:" + String(myDict["FirstPoints"]))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_CenterContainer_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		onFieldClicked(0)
	pass # Replace with function body.


func _on_CenterContainer2_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		onFieldClicked(0)
	pass # Replace with function body.
