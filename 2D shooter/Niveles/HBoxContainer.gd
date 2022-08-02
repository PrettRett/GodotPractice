extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func connectSignals(obj):
	if get_tree().has_network_peer():
		if is_network_master():
			obj.connect("setArrowNum", self, "_change_arrowNum")

func _change_arrowNum(num):
	print("flechas: ", str(num))
	if num != 0:
		text = str(num)
	else:
		text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
